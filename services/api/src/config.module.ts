import { Global, Module } from '@nestjs/common';
import { AppConfig, loadConfig } from './config.js';
import { StructuredLogger } from './logger.js';

/**
 * Loads and exposes validated configuration application-wide.
 * Configuration is validated exactly once at startup; an invalid environment
 * fails fast rather than running with insecure defaults.
 */
export const APP_CONFIG = 'APP_CONFIG';
export const APP_LOGGER = 'APP_LOGGER';

@Global()
@Module({
  providers: [
    {
      provide: APP_CONFIG,
      useFactory: (): AppConfig => loadConfig(),
    },
    {
      provide: APP_LOGGER,
      useFactory: (): StructuredLogger => {
        const cfg = loadConfig();
        return new StructuredLogger(cfg.LOG_LEVEL);
      },
    },
  ],
  exports: [APP_CONFIG, APP_LOGGER],
})
export class ConfigModule {}
