# Log for WebR/WASM Installation Investigation
# Date: 2025-12-15
# Author: Gemini Agent

# 1. Created branch 'doc-wasm-install-info'

# 2. Investigation
# User reported: "Requested package etfdata not found in webR binary repo."
# Checked `https://johngavin.r-universe.dev/packages/etfdata` -> 404.
# Checked `https://johngavin.r-universe.dev/builds` for "etfdata" and "WebAssembly" -> no results.

# 3. Conclusion
# The `etfdata` package is not currently built or indexed as a WebAssembly binary on johngavin.r-universe.dev.
# This prevents it from being installed in the WebR interactive console.

# 4. Action
# Informed user. No code changes to the package itself required at this stage,
# as the package needs to be built by R-Universe's CI for WASM.
# The vignette already handles fallback gracefully.
# This log serves as documentation of the investigation.
