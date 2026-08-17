import { Inject, Injectable } from '@nestjs/common';
import { AnalysisResult, Ranca, RancaRequest } from '@unstuck/contracts';

/**
 * Server-side analysis service.
 *
 * Depends on the `Ranca` orchestration boundary (docs/ARCHITECTURE.md), never on a
 * concrete AI provider. The provider is injected; in development it is `MockRanca`.
 *
 * Security (docs/SECURITY.md): never logs the user's free-form `situation` text; only
 * non-content audit fields (request id presence, whether a Tell was provided) may be
 * logged elsewhere. Raw request material is not persisted beyond this call.
 */
@Injectable()
export class AnalysisService {
  constructor(@Inject('RANCA') private readonly ranca: Ranca) {}

  analyze(request: RancaRequest): Promise<AnalysisResult> {
    return this.ranca.analyze(request);
  }
}
