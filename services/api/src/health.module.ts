import { Module } from '@nestjs/common';
import { HealthController } from './health.controller.js';
import { HealthService } from './health.service.js';

/**
 * Health module.
 *
 * Exposes a single read-only `/health` endpoint used by `dev status` and by
 * future deployment probes. No product features, no database, no secrets.
 */
@Module({
  controllers: [HealthController],
  providers: [HealthService],
})
export class HealthModule {}
