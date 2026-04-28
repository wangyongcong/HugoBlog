# AGENTS.md

Guidance for agents working in this Hugo portfolio repository.

## Project Shape

- This is a Hugo static site for a personal portfolio, not a multi-page blog in current use.
- The live English portfolio content is in `content/_index.md`.
- The Chinese portfolio content is in `content/CN/index.md`.
- Portfolio images for the English homepage are stored directly under `content/`.
- Chinese page-bundle images are stored under `content/CN/` and `content/CN/index/`.
- The site uses the bundled theme at `themes/alageek`; this repo intentionally modifies that theme in place.
- Static root assets live in `static/`, including `static/CNAME`, `static/img/`, `static/css/lightbox.min.css`, and `static/js/lightbox.min.js`.

## Important Files

- `config.toml`: site metadata, menus, theme name, social links, logo path, and Hugo params.
- `content/_index.md`: the main English one-page portfolio.
- `content/CN/index.md`: Chinese portfolio page, with `gallery: true` for lightbox behavior.
- `themes/alageek/layouts/index.html`: homepage layout. It renders the Markdown content first, then optional pinned/latest blog sections.
- `themes/alageek/layouts/partials/header.html`: header markup plus conditional Mermaid and lightbox asset loading.
- `themes/alageek/layouts/partials/content.html`: theme content rendering and progressive-image replacement logic.
- `layouts/_default/_markup/render-image.html`: project-level Markdown image render hook for page-bundle images and lightbox galleries.
- `layouts/shortcodes/mermaid.html`: Mermaid shortcode.
- `themes/alageek/static/css/main.css`: primary dark theme styling.
- `themes/alageek/static/css/highlight.css`: syntax highlighting theme import.
- `deploy.bat`: Windows deployment helper that copies generated output from `destination` to `C:\projects\wangyongcong.github.io`.
- `.github/workflows/pages.yml`: GitHub Pages deployment workflow. It installs Hugo `0.160.1`, builds to `public/`, uploads the Pages artifact, and deploys from this source repository.

## Local Commands

- Preview locally:

  ```powershell
  hugo server -D
  ```

- Build for publishing:

  ```powershell
  hugo -d destination
  ```

- GitHub Pages publishing is handled by `.github/workflows/pages.yml` on pushes to `main` and manual `workflow_dispatch` runs. The workflow is pinned to Hugo `0.160.1`.

- A stricter local check used while editing:

  ```powershell
  hugo --printPathWarnings --printI18nWarnings --printUnusedTemplates -d destination-agent-check
  ```

  The current one-page portfolio build may warn about unused theme templates such as blog, taxonomy, section, robots, icon, list, and Mermaid shortcode templates. Treat those as informational unless the requested change touches those paths.

## Content Conventions

- Keep portfolio content in Markdown. Prefer editing `content/_index.md` and associated images before changing layouts.
- Use page-bundle-relative image paths when content is in a bundle, for example `![alt](image.jpg)`.
- The English homepage currently references images beside `content/_index.md`, for example `![Purr-fect-Chef](purr-fect-chef.jpg)`.
- The Chinese page uses gallery/lightbox support, so keep `gallery: true` when image lightbox behavior is required.
- The image render hook detects image sets from the Markdown alt text and page resources. If multiple matching resources exist, it renders a lightbox gallery and uses `*-small.*` files as thumbnails when present.
- Keep portfolio copy professional, concise, and resume-like. Preserve the existing section order unless the user asks for a redesign.

## Theme And Styling Conventions

- The theme has been customized to force a dark palette in `themes/alageek/static/css/main.css`; do not reintroduce system light/dark switching without explicit user direction.
- Header logo comes from `params.logofile` in `config.toml` and currently points to `/img/logo3.png`.
- Header language links are configured through `[[menu.primary]]` in `config.toml` rather than Hugo multilingual configuration.
- Avoid broad theme rewrites for content-only requests. This portfolio is intentionally simple and content-led.
- If adding JavaScript or CSS, prefer static assets under `static/` and conditional loading through Hugo params/front matter when the feature is page-specific.

## Deployment Notes

- `static/CNAME` is part of the published site and should not be removed.
- `destination/` is the normal generated output directory for publishing.
- GitHub Pages should be configured in the repository settings with `Build and deployment -> Source -> GitHub Actions`.
- `deploy.bat` assumes a sibling/local checkout at `C:\projects\wangyongcong.github.io` and is Windows-specific.
- `deploy.bat` is now a legacy/manual fallback. Do not run deployment or copy into `C:\projects\wangyongcong.github.io` unless the user explicitly asks.

## Agent Workflow

- Before edits, inspect the relevant Markdown, layout, and CSS rather than assuming a stock Hugo setup.
- Use `rg`/`rg --files` for search when available.
- After content, layout, or config changes, run `hugo -d destination-agent-check` or the stricter warning command above.
- Clean up temporary build output such as `destination-agent-check/` after verification when practical.
- Git may report dubious ownership in this environment because the sandbox user differs from the repository owner. Do not change global Git config unless the user asks or Git operations are required.
