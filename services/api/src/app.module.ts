import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { AnalysisModule } from './analysis.module.js';
import { ConfigModule } from './config.module.js';
import { HealthModule } from './health.module.js';
import { SecurityHeadersMiddleware } from './security.js';

/**
 * Root application module.
 *
 * Infrastructure + the first analysis surface: config + health + security headers +
 * the `/analysis` endpoint behind the Ranca boundary. No product features beyond the
 * approved Phase 3A vertical slice; no database, no real AI provider. Ranca is
 * represented by an abstract boundary (docs/ARCHITECTURE.md) and is wired to a
 * dev-safe mock in development.
 */
@Module({
  imports: [ConfigModule, HealthModule, AnalysisModule],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(SecurityHeadersMiddleware).forRoutes('*');
  }
}
