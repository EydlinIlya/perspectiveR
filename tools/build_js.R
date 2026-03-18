# Build script for perspectiveR JS assets
# Run from the package root directory:
#   source("tools/build_js.R")

tools_dir <- file.path(getwd(), "tools")

message("=== Installing npm dependencies ===")
status <- system2("npm", args = c("install"), stdout = TRUE, stderr = TRUE,
                  env = paste0("npm_config_prefix=", tools_dir))
if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
  stop("npm install failed:\n", paste(status, collapse = "\n"))
}

message("\n=== Building Perspective ESM bundle ===")
status <- system2("npm", args = c("run", "build"), stdout = TRUE, stderr = TRUE)
if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
  stop("esbuild failed:\n", paste(status, collapse = "\n"))
}

message("\n=== Copying theme CSS files ===")
status <- system2("npm", args = c("run", "copy-themes"), stdout = TRUE, stderr = TRUE)
if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
  stop("Theme copy failed:\n", paste(status, collapse = "\n"))
}

message("\n=== Build complete! ===")
