import { Injectable } from '@nestjs/common';
import { HealthResponse, HealthStatus } from '@unstuck/contracts';

/** Deterministic service identity. Version is static during scaffolding. */
const SERVICE = 'unstuck-api';
const VERSION = '0.0.0';

@Injectable()
export class HealthService {
  status(): HealthResponse {
    const status: HealthStatus = 'ok';
    return {
      status,
      service: SERVICE,
      version: VERSION,
      timestamp: new Date().toISOString(),
    };
  }
}
