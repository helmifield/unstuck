import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { NestApplicationOptions } from '@nestjs/common';
import { json, urlencoded } from 'express';
import { AppModule } from './app.module.js';
import { AllExceptionsFilter } from './exceptions.js';
import { APP_CONFIG, APP_LOGGER } from './config.module.js';
import { StructuredLogger } from './logger.js';
import type { AppConfig } from './config.js';

/**
 * Secure-by-default HTTP configuration.
 *
 * - Binds to 127.0.0.1 by default (loopback only) unless explicitly overridden.
 * - Enables a request body size limit to mitigate abusive payloads.
 * - Uses the centralized exception filter and structured logger.
 * - No CORS in scaffolding; the iOS client and any web client will be
 *   configured explicitly later. No credentials, no production hosts.
 */
async function bootstrap(): Promise<void> {
  const options: NestApplicationOptions = {
    bufferLogs: false,
    logger: ['error', 'warn'],
  };
  const app = await NestFactory.create(AppModule, options);

  const config = app.get<AppConfig>(APP_CONFIG);
  const logger = app.get<StructuredLogger>(APP_LOGGER);
  app.useLogger(logger);

  app.useGlobalFilters(new AllExceptionsFilter());

  // Limit request bodies; large uploads (screenshots) will be handled with
  // explicit, smaller limits when that feature is introduced.
  app.use(json({ limit: '256kb' }));
  app.use(urlencoded({ limit: '256kb', extended: true }));

  await app.listen(config.PORT, config.HOST);
  logger.log('api_listening', { port: config.PORT, host: config.HOST, env: config.NODE_ENV });
}

bootstrap().catch((err: unknown) => {
  console.error('fatal', err);
  process.exit(1);
});
