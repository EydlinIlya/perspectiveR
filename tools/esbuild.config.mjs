import * as esbuild from "esbuild";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.resolve(
  __dirname,
  "..",
  "inst",
  "htmlwidgets",
  "lib",
  "perspective-3.1.3"
);

async function build() {
  try {
    await esbuild.build({
      entryPoints: [path.resolve(__dirname, "src", "perspective-bundle.js")],
      bundle: true,
      format: "esm",
      outfile: path.resolve(outDir, "perspective-all.mjs"),
      minify: true,
      sourcemap: false,
      target: ["esnext"],
      supported: { "top-level-await": true },
      // Perspective inline builds include WASM as base64
      loader: {
        ".wasm": "binary",
        ".css": "text",
      },
      logLevel: "info",
    });
    console.log("Build complete: perspective-all.mjs");
  } catch (err) {
    console.error("Build failed:", err);
    process.exit(1);
  }
}

build();
