import { describe, it, expect } from 'vitest';
import { loadConfig } from '../src/config.js';

describe('loadConfig', () => {
  it('uses safe defaults in an empty environment', () => {
    const cfg = loadConfig({});
    expect(cfg.NODE_ENV).toBe('local');
    expect(cfg.HOST).toBe('127.0.0.1');
    // Dev-safe mock provider by default; never a real provider, never a credential.
    expect(cfg.RANCA_PROVIDER_ID).toBe('mock-dev');
    expect(cfg.RANCA_CREDENTIAL_REF).toBe('unset');
  });

  it('coerces PORT to a number', () => {
    const cfg = loadConfig({ PORT: '4321' });
    expect(cfg.PORT).toBe(4321);
  });

  it('rejects an invalid PORT', () => {
    expect(() => loadConfig({ PORT: '70000' })).toThrow(/Invalid environment configuration/);
  });

  it('rejects an invalid NODE_ENV', () => {
    expect(() => loadConfig({ NODE_ENV: 'prod' })).toThrow(/Invalid environment configuration/);
  });

  it('rejects an invalid API_BASE_URL', () => {
    expect(() => loadConfig({ API_BASE_URL: 'not-a-url' })).toThrow(
      /Invalid environment configuration/,
    );
  });
});
