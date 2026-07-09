# BatchFrame

A single-page, client-side tool for batch-adding frames to photos. Drop in
a set of images, tune the frame and theme, and export the framed results —
everything runs locally in the browser, no upload required.

## Features

- Batch process multiple photos at once
- Adjustable frame tone and theme controls
- HEIC/HEIF support via [heic2any](https://github.com/alexcorvi/heic2any)
- Export all framed images as a single ZIP via [JSZip](https://stuk.github.io/jszip/)

## Usage

Open `index.html` in a modern browser — no build step or server needed.

Or serve it locally:

```bash
python3 -m http.server
# then visit http://localhost:8000
```

## macOS app

Build a local macOS app bundle:

```bash
scripts/build-macos-app.sh
```

The app is created at `dist/BatchFrame.app`.

## Files

- `index.html` — the app UI and logic
- `support.js` — runtime support script loaded by the page
- `macos/BatchFrameApp.swift` — native macOS WebView wrapper
- `scripts/build-macos-app.sh` — macOS app build script
