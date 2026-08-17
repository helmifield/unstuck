import { z } from 'zod';

/** Service health, used by the backend `/health` endpoint and by `dev status`. */
export const HealthStatus = z.enum(['ok', 'degraded', 'down']);
export type HealthStatus = z.infer<typeof HealthStatus>;

export const HealthResponse = z.object({
  status: HealthStatus,
  service: z.string(),
  version: z.string(),
  timestamp: z.string().datetime(),
});
export type HealthResponse = z.infer<typeof HealthResponse>;
