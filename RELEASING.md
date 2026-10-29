# Preparing a GitHub release

## Before publishing

1. Review the README and release notes, including architecture and unsigned-build disclosures.
2. Keep the implementation in a private repository. Publish only download documentation, LICENSE, and release assets in the public download repository. Public GitHub repositories permit viewing and forking under GitHub’s terms, even with a restrictive license. Do not publish implementation source or change repository visibility without the owner’s authorization.
3. Build with `bash scripts/package.sh` and test the resulting app installed in Applications.
4. Test a browser-downloaded copy on a second Apple silicon Mac if possible. Local launch does not test Gatekeeper’s downloaded-file checks. Verify permission denial, permission grant, Start, countdown cancellation, Stop, global stop, interval validation, and quitting while clicking.
5. Review and commit the source, icon, package manifest, documentation, and packaging script. Keep `dist/` and `.build/` out of Git.

## GitHub Releases

1. Confirm which repository will hold private source and which will host public downloads. The current remote is `https://github.com/sloanagx/autoclick-mac`; do not push source there until its intended visibility is confirmed. Keep the release source commit recorded in the private repository.
2. In the public download repository, open Releases → Draft a new release. Create tag `v1.0.0` at the release documentation commit.
3. Use title `AGX Auto Clicker 1.0.0 — Beta` and paste `RELEASE_NOTES.md` as the description.
4. Attach only the intended DMG and `SHA256SUMS.txt` from `dist/`. GitHub’s automatic source archives do not contain an installable app.
5. Select **Set as a pre-release**. Review the draft, then publish it when ready.

The initial release uses ad-hoc signing. A paid Apple Developer membership is required for Developer ID signing and Apple notarization, not for publishing a GitHub release. See https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution for that later workflow.

The current installer is built for the host architecture. Do not describe it as universal. Use a separate verified x86_64 build or a tested universal build before claiming Intel support.
