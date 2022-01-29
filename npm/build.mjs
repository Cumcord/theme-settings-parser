import esbuild from "esbuild";

try {
  await esbuild.build({
    entryPoints: ["./src/index.js"],
    outfile: "./dist/index.js",
    minify: true,
    bundle: true,
    format: "esm",
    target: ["esnext"],
  });

  await esbuild.build({
    entryPoints: ["./src/test.js"],
    outfile: "./dist/test.js",
    minify: true,
    bundle: true,
    format: "iife",
    target: ["esnext"],
  });

  console.log("Build successful!");
} catch (err) {
  console.error(err);
  process.exit(1);
}