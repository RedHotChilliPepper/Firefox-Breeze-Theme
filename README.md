# Firefox Qt6 Breeze Theme (KDE Plasma 6 Dolphin Aesthetic)

A complete UI and UX theme for Mozilla Firefox replicating the native KDE Plasma 6 **Qt6 Breeze** design language as showcased in KDE Dolphin and KDE System Settings.

This theme goes far beyond basic color tweaks by recreating authentic Qt6 Breeze UI components, spatial density, interaction states, and icon sets.

---

## Visual & UX Alignment with KDE Dolphin References

### 1. Navigation & Header Toolbar (Dolphin Reference)
* **Grouped Navigation Buttons:** The Back `<` and Forward `>` buttons are unified into a contiguous button group with shared borders and 4px rounding on outer corners, just like Dolphin's navigation cluster.
* **Flat Breeze Action Buttons:** 4px border-radius, transparent resting border, subtle hover outline (`rgba(61, 174, 233, 0.5)`), and active/pressed fill with Breeze Blue (`#3daee9`).
* **Official Breeze SVGs:** Navigation, reload, home, hamburger menu (`application-menu.svg`), extensions (`plugins.svg`), downloads, and bookmarks all use the native KDE Breeze vector icons.

### 2. Location / Address Bar (Dolphin Path Bar UX)
* **Docked Compact Geometry:** Sits at native 30px height with 4px border radius and dark view background (`#141618`).
* **No Megabar Bloat:** Disables the oversized expanding balloon popup when focused, preserving toolbar spacing.
* **Breeze Focus Glow:** On focus, displays the signature 1px solid Breeze Blue (`#3daee9`) border with a 4px soft outer blue glow (`box-shadow: 0 0 0 1px #3daee9, 0 0 4px rgba(61, 174, 233, 0.45)`).
* **Dropdown Results:** Clean flush popup panel with Breeze card highlights on hover and selection (`rgba(61, 174, 233, 0.25)`).

### 3. Tabs & Tab Strip (Qt6 Breeze Tab Bar)
* **Attached Tabs:** Replaces detached floating Proton pills with attached tabs seamlessly docked to the navigation bar.
* **Inactive Tab Separators:** Vertical 1px subtle divider lines (`rgba(255, 255, 255, 0.12)`) separating inactive tabs, identical to Qt Breeze tab bars.
* **Active Tab Accent:** Docked flush into the toolbar below, styled with a vibrant 2px top Breeze Blue accent line (`border-top: 2px solid #3daee9`) and 1px border.
* **Tab Controls:** Breeze `window-close.svg` that highlights in Breeze Red (`#da4453`) on hover, and compact `list-add.svg` for new tabs.

### 4. Places Sidebar & No-Dotted-Lines Standard (Dolphin "Places" Reference)
* **Zero Dotted Focus/Selection Lines:** All browser-default dotted focus rings (`1px dotted`, `--default-focusring`, `treechildren::-moz-tree-row(current, focus)`) and dotted tree hierarchy connector lines (`::-moz-tree-line`) are globally removed across Chrome, Content, Library, and Subdialogs.
* **Dolphin Places Selection Card:** Selected sidebar/tree items (`#placesList`, `.sidebar-placesTree`, `.category[selected]`) use a smooth `5px`-radius translucent Breeze Blue card (`background: rgba(61, 174, 233, 0.26); border: 1px solid rgba(61, 174, 233, 0.55); outline: none`), matching KDE Dolphin's `Downloads` selection in the Places panel.
* **Single-Divider Sidebar Geometry:** `about:preferences` and `about:addons` enforce a single `1px solid #31363b` divider and single `8px` outer padding on `#sidebar` (suppressing inner `<moz-page-nav>` host borders/padding).

### 5. Tables, Columns & Multi-Column Trees Standard (Dolphin "Details" View Reference)
* **Compact Column Header Bar:** Multi-column tables and trees (`#placeContent` in Library, `#device_tree` in Device Manager, Certificate Manager, Exceptions) use a `26px` `#181a1d` header bar with `#a1a9b1` text (`#fcfcfc` on `#222529` hover) and subtle `1px solid #2d3136` column dividers. Hidden single-column headers (`treecol[hideheader="true"]`) are collapsed completely.
* **Alternating Zebra Rows & 5px Selection:** `28px` rows alternate between `#141618` (even) and `#1a1d20` (odd), with a `5px` rounded Breeze Blue row highlight on hover (`rgba(61, 174, 233, 0.14)`) and selection (`rgba(61, 174, 233, 0.24)` fill + `1px solid rgba(61, 174, 233, 0.85)` border).

### 6. Status Badge ("Eine Datei (50 B)" Reference)
* The bottom-left link hover status tooltip is styled as an authentic Breeze docked badge (`#292c30`, 1px border, 4px radius, 11px font).

### 7. Popups, Subdialogs & Menus: 8px Corner & Padding Standard
* **8px Rounded Corners (`--breeze-menu-radius: 8px`):** All floating context menus (`menupopup`), arrow panels, `<panel-list>` dropdowns, modal subdialogs (`.dialogBox`, `html|dialog`), profile cards (`.profile-card`), and DevTools doorhanger panels (`.tooltip-panel`) use an `8px` outer border-radius on a `#1c1f22` / `#202326` surface with `0.14s–0.15s cubic-bezier(0.22, 1, 0.36, 1)` fade-in/out transitions.
* **One flush subdialog shell — `reference1.png`:** The rounded outer `.dialogBox` has one border and **zero content padding**. Its embedded browser has zero margin/padding; document roots and embedded dialogs never draw a second rounded frame, border or shadow. Apply `16px 20px` **once to the form body**, keeping the existing header type. No inset dark band or card inside another card. Preserve native intrinsic sizing and content scrolling so the entire form and action buttons remain reachable. Use consistent `5px–8px` row rhythm, `1px solid #31363b` groove separators (`12px` vertical margin), and unboxed inner form-layout groupboxes (`#FontsDialog`, `#changemp`).

### 8. In-Content Settings, Subdialogs, Library, Print, PDF.js, DevTools & View Source
Applies the General Style Language (GSL) across all internal Firefox pages and windows:
* **Settings, Add-ons & Profile Selector (`about:preferences`, `about:addons`, `about:keyboard`, `profiles.html`):** Single-box `<moz-button>`, `<moz-select>`, `<moz-input-search>`, and `<moz-input-folder>` controls (preserving `34px` icon-safe start padding), reference-style `<moz-toggle>` switches as specified below, and CSP-safe `chrome://global/skin/icons/check.svg` white checkmarks on `<moz-checkbox>`.
* **Subdialogs & Modal Windows:** Unified `#202326` dialog cards (`8px` radius) with `#141618` inputs/trees across Primary Password (`changemp.xhtml`), Fonts (`fonts.xhtml`), Permissions, Enhanced Tracking Protection Exceptions, Clear Browsing Data, Manage Cookies, Connection Settings, Certificate Manager, Device Manager, Add Card / Add Address, and About Firefox.
* **Library Window (`places.xhtml`), Print Preview (`print.html`), & PDF Viewer (`PDF.js`):** Compact `34px` `#placesToolbar`, unboxed `<moz-input-search id="searchFilter">` host (preventing double search boxes), Dolphin Places sidebar, Dolphin Details content table, and full Print/PDF.js theming.
* **Web Developer Tools, Parent Process Browser Console & View Page Source (`view-source:`):** Full Breeze Dark DevTools theme, Dolphin-styled `8px` doorhanger settings menus, and KDE Kate / KSyntaxHighlighting Breeze Dark syntax coloring for `view-source:`.

### 9. Switches — `ref 2 active.png`, `ref 3 deactive.png`, `ref 4 hovering over switch.png`
* **One switch design everywhere:** Settings, Add-ons, new-tab customization, browser popups, VPN, and internal dialogs use a `34×12px` rounded track with an `18×18px` circular thumb that overhangs the track vertically by `3px`. This replaces the earlier contained pill-switch specification.
* **Reference colors:** The thumb stays dark `#292c30` in both states, with a `1px #4c4e51` outline. The enabled track uses muted blue `#3e7797` with a `1px #3daee9` border; the unchecked track uses gray `#3e4144` with a muted gray border. The thumb moves `16px`, reverses direction for RTL, and is never clipped by the track. Preserve Firefox's label/input positioning margins.
* **State fidelity:** The checked track must be blue and the unchecked track gray; hovering outlines both the track and the dark thumb in Breeze Blue without changing the checked state. Disabled controls retain their native dimming. Track geometry selectors must not have greater specificity than the checked/hover selectors.

### 10. Feature Showcase Panels — VPN and Similar Onboarding Popups
* **Single outer shell:** One `8px` rounded `#202326` surface with one `1px #3a3f44` border. Only the popup content shell paints the frame; its host and internal layout wrappers stay transparent and unboxed. Use `16px 20px` outer padding, `8px–12px` content spacing, and the existing GSL popup fade timing.
* **Content hierarchy:** Compact `14px` header, subdued `12px` status badge, centered illustration without an extra frame, `18px` semibold heading, and `13px` body text with `1.45` line-height. Benefit rows reserve `16px` for an icon plus an `8px` gap. Keep the illustration's artwork colors.
* **One visible action button:** A `4px` rounded, at least `32px` high primary action uses `#2980b9`, a Breeze Blue border and white text; hover uses `#3daee9`. For `<moz-button>`, its inner `.button-background` owns this single frame. The host has no background, border, shadow, or duplicate padding. Settings/navigation actions remain secondary or ghost controls.
* **Footer:** Muted `12px` text, blue links, centered alignment and `12px` top spacing. No extra enclosing card or button frame.

### 11. Icon-Safe Dropdown Rows and Continuous Page Canvases
* **Dropdown families:** All `<panel-item>` rows reserve `34px` of inline-start text space, including rows whose icon comes from `--panel-item-icon` rather than an `[icon]` attribute. Draw `16px` icons at an `8px` inset; reverse the inset for RTL. XUL menu icons occupy a separate `16px` layout slot followed by an `8px` gap. Icons must never be positioned over their label.
* **Backup folder fields:** Both recommended/default and custom backup locations reserve `34px` of start padding for their `16px` icon at a `10px` inset. Match the current `.backup-location-filepicker-input` family so the filename never begins underneath the icon.
* **Translations canvas:** `about:translations` uses the same `#202326` background across the document root, body, heading surround and unused viewport. Editing panes keep their contrasting `#141618` background.

### 12. Popup Forms and Site Information — Bookmark Reference (`reference 1.png`)
* Translation popups use the bookmark dialog's `8px` `#202326` shell, a compact semibold header with a single groove divider, and `12px 16px` content insets. Native language dropdowns have one `4px` rounded `#292c30` frame with a `#3a3f44` border and `32px` height. Footer buttons have `4px` corners, `30px` minimum height, `8px` spacing, a neutral Cancel action and a Breeze Blue primary action. Footer and header separators use `#31363b`.

* Site permission, connection/identity and tracking protection panels follow the same bookmark shell, header and form-control geometry. Only the content part draws the outer frame; the panel host stays unboxed. Use a `380px` maximum content width, `12px 16px` content insets, thin groove separators, neutral `32px` dropdowns and one hover highlight per action. Site-info summary cards use `#141618`, a gray border and `4px` corners; preserve the security artwork and native warning/state visibility.

* **Inline information cards:** Spellcheck and similar `<moz-promo>` fields use one `4px` rounded `#1c1f22` surface with a `1px #3a3f44` border, `12px 16px` text insets, a `14px` semibold heading and subdued `13px/1.45` body text. Preserve the illustration artwork. Style the actual shadow content and tokens without adding a second frame on the host.

### 13. One Highlight Layer for Icon Actions
* Toolbar, address-bar, popup, zoom, and expander actions paint their hover/selected blue marker once, on the actionable outer control. Inner icon boxes, image wrappers, and dropmarker containers remain transparent, borderless and shadowless. No nested gray disc or second tinted rectangle may appear behind a glyph. Preserve the icon artwork and notification badges.

### 14. Native Menu Selection Markers — `ref5.png`
* Checkbox/radio menu entries retain their native icon slot even when no image source is set. Render the slot as a `16px` circular marker with a thin gray border; checked entries use a Breeze Blue border and centered blue dot. Hover uses a blue outline. Do not hide semantic selection markers with the empty decorative-icon rule.

### 15. Picture-in-Picture — Solid Dragon Player Reference
* **Opaque controls:** PiP follows the Dragon Player reference's compact, centered bottom control dock. Use a solid `#141618` dock with a `1px #3a3f44` border, `8px` corners and compact spacing. Replace the full-width video gradient and translucent overlays with this single solid dock. Keep the video image, aspect ratio, playback behavior and the window's drag/resize behavior intact; the reference's black video area is not a required background color.
* **Buttons:** Playback, volume, captions and fullscreen controls use white glyphs, `4px` corners and `28px` targets (`24px` in small windows). Their resting surface matches the solid dock; hover uses solid `#31363b` with a Breeze Blue border, and pressed/expanded controls use solid `#3daee9`. Return-to-tab and Close use solid `#292c30` surfaces; Close hovers red. No partially transparent controls, nested gray highlights or black glyphs on dark controls.
* **Seek icon scale:** The native five-second seek SVGs have extra viewport padding. Render their backgrounds at `32px` so the visible arrows match the other playback glyphs, while keeping the existing button targets and centered alignment.
* **Sliders and text:** Balance progress, volume and time with the playback glyphs: solid `6px #31363b` range tracks, Breeze Blue progress, `16px` dark circular thumbs with a gray border and blue hover/focus outlines, and `14px` timestamps. Range hit areas and timestamp line-height match the `28px` button targets. Small windows use `5px` tracks, `14px` thumbs, `12px` timestamps and `24px` targets. Preserve native keyboard seeking, media state icons and responsive control hiding.
* **Settings, tooltips and captions:** Use opaque `#202326` settings cards with one `8px` outer border, unboxed inner fieldsets, and GSL switches/radios. Tooltips and caption backplates use solid `#1c1f22` surfaces, white text and `4px` corners. Disabled controls use solid muted colors instead of reduced opacity.
* **Visibility:** Native auto-hide may hide the entire dock and top actions; visible controls are fully opaque. PiP uses whole-surface visibility changes instead of opacity ramps, and disables see-through video dimming/blur.

### 16. Page Information and Form Radios — `reference 2.png`
* **Page Information:** General, Media, Permissions and Security use the Breeze reference's `#202326` window surround and a single `#1c1f22` content frame. Inactive tabs use `#1b1d20`; the selected tab joins the content frame with a `2px` blue top accent. Keep `16px 20px` content padding, GSL tables, neutral buttons and unboxed metadata/security groups. Native media previews and image documents use a solid `#1c1f22` canvas instead of Firefox's noise texture. Permissions use a `#141618` list with one gray frame, `4px` corners, `10px 12px` rows and solid `#31363b` separators. Preserve scrolling of the permission list and all native permission/default controls.
* **Radio geometry and states:** HTML, XUL and `<moz-radio>` form controls use an `18px` circle with a thin `1px #535659` outline and dark `#141618` center. Checked controls use a `#3daee9` outline and a separate centered `8px` blue dot, leaving a dark gap inside the ring. Hover and keyboard focus outline the circle blue. Disabled options retain a muted gray ring/dot and their native disabled behavior. Do not apply the form marker to navigation tabs or change the custom element's input/label positioning.

* **Checkboxes — Breeze settings reference:** Use an `18px` box, `3px` corners, a thin gray border and a solid `#292c30` unchecked surface. Checked boxes use muted blue `#3e7797`, a `#3daee9` outline and a centered white checkmark. Disabled boxes retain a visible muted checkmark.
* **Native boolean states:** XUL checkbox/radio/tab rules match the presence of `[checked]`, `[selected]` and `[focused]`; Firefox can serialize these attributes with an empty value. Checked, selected and disabled states must remain distinguishable after native appearance is removed.
* **Tracking-protection confirmations — `reference2.png`:** Subviews use their parent panel's solid shell, divided compact header, `12px 16px` body padding and a separated footer. Cancel uses a neutral gray button and Delete uses the GSL blue primary button, both `32px` high with `4px` corners and `8px` spacing. Size the view to its contents instead of retaining a large empty area from the parent view.

---

## Project Structure

```
firefox-qt6-breeze-theme/
├── components/               # Modular functional CSS components
│   ├── base.css              # Tokens, variables, scrollbars & no-dotted-lines
│   ├── titlebar.css          # Window titlebar, non-CSD clean-up & CSD buttons
│   ├── tabs.css              # Tabs, tab strip, containers & close/newtab buttons
│   ├── toolbars.css          # Navigation & bookmarks toolbars & action buttons
│   ├── urlbar.css            # Address bar, search dropdown & search engines
│   ├── popups.css            # Menus, dropdowns, hamburger & micro-animations
│   ├── sidebar.css           # Dolphin Places sidebar & vertical launcher
│   ├── findbar.css           # In-page Ctrl+F search bar
│   ├── dialogs.css           # Modal dialogs & in-content subdialogs
│   ├── bookmarks-dialog.css  # Add/Edit Bookmark popup panel
│   ├── downloads-dialog.css  # Downloads panel & listbox
│   ├── library.css           # Places Library window (places.xhtml) & tables
│   ├── settings.css          # In-content settings entry & base layout
│   ├── settings-nav.css      # Settings & Add-ons left navigation sidebar
│   ├── settings-cards.css    # Settings cards, promos, box-groups & pickers
│   ├── settings-controls.css # Form controls (buttons, inputs, toggles, dropdowns)
│   ├── settings-pages.css    # Profile selector, keybinds & customize toolbar
│   ├── newtab.css            # New tab & private browsing new tab pages
│   ├── devtools.css          # Developer Tools & browser console
│   ├── view-source.css       # Syntax highlighting for view-source:
│   ├── pdf-print.css         # Print preview & PDF.js viewer
│   ├── picture-in-picture.css # Opaque PiP dock, controls, settings & captions
│   └── icons/                # Official KDE Breeze SVGs
│       ├── back.svg, forward.svg, reload.svg, stop.svg
│       ├── menu.svg, plugins.svg, download.svg, star.svg
│       ├── newtab.svg, close.svg, lock.svg, folder.svg, vpn.svg
│       └── titlebutton-*.svg # CSD Breeze titlebar buttons
├── palette.css               # Central color palette (defines all colors once, zero duplicates)
├── breeze-icons.css          # SVG icon mappings for toolbars
├── kde-colors.css            # Legacy compatibility palette mapping
├── kde-colors-content.css    # Legacy compatibility content mapping
├── userChrome.css            # Firefox Chrome entry point
├── userContent.css           # Firefox Content entry point
├── breeze-theme.css          # Aggregator for chrome components
├── breeze-content.css        # Aggregator for content components
├── install.sh                # Automated installer and uninstaller
└── README.md
```

---

## Installation & Management

The theme is already installed in your active Firefox profile. To reinstall, update, or remove:

```bash
# Run installer (automatically detects profile)
./install.sh

# Target a specific profile directory
./install.sh --profile ~/.config/mozilla/firefox/pf2xhvwe.default-release

# Uninstall and restore default styling
./install.sh --uninstall
```

After installing or updating, restart Firefox for changes to take effect.
