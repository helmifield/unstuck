import { BadRequestException, Body, Controller, HttpCode, Post } from '@nestjs/common';
import {
  AnalysisResult,
  RancaRequest,
  RancaRequestSchema,
  RancaRequestParsed,
} from '@unstuck/contracts';
import { AnalysisService } from './analysis.service.js';

/**
 * Analysis endpoint.
 *
 * Validates input at the trust boundary with `RancaRequestSchema`
 * (docs/SECURITY.md "input validation"). Never logs the request body (the situation
 * text is user-provided relationship context — docs/SECURITY.md "no raw private
 * conversation in logs"). Delegates to the Ranca boundary via `AnalysisService`.
 *
 * No AI provider is referenced here; the provider is injected behind `Ranca`.
 */
@Controller('analysis')
export class AnalysisController {
  constructor(private readonly analysis: AnalysisService) {}

  @Post()
  @HttpCode(200)
  async analyze(@Body() body: unknown): Promise<AnalysisResult> {
    const parsed = RancaRequestSchema.safeParse(body);
    if (!parsed.success) {
      throw new BadRequestException(
        parsed.error.issues.map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`).join('; '),
      );
    }
    const req: RancaRequest = normalize(parsed.data);
    return this.analysis.analyze(req);
  }
}

function normalize(data: RancaRequestParsed): RancaRequest {
  // Only include `situation` when present (exactOptionalPropertyTypes: no `undefined`).
  const situation =
    data.situation !== undefined ? { situation: data.situation } : {};
  return {
    ...situation,
    hasConversationEvidence: data.hasConversationEvidence,
    requestId: data.requestId,
  };
}
