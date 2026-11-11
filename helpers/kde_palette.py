#!/usr/bin/env python3
"""Generate an independent, preference-gated Firefox palette from KDE colors.

Reads KDE color data and registers a missing colour-sync Boolean in prefs.js.
Existing saved choices and browser databases are never modified.
The optional user-systemd path unit regenerates CSS when kdeglobals changes.
"""
import argparse
import configparser
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

UNIT = 'firefox-breeze-colour-sync'

def config_home():
    return Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))

def read_ini(path):
    parser = configparser.ConfigParser(interpolation=None, strict=False)
    parser.optionxform = str
    with Path(path).open() as stream:
        parser.read_file(stream)
    return parser

def rgb(value):
    value = value.strip()
    if re.fullmatch(r'#[0-9a-fA-F]{6}', value):
        return tuple(int(value[i:i+2], 16) for i in (1, 3, 5))
    parts = value.split(',')
    if len(parts) not in (3, 4):
        raise ValueError('Invalid KDE color: ' + value)
    values = tuple(int(p.strip()) for p in parts)
    if any(not 0 <= channel <= 255 for channel in values):
        raise ValueError('KDE color channel outside 0–255: ' + value)
    # KDE scheme surfaces use RGB; optional alpha is retained in direct values.
    return values

def css(value):
    if len(value) == 4:
        return f'rgba({value[0]}, {value[1]}, {value[2]}, {value[3] / 255:.5f})'
    return '#' + ''.join(f'{v:02x}' for v in value)

def mix(a, b, amount):
    return tuple(round(x * (1 - amount) + y * amount) for x, y in zip(a[:3], b[:3]))

def find_scheme(name):
    if not name or not re.fullmatch(r'[\w .-]+', name):
        return None
    roots = [Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share'))]
    roots += [Path(p) for p in os.environ.get('XDG_DATA_DIRS', '/usr/local/share:/usr/share').split(':') if p]
    return next((p for base in roots if (p := base / 'color-schemes' / (name + '.colors')).is_file()), None)

def load_colors(path):
    path = Path(path)
    current = read_ini(path)
    defaults = path.parent / 'kdedefaults/kdeglobals'
    default_config = read_ini(defaults) if defaults.is_file() else configparser.ConfigParser(interpolation=None)
    scheme = current.get('General', 'ColorScheme', fallback=default_config.get('General', 'ColorScheme', fallback=''))
    merged = configparser.ConfigParser(interpolation=None, strict=False)
    merged.optionxform = str
    if defaults.is_file():
        merged.read(defaults)
    selected = find_scheme(scheme)
    if selected:
        selected_config = read_ini(selected)
        # Older complete schemes (including Catppuccin) omit Header. Do not
        # retain an unrelated desktop-default Header in the selected scheme.
        if selected_config.has_section('Colors:Window') and not selected_config.has_section('Colors:Header'):
            merged.remove_section('Colors:Header')
        merged.read(selected)
    # An anonymous current palette may override every role without naming its
    # scheme. Its Header must not come from the inferred desktop-default file.
    if not current.get('General', 'ColorScheme', fallback='') and current.has_section('Colors:Window'):
        merged.remove_section('Colors:Header')
    for section in current.sections():
        if not merged.has_section(section):
            merged.add_section(section)
        for key, value in current.items(section):
            merged.set(section, key, value)
    # Fallbacks are KDE Breeze Dark roles, not dependencies on palette.css.
    base = {
        'Window': (32,35,38), 'View': (20,22,24), 'Button': (41,44,48),
        'Selection': (61,174,233), 'Tooltip': (41,44,48), 'Header': (41,44,48),
    }
    result = {}
    for name, background in base.items():
        section = 'Colors:' + name
        fallback = {
            'BackgroundNormal': background,
            'BackgroundAlternate': (29,31,34) if name == 'View' else (30,87,116) if name == 'Selection' else (41,44,48),
            'ForegroundNormal': (252,252,252), 'ForegroundInactive': (161,169,177),
            'ForegroundActive': (61,174,233), 'ForegroundLink': (29,153,243),
            'ForegroundVisited': (155,89,182), 'ForegroundNegative': (218,68,83),
            'ForegroundNeutral': (246,116,0), 'ForegroundPositive': (39,174,96),
            'DecorationFocus': (61,174,233), 'DecorationHover': (61,174,233),
        }
        if name == 'Header':
            fallback = result['Window'].copy()
        result[name] = {key: rgb(merged.get(section, key)) if merged.has_option(section, key) else value for key, value in fallback.items()}
    return result

def generate(path):
    c = load_colors(path)
    w,v,b,s,t,h = [c[k] for k in ('Window','View','Button','Selection','Tooltip','Header')]
    wb,vb,bb,sb = [x['BackgroundNormal'] for x in (w,v,b,s)]
    wf,vf,bf,sf = [x['ForegroundNormal'] for x in (w,v,b,s)]
    border = mix(wb,wf,.20)
    values = {
        'view-bg':vb, 'tabstrip-bg':h['BackgroundNormal'], 'treeheader-bg':h['BackgroundNormal'],
        'sidebar-dark':w['BackgroundAlternate'], 'zebra-odd':v['BackgroundAlternate'],
        'tab-bg':wb, 'popup-bg':wb, 'alt-view-bg':v['BackgroundAlternate'],
        'card-border':mix(wb,wf,.16), 'window-bg':wb, 'header-hover':mix(h['BackgroundNormal'],h['DecorationHover'],.16),
        'accent-fg':sf, 'editor-bg':vb, 'input-hover':mix(vb,v['DecorationHover'],.08),
        'deep-accent':s['BackgroundAlternate'], 'tab-hover':mix(wb,w['DecorationHover'],.16),
        'positive':w['ForegroundPositive'], 'tab-border':mix(wb,wf,.16), 'button-bg':bb,
        'btn-primary':sb, 'toggle-on-bg':mix(bb,sb,.55), 'toggle-off-bg':mix(bb,bf,.18),
        'cyan':v['ForegroundActive'], 'button-border':mix(bb,bf,.24), 'col-divider':mix(wb,wf,.14),
        'green':v['ForegroundPositive'], 'groove-sep':mix(wb,wf,.16), 'border-dark':border,
        'blue-accent':sb, 'dialog-border':mix(wb,wf,.32), 'scrollbar-thumb':mix(bb,bf,.30),
        'blue-light':mix(sb,sf,.15), 'icon-muted':mix(wb,wf,.40),
        'green-light':mix(v['ForegroundPositive'],vf,.15), 'blue-focus':v['DecorationFocus'],
        'comment':v['ForegroundInactive'], 'text-dim':w['ForegroundInactive'], 'purple':v['ForegroundVisited'],
        'negative':w['ForegroundNegative'], 'orange':w['ForegroundNeutral'], 'text-main':wf,
        'yellow':v['ForegroundNeutral'], 'white':wf, 'link':v['ForegroundLink'],
        'link-visited':v['ForegroundVisited'], 'neutral':w['ForegroundNeutral'],
    }
    declarations = { '--palette-'+key:css(value) for key,value in values.items() }
    # Alpha variants derive from the live role colors, never the theme's blue literal.
    for family, color, amounts in [
        ('black',(0,0,0),(25,35,45,50,55,65)),
        ('white',wf,(10,12)), ('red',w['ForegroundNegative'],(25,)),
        ('green',v['ForegroundPositive'],(55,)),
        ('blue',sb,(12,14,16,18,20,22,24,25,26,28,30,35,38,40,45,50,55,65,75,85)),
    ]:
        for amount in amounts:
            declarations[f'--palette-alpha-{family}-{amount}'] = f'rgba({color[0]}, {color[1]}, {color[2]}, {amount / 100:g})'
    aliases = {
        'window-bg':css(wb), 'window-bg-alt':css(w['BackgroundAlternate']), 'window-fg':css(wf),
        'window-fg-inactive':css(w['ForegroundInactive']), 'view-bg':css(vb),
        'view-bg-alt':css(v['BackgroundAlternate']), 'view-fg':css(vf), 'view-fg-inactive':css(v['ForegroundInactive']),
        'button-bg':css(bb), 'button-fg':css(bf), 'selection-bg':css(sb), 'selection-fg':css(sf),
        'selection-hover':'var(--palette-alpha-blue-25)', 'selection-card':'var(--palette-alpha-blue-22)',
        'tooltip-bg':css(t['BackgroundNormal']), 'tooltip-fg':css(t['ForegroundNormal']),
        'accent':css(v['DecorationFocus']), 'accent-fg':css(sf), 'deco-hover':css(w['DecorationHover']),
        'link':css(v['ForegroundLink']), 'link-visited':css(v['ForegroundVisited']),
        'negative':css(w['ForegroundNegative']), 'neutral':css(w['ForegroundNeutral']), 'positive':css(w['ForegroundPositive']),
        'border-color':css(border), 'border-color-subtle':css(mix(wb,wf,.16)),
        'hover-bg':'var(--palette-alpha-blue-16)', 'active-bg':css(sb), 'btn-primary-bg':css(sb), 'btn-primary-hover':css(sb),
    }
    declarations.update({'--kde-'+key:value for key,value in aliases.items()})
    declarations.update({
        '--breeze-sidebar-hover-bg':css(s['BackgroundAlternate']),
        '--breeze-sidebar-hover-border':css(s['DecorationHover']),
        '--breeze-sidebar-selected-bg':css(sb), '--breeze-sidebar-selected-border':css(sb),
        '--breeze-sidebar-selected-fg':css(sf), '--breeze-action-active-fg':css(sf),
        '--sync-selection-fg':css(sf),
        '--sync-tooltip-bg':css(t['BackgroundNormal']), '--sync-tooltip-fg':css(t['ForegroundNormal']),
    })
    dark = sum(x * weight for x,weight in zip(vb[:3],(.2126,.7152,.0722))) < 128
    lines = ['/* Generated from KDE color roles by helpers/kde_palette.py.',
             '   Independent of palette.css. Enable the Boolean colour-sync in about:config.',
             '   Regenerate after KDE changes; restart Firefox to reload changed CSS files. */',
             '@media -moz-pref("colour-sync") {', ':root, :host {',
             '  color-scheme: '+('dark' if dark else 'light')+' !important;']
    lines += [f'  {key}: {value} !important;' for key,value in declarations.items()]
    lines += ['}', '}', '']
    return '\n'.join(lines)

def atomic_write(path, text):
    path = Path(path)
    if path.is_file() and path.read_text() == text:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix='.'+path.name+'-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(text)
        os.chmod(temporary, 0o644)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):os.unlink(temporary)

def quote_unit(value):
    value = str(value)
    if '\n' in value or '\r' in value:raise ValueError('Newlines are not allowed in service paths.')
    return '"'+value.replace('\\','\\\\').replace('"','\\"').replace('%','%%').replace('$','$$')+'"'

def unit_path(value):
    # Path directives consume the entire literal value; unlike ExecStart they
    # do not strip quotes. Internal spaces are supported without quoting.
    value = str(Path(value).resolve())
    if '\n' in value or '\r' in value:raise ValueError('Newlines are not allowed in service paths.')
    return value.replace('%', '%%')

def registry_path():
    return config_home() / 'firefox-breeze-theme/colour-sync.json'

def ensure_colour_sync_pref(profile):
    """Register a missing Boolean once; preserve all existing saved choices.

    Append to the open inode rather than replacing Firefox's preference file.
    If Firefox replaces it concurrently, the existing path watcher retries on
    the new inode. Never modify user.js or log the contents of prefs.js.
    """
    path = Path(profile) / 'prefs.js'
    flags = os.O_RDWR | os.O_CREAT | os.O_APPEND | getattr(os, 'O_NOFOLLOW', 0)
    fd = os.open(path, flags, 0o600)
    with os.fdopen(fd, 'a+b') as stream:
        stream.seek(0)
        saved = stream.read()
        pattern = rb'^\s*user_pref\(\s*["\']colour-sync["\']\s*,'
        if re.search(pattern, saved, re.M):
            return False
        prefix = b'' if not saved or saved.endswith(b'\n') else b'\n'
        stream.write(prefix + b'user_pref("colour-sync", false);\n')
        stream.flush()
    return True

def refresh(registry):
    data = json.loads(Path(registry).read_text())
    source = Path(data['theme_root'])
    targets = []
    for profile in data['profiles']:
        target = Path(profile) / 'chrome'
        # Uninstalled/deleted profiles must not be recreated by a stale watcher.
        if (target / 'userChrome.css').is_file():
            ensure_colour_sync_pref(profile)
            targets.append(target / 'palette-sync.css')
    if not Path(data['kdeglobals']).is_file():
        return
    palette = generate(data['kdeglobals'])
    atomic_write(source / 'palette-sync.css', palette)
    for target in targets:
        atomic_write(target, palette)

def systemctl(*args):
    return subprocess.run(['systemctl','--user',*args], text=True, capture_output=True)

def register(theme_root, profiles, kdeglobals):
    theme_root, kdeglobals = Path(theme_root).resolve(), Path(kdeglobals).resolve()
    registry = registry_path()
    data = json.loads(registry.read_text()) if registry.is_file() else {'profiles':[]}
    data.update(theme_root=str(theme_root.resolve()), kdeglobals=str(kdeglobals.resolve()))
    data['profiles'] = sorted(set(data['profiles']) | {str(p.resolve()) for p in profiles})
    atomic_write(registry, json.dumps(data,indent=2)+'\n')
    directory = config_home()/'systemd/user';directory.mkdir(parents=True,exist_ok=True)
    command = ' '.join(map(quote_unit,[sys.executable,str(theme_root/'helpers/kde_palette.py'),'--refresh-registry',str(registry)]))
    atomic_write(directory/(UNIT+'.service'), '[Unit]\nDescription=Refresh Firefox KDE colors and register colour-sync\nStartLimitIntervalSec=0\n[Service]\nType=oneshot\nExecStart='+command+'\n[Install]\nWantedBy=default.target\n')
    watched_paths = [kdeglobals] + [Path(p) / 'prefs.js' for p in data['profiles']]
    path_settings = ''.join('PathChanged=' + unit_path(p) + '\n' for p in watched_paths)
    atomic_write(directory/(UNIT+'.path'), '[Unit]\nDescription=Watch KDE colors and Firefox preference registration\n[Path]\n'+path_settings+'Unit='+UNIT+'.service\n[Install]\nWantedBy=default.target\n')
    if shutil.which('systemctl'):
        reload = systemctl('daemon-reload')
        enable = systemctl('enable','--now',UNIT+'.path',UNIT+'.service') if reload.returncode == 0 else reload
        if enable.returncode == 0:
            enable = systemctl('restart', UNIT+'.path')
        if enable.returncode == 0:
            print('KDE palette watcher enabled for this user.')
            return
        print('KDE watcher files installed, but activation failed: '+enable.stderr.strip(),file=sys.stderr)
    else:print('KDE watcher files installed; systemctl is unavailable.',file=sys.stderr)

def unregister(profiles):
    registry=registry_path()
    if not registry.is_file():return
    data=json.loads(registry.read_text());removed={str(p.resolve()) for p in profiles}
    remaining=[p for p in data['profiles'] if p not in removed]
    if remaining==data['profiles']:return
    if remaining:
        data['profiles']=remaining;atomic_write(registry,json.dumps(data,indent=2)+'\n')
        register(Path(data['theme_root']), [], Path(data['kdeglobals']))
        return
    if shutil.which('systemctl'):systemctl('disable','--now',UNIT+'.path',UNIT+'.service')
    for suffix in ('.path','.service'):(config_home()/'systemd/user'/(UNIT+suffix)).unlink(missing_ok=True)
    registry.unlink()
    if shutil.which('systemctl'):systemctl('daemon-reload')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kdeglobals',type=Path,default=config_home()/'kdeglobals')
    parser.add_argument('--output',type=Path,action='append',default=[])
    parser.add_argument('--theme-root',type=Path)
    parser.add_argument('--profile',type=Path,action='append',default=[])
    parser.add_argument('--watch',action='store_true')
    parser.add_argument('--unregister',action='store_true')
    parser.add_argument('--refresh-registry',type=Path)
    args=parser.parse_args()
    try:
        if args.unregister:unregister(args.profile);return
        if args.refresh_registry:refresh(args.refresh_registry);return
        for profile in args.profile:
            ensure_colour_sync_pref(profile)
        if not args.kdeglobals.is_file():
            if args.theme_root:
                print('No kdeglobals found; installed palette snapshot retained.')
                if args.watch:register(args.theme_root,args.profile,args.kdeglobals)
                return
            parser.error('KDE palette does not exist: '+str(args.kdeglobals))
        outputs=args.output[:]
        if args.theme_root:outputs.append(args.theme_root/'palette-sync.css')
        outputs += [p/'chrome/palette-sync.css' for p in args.profile]
        if not outputs:parser.error('Pass --output or --theme-root/--profile.')
        text=generate(args.kdeglobals)
        for target in outputs:atomic_write(target,text)
        print('KDE palette generated for '+str(len(outputs))+' stylesheet(s).')
        if args.watch:
            if not args.theme_root:parser.error('--watch needs --theme-root.')
            register(args.theme_root,args.profile,args.kdeglobals)
    except (OSError,ValueError,configparser.Error) as error:parser.exit(1,'Palette sync: '+str(error)+'\n')

if __name__=='__main__':main()
