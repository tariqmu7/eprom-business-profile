# EPROM Business Profile 2026

The public home of the EPROM business profile — a single self-contained HTML file
(12 service categories, 49 service modules, scope-sheet builder, printable).

**Read it online:** https://tariqmu7.github.io/eprom-business-profile/

## Why this repo exists

The profile is sent to clients as one file by e-mail or WhatsApp. Every recipient
therefore keeps a frozen copy. This repo is the one place that says what the
current version is, so those frozen copies can catch up:

* the file carries its own version stamp in two `<meta>` tags,
* on each open — **only if there is internet** — it fetches `version.json` here,
* if a newer version is published it offers **Update now** (the page refreshes
  itself in place) and **Save updated file** (downloads the new HTML so the
  recipient's offline copy is current too),
* offline, or already current, nothing appears and the document works normally.
  The reader's scope-sheet selection and theme survive an update.

There is also a **Check for updates** link in the page footer, next to the version.

## Publishing a new version

1. Edit the deliverable in `BD\EPROM Business Profile\1_Final_Deliverables\`.
2. Bump **both** tags in its `<head>`:

   ```html
   <meta name="profile-version"  content="2026.08.15-1">
   <meta name="profile-released" content="15 August 2026">
   ```

3. Run:

   ```powershell
   .\publish.ps1 -Notes "What changed"
   ```

`publish.ps1` copies the file to `index.html`, derives `version.json` from those
tags (so the manifest can never contradict the file), commits and pushes. It
refuses to publish twice under the same version string.

Recipients see the update the next time they open their copy online. GitHub's raw
CDN caches for a few minutes, so allow ~5 minutes before testing.

## Files

| File | What it is |
|---|---|
| `index.html` | the published profile — byte-identical to the deliverable |
| `version.json` | the manifest every copy in the wild reads |
| `publish.ps1` | the only supported way to publish |
