import { Module } from '@nestjs/common';
import { Ranca } from '@unstuck/contracts';
import { AnalysisController } from './analysis.controller.js';
import { AnalysisService } from './analysis.service.js';
import { MockRanca } from './mock-ranca.js';
import { loadConfig } from './config.js';

/**
 * Analysis module.
 *
 * Wires the `Ranca` orchestration boundary (docs/ARCHITECTURE.md). The concrete provider
 * is selected from config: in development (`RANCA_PROVIDER_ID=mock-dev`) the dev-safe
 * `MockRanca` is used. No real AI provider is embedded and no provider credentials are
 * read here — real providers are injected server-side only in staging/production.
 *
 * The provider id is a non-secret reference (`RANCA_PROVIDER_ID`), never a credential.
 */
@Module({
  controllers: [AnalysisController],
  providers: [
    AnalysisService,
    {
      provide: 'RANCA',
      useFactory: (): Ranca => {
        const cfg = loadConfig();
        if (cfg.RANCA_PROVIDER_ID === 'mock-dev') {
          return new MockRanca();
        }
        // No real provider wired yet. Fail explicitly rather than fabricate analysis
        // (docs/AI_BEHAVIOR.md "Never invent evidence"). A real provider must be injected
        // server-side only; the dev path expects 'mock-dev'.
        throw new Error(
          `Ranca provider '${cfg.RANCA_PROVIDER_ID}' is not configured (dev expects 'mock-dev')`,
        );
      },
    },
  ],
})
export class AnalysisModule {}
