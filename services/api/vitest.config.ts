import { defineConfig } from 'vitest/config';
import swc from 'unplugin-swc';

// Vitest uses esbuild by default, which does NOT emit the `emitDecoratorMetadata`
// that NestJS dependency injection relies on. We swap the TS transform for swc,
// configured to preserve decorators + metadata, so DI resolves correctly in tests.
export default defineConfig({
  plugins: [
    swc.vite({
      module: { type: 'es6' },
      jsc: {
        target: 'es2022',
        parser: {
          syntax: 'typescript',
          decorators: true,
        },
        transform: {
          legacyDecorator: true,
          decoratorMetadata: true,
        },
      },
    }),
  ],
  test: {
    environment: 'node',
    include: ['test/**/*.test.ts', 'src/**/*.test.ts'],
    coverage: { reporter: ['text'] },
  },
});
