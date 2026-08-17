import { z } from 'zod';

/**
 * Strict, validated application configuration.
 *
 * No production credentials are ever read from code or committed. Real values
 * are supplied via environment variables in local/CI/production secret stores
 * (docs/SECURITY.md). The API must fail to start if required config is invalid
 * rather than silently running with insecure defaults.
 */

const EnvSchema = z.object({
  NODE_ENV: z.enum(['local', 'test', 'staging', 'production']).default('local'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  HOST: z.string().default('127.0.0.1'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
  /** Base URL the iOS client uses. Never a production host in local/dev. */
  API_BASE_URL: z.string().url().default('http://127.0.0.1:3000'),
  /** Reference (never raw value) to AI provider credentials, server-side only. */
  RANCA_PROVIDER_ID: z.string().default('mock-dev'),
  RANCA_CREDENTIAL_REF: z.string().default('unset'),
  RANCA_TIMEOUT_MS: z.coerce.number().int().min(100).max(60000).default(10000),
});

export type AppConfig = z.infer<typeof EnvSchema>;

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const parsed = EnvSchema.safeParse(env);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`)
      .join('; ');
    // Never print secret values — zod only reports field names/messages here.
    throw new Error(`Invalid environment configuration: ${issues}`);
  }
  return parsed.data;
}
