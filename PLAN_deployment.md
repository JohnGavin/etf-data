# Plan: Deployment Strategy for WebR/Shinylive

**Objective:** Deploy a pkgdown website for `etfdata` that includes interactive WebR/Shinylive vignettes using the project's own R package.

## 1. The Challenge
*   **WebR Requirement:** Needs WASM binaries (`.tgz` for macOS/wasm, or special `.data`).
*   **Cachix Limitation:** Hosts Nix binaries (ELF/Mach-O), not compatible with WebR.
*   **Monorepo Structure:** `etfdata` is deep in `finance/data/etfs/etfdata`. Standard R-Universe or generic actions usually expect root packages.

## 2. Options Analysis

### Option A: R-Universe (Simplicity)
*   **Setup:** Enable R-Universe for `JohnGavin`. It builds all packages.
*   **Usage:** `webr::install("etfdata", repos = "https://johngavin.r-universe.dev")`.
*   **Pros:** Zero CI config. Handles WASM compilation.
*   **Cons:** Lag time (hourly). Monorepo support might need configuration (`packages.json` in root).

### Option B: Custom Repository on GitHub Pages (Recommended)
*   **Setup:** Use `r-wasm/actions` in GitHub Actions to build WASM binaries.
*   **Storage:** Deploy binaries to `docs/bin` (served via GitHub Pages).
*   **Usage:** `webr::install("etfdata", repos = "https://johngavin.github.io/llm/bin/")`.
*   **Pros:** Instant updates. Integrated with pkgdown deployment. Full control.
*   **Cons:** Adds build time to CI (~10 mins).

## 3. Recommended Strategy: Custom Repo via GitHub Actions

We will build the WASM repository as part of the documentation workflow.

### Implementation Steps

1.  **Configure CI (`.github/workflows/deploy-docs.yml`):**
    *   Job 1: `build-wasm`:
        *   Uses `r-lib/actions/setup-r`.
        *   Uses `r-wasm/actions/build-rwasm`.
        *   Builds `etfdata` to `_site/bin`.
    *   Job 2: `build-pkgdown`:
        *   Uses Native R (as per AGENTS.md for pkgdown).
        *   Builds site to `_site`.
    *   Job 3: `deploy`:
        *   Deploys `_site` to GitHub Pages.

2.  **Update Vignettes:**
    *   Use `webr::install("etfdata", repos = "https://johngavin.github.io/llm/bin/")`.

3.  **Monorepo Handling:**
    *   The GitHub Action needs to be directed to `finance/data/etfs/etfdata`.

## 4. Pros & Cons Summary (Context: WebR/Shinylive)

| Strategy | WebR Compat | CI Overhead | Latency | Monorepo Friendly |
| :--- | :--- | :--- | :--- | :--- |
| **Cachix** | ❌ No | Low | Low | Yes |
| **R-Universe** | ✅ Yes | None | High | Medium |
| **Custom Repo** | ✅ Yes | High | Low | Yes (Manual config) |

**Decision:** **Custom Repo** is the robust choice for a self-contained monorepo project where we want immediate vignette availability upon merge.
