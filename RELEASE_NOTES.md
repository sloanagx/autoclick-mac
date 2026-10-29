# AGX Auto Clicker 1.0.0 — Beta

First public beta of AGX Auto Clicker for macOS, developed by AGX.

Copyright © 2026 AGX. All rights reserved. Use of unmodified official releases is permitted. Modification and redistribution require written permission, subject to applicable law and hosting-platform terms. Share the official release link instead of rehosting the installer. See the accompanying LICENSE for full terms.

- Native interface with the custom AGX cursor icon.
- Repeated left clicks at the current cursor position.
- Adjustable interval: 0.05–3600 seconds.
- Three-second starting countdown and a clicks-sent counter.
- Stop button and Command–Shift–S stop shortcut.
- DMG with drag-to-Applications installation.

## Requirements and installation

**Apple silicon Mac (M1 or newer), macOS 14 or newer.** Tested locally on macOS 27.2. Intel builds are not included.

Download `AGX-Auto-Clicker-1.0.0-arm64.dmg`, open it, and drag the app into Applications. Enable the installed app under System Settings → Privacy & Security → Accessibility, then quit and reopen it.

**This beta has no Developer ID signature or Apple notarization.** macOS may block it on first launch. If you trust the source, review [Apple’s instructions](https://support.apple.com/102445) for approving an unidentified developer app. Approval may be unavailable on managed Macs.

## Known limitations

- Left clicks only; no fixed-position mode or automatic click limit.
- Shortcut may also reach the foreground app and may conflict with other shortcuts or secure keyboard input.
- Timing is approximate; the counter measures events sent.
- Accessibility permission may need to be granted again after an update.

Download `SHA256SUMS.txt` to check the installer’s integrity. With both files in the same folder, run:

```sh
shasum -a 256 -c SHA256SUMS.txt
```

A matching checksum confirms file integrity, not Apple verification.
