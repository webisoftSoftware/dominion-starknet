/// <reference types='vitest' />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { nxViteTsPaths } from '@nx/vite/plugins/nx-tsconfig-paths.plugin';
import { nxCopyAssetsPlugin } from '@nx/vite/plugins/nx-copy-assets.plugin';
import { TanStackRouterVite } from '@tanstack/router-plugin/vite';
import svgr from 'vite-plugin-svgr';
import wasm from 'vite-plugin-wasm';

export default defineConfig({
  root: __dirname,
  cacheDir: '../../node_modules/.vite/apps/frontend',
  server: {
    port: 4200,
    host: 'localhost',
    cors: true,
    allowedHosts: ['localhost', "0e31240b304d.ngrok.app"],
  },
  preview: {
    port: 4300,
    host: 'localhost',
  },
  plugins: [
    wasm(),
    TanStackRouterVite(),
    react(),
    nxViteTsPaths(),
    nxCopyAssetsPlugin(['*.md']),
    svgr()],
  // Uncomment this if you are using workers.
  // worker: {
  //  plugins: [ nxViteTsPaths() ],
  // },
  build: {
    outDir: '../../dist/apps/frontend',
    emptyOutDir: true,
    reportCompressedSize: true,
    target: 'esnext',
    commonjsOptions: {
      transformMixedEsModules: true,
    },
  },
});
