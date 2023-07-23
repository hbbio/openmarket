// vite.config.js
import { defineConfig } from "vite";
import { viteSingleFile } from "vite-plugin-singlefile";

export default defineConfig({
  // base: "./", // relative paths
  plugins: [viteSingleFile()],
});
