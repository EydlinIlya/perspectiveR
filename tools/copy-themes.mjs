// Copy Perspective theme CSS files to inst/htmlwidgets/lib/
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const themeSrc = path.resolve(
  __dirname,
  "node_modules",
  "@finos",
  "perspective-viewer",
  "dist",
  "css"
);
const themeDest = path.resolve(
  __dirname,
  "..",
  "inst",
  "htmlwidgets",
  "lib",
  "perspective-3.1.3",
  "themes"
);

// Create destination directory
fs.mkdirSync(themeDest, { recursive: true });

// Copy all CSS files
if (fs.existsSync(themeSrc)) {
  const files = fs.readdirSync(themeSrc).filter((f) => f.endsWith(".css"));
  for (const file of files) {
    fs.copyFileSync(path.join(themeSrc, file), path.join(themeDest, file));
    console.log(`Copied theme: ${file}`);
  }
} else {
  console.warn(`Theme source not found: ${themeSrc}`);
  console.log("Checking alternative paths...");

  // Try alternative paths for different Perspective versions
  const altPaths = [
    path.resolve(
      __dirname,
      "node_modules",
      "@finos",
      "perspective-viewer",
      "dist",
      "themes"
    ),
    path.resolve(
      __dirname,
      "node_modules",
      "@finos",
      "perspective-viewer",
      "themes"
    ),
  ];

  for (const altPath of altPaths) {
    if (fs.existsSync(altPath)) {
      const files = fs.readdirSync(altPath).filter((f) => f.endsWith(".css"));
      for (const file of files) {
        fs.copyFileSync(
          path.join(altPath, file),
          path.join(themeDest, file)
        );
        console.log(`Copied theme: ${file}`);
      }
      break;
    }
  }
}

console.log("Theme copy complete.");
