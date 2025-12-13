# Deployment Strategy: Pkgdown & GitHub Pages

**Status:** Production-Ready
**Context:** Project `etf-data`
**Date:** 2025-12-12

## Executive Summary

We use a **Hybrid Workflow** for this project. 
*   **Core Development & Logic:** Performed in **Nix** (locally and via `default.nix`) to ensure strict reproducibility of data retrieval and analysis.
*   **Documentation Deployment:** Performed in **Native R** (`r-lib/actions`) on GitHub Actions to bypass fundamental incompatibilities between the Nix store and modern R web tooling (`bslib`).

This document explains *why* we deviated from a "Pure Nix" CI pipeline for the website and how to replicate this success.

---

## The Problem: Nix vs. Modern R Web Tools

The 9-Step Workflow usually mandates using Nix for everything. However, `pkgdown` (specifically via `bslib` for Bootstrap 5 themes) has a specific runtime behavior that conflicts with Nix:

1.  **Immutability:** The Nix store (`/nix/store/...`) is **read-only**.
2.  **Runtime Copying:** `bslib` attempts to copy JavaScript/CSS assets *from* its installation directory *to* a temporary cache or the output directory during execution.
3.  **The Crash:** In a strict Nix environment (like our CI), `bslib` often fails with `Permission denied` when trying to access or manipulate files in ways that assume a standard, writable R library path.
4.  **Quarto Complexity:** Quarto adds another layer. It is a binary dependency that must be in the PATH. While Nix handles this well, `pkgdown`'s invocation of Quarto can sometimes desynchronize from the Nix shell context in CI, leading to "Quarto not found" or "Pandoc not found" errors.

## The Solution: Native R for Deployment

We use the standard **`r-lib/actions`** for the *deployment* workflow (`deploy-docs.yml`), effectively treating the documentation build as a "presentation layer" task rather than a "core logic" task.

### Why this is Acceptable (Compliance Check)

Is this "cheating" the 9-step workflow? **No.**

*   **Logic is Verified in Nix:** We still run `devtools::check()` and our `targets` pipeline in the Nix environment (locally or in a separate `nix-ci.yml` if we added one). This ensures our *code* works in a reproducible environment.
*   **Documentation is Presentation:** The website is a view of our package. Building it in a standard Ubuntu/R environment ensures compatibility with the latest web standards (Pandoc, Quarto, Bootstrap) without fighting the Nix store permissions.
*   **Pre-built Vignettes:** We use `targets` to render vignettes locally (in Nix!) and commit the HTML/Markdown. The CI just wraps them in the site structure. This preserves computational reproducibility (results computed in Nix) while allowing flexible deployment.

---

## The Workflow Pattern

### 1. `deploy-docs.yml` Configuration

**DO:**
*   Use `r-lib/actions/setup-r` and `setup-pandoc`.
*   Use `quarto-dev/quarto-actions/setup` to ensure the CLI is available.
*   Install dependencies via `remotes::install_deps`.
*   Run `pkgdown::build_site(new_process = FALSE)` to avoid spawning a child process that might lose environment variables.

**DON'T:**
*   **Don't use `nix-shell`** for the `pkgdown` build step. It introduces the permission errors.
*   **Don't forget `setup-pandoc`**. `pkgdown` needs it for converting READMEs and manual pages, even if you aren't building vignettes.

### 2. Vignette Strategy (The "Pre-built" Pattern)

To ensure the analysis (e.g., fetching ETF data) is reproducible via Nix, but the site builds easily:

1.  **Local Execution:** Run `targets::tar_make()` in your local Nix shell. This runs the heavy code and renders `analysis.qmd` to `analysis.html` (or `.md`).
2.  **Commit Artifacts:** Commit the generated `vignettes/*.html` (or `inst/doc/*.html`).
3.  **Configure Pkgdown:** In `_pkgdown.yml`, set `build_articles: false` (or configure it to use existing HTML).
    *   *Refinement:* In our working solution, we moved the source `.qmd` to `inst/qmd/` so `pkgdown` wouldn't try (and fail) to rebuild it in CI, while leaving the `.html` in `vignettes/`.

### 3. GitHub Pages Settings

**DO:**
*   Set Source to **"GitHub Actions"** (not "Deploy from Branch"). This allows the workflow to push the `_site` artifact directly.

---

## Summary of Rules

| Task | Environment | Why? |
| :--- | :--- | :--- |
| **Data Retrieval** | **Nix** | Reproducibility, strict dependency versions. |
| **Unit Tests** | **Nix** | Verification in controlled environment. |
| **Vignette Rendering** | **Nix (Local)** | Heavy computation needs reproducible stack. |
| **Site Building** | **Native R (CI)** | `bslib`/Quarto compatibility, file permissions. |
| **Site Deployment** | **Native R (CI)** | Standard GitHub Actions integration. |

By separating the "Compute" (Nix) from the "Publish" (Native R), we get the best of both worlds: robust analysis and reliable deployment.
