import { z } from 'zod';

/**
 * Confidence levels used across UNSTUCK analysis, per docs/AI_BEHAVIOR.md.
 * A short or conflicting conversation must lower confidence.
 */
export const Confidence = z.enum(['high', 'medium', 'low']);
export type Confidence = z.infer<typeof Confidence>;

/**
 * Signals the analysis engine can evaluate, per docs/PRODUCT.md.
 * Not every signal appears in every context; this is the closed vocabulary.
 */
export const SignalName = z.enum([
  'interest',
  'effort',
  'consistency',
  'intent',
  'clarity',
  'reciprocity',
  'compatibility',
  'attachment',
  'risk',
]);
export type SignalName = z.infer<typeof SignalName>;

/**
 * A single evidence-backed signal. Conclusions must be evidence-based and
 * expressed with uncertainty when evidence is limited (docs/AI_BEHAVIOR.md).
 * No scores are invented from free-form intuition.
 */
export const AnalysisSignal = z.object({
  name: SignalName,
  /** Evidence-grounded reading. Empty means "not enough evidence". */
  reading: z.string().min(1).max(280),
  confidence: Confidence,
  /** Plain statement of why this conclusion was reached. Required, never invented. */
  evidence: z.string().min(1).max(1000),
});
export type AnalysisSignal = z.infer<typeof AnalysisSignal>;

/**
 * The structured result produced by Ranca and consumed by the backend.
 * This is the contract boundary: UNSTUCK depends on this shape, not on any
 * specific AI provider.
 */
export const AnalysisResult = z.object({
  /** THE READ — concise, conversational. */
  read: z.string().min(1).max(1000),
  signals: z.array(AnalysisSignal).max(9),
  /** What this does NOT mean — guards against overinterpretation. */
  doesNotMean: z.array(z.string().min(1).max(280)).max(5).default([]),
  /** One practical next move. */
  nextMove: z.string().min(1).max(280),
  overallConfidence: Confidence,
});
export type AnalysisResult = z.infer<typeof AnalysisResult>;
