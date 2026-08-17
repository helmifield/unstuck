import { Injectable } from '@nestjs/common';
import {
  AnalysisResult,
  AnalysisSignal,
  Confidence,
  Ranca,
  RancaRequest,
} from '@unstuck/contracts';

/**
 * Development-safe mock Ranca implementation.
 *
 * This is NOT a real AI provider. It sits behind the `Ranca` orchestration boundary
 * (docs/ARCHITECTURE.md) so the iOS client and API exercise the real contract path
 * (iOS → UNSTUCK API → Ranca boundary → analysis) without any provider credentials or
 * network calls. No AI provider is embedded; no credentials are read.
 *
 * Output is deterministic, evidence-based in *form* (always separates evidence from
 * inference, states uncertainty, never claims certainty about another person's private
 * intentions), and contains NO real personal information — it never echoes the user's
 * free-form text back. Per docs/AI_BEHAVIOR.md: it does not invent evidence, does not
 * mind-read, and gives exactly one practical next move.
 *
 * This mock is wired only when `RANCA_PROVIDER_ID=mock-dev` (see AnalysisModule).
 */
@Injectable()
export class MockRanca implements Ranca {
  analyze(request: RancaRequest): Promise<AnalysisResult> {
    const hasTell = typeof request.situation === 'string' && request.situation.trim().length > 0;
    // Evidence quality drops without a Tell; confidence follows (docs/AI_BEHAVIOR.md).
    const overall: Confidence = hasTell ? 'medium' : 'low';

    const signals: AnalysisSignal[] = [
      {
        name: 'interest',
        reading: hasTell
          ? 'There are signs of engagement, but intent is not established by description alone.'
          : 'Not enough evidence to read interest from a description that was not provided.',
        confidence: hasTell ? 'medium' : 'low',
        evidence: hasTell
          ? 'Based only on the situation you described; no conversation was provided to verify.'
          : 'No situation description was provided, so there is nothing to read.',
      },
      {
        name: 'clarity',
        reading: 'Clarity is limited until more context is available.',
        confidence: 'low',
        evidence: 'A single description cannot establish where things actually stand.',
      },
    ];

    const result: AnalysisResult = {
      read: hasTell
        ? "Here's an initial read based on what you described. It's a starting point, not a verdict — there's more to see with a little more context."
        : "There's not enough here to give you a real read yet. Add a little about what's happening and we'll look closer.",
      signals,
      doesNotMean: [
        'This is not a prediction of what someone is thinking.',
        'A medium read is not a green light or a red flag.',
      ],
      nextMove: hasTell
        ? 'Notice one concrete pattern in how they act this week, without overthinking it.'
        : 'Add a sentence or two about what specifically is happening.',
      overallConfidence: overall,
    };

    return Promise.resolve(result);
  }
}
