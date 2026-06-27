# russian_vocabulary_quiz

Personal Russian vocabulary quiz (Flutter Web). Local JSON only — no server, no API keys.

## Public URL (GitHub Pages)

`https://<username>.github.io/russian_vocabulary_quiz/`

## Build for GitHub Pagesnyan

```bash
flutter pub get
flutter build web --base-href=/russian_vocabulary_quiz/
```

Copy output into `docs/` (see `scripts/build_github_pages.ps1`), then commit and push.

## GitHub Pages settings

1. Repository → **Settings** → **Pages**
2. **Build and deployment** → Source: **Deploy from a branch**
3. Branch: **main** / Folder: **/docs**
4. Save

`.nojekyll` in `docs/` is required (included by the script).

## Local Web (development)

```bash
flutter run -d chrome --base-href=/
```

## Word data

Edit JSON under `assets/data/`, then rebuild and redeploy.

## Stack

- Flutter / Dart (`StatefulWidget` + `setState`)
- `flutter_tts` (device/browser TTS)
- `shared_preferences` (missed / guessed IDs)
- Assets: `assets/data/*.json`

No Firebase, no paid APIs, no cloud sync.
