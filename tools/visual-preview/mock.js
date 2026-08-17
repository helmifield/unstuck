/**
 * UNSTUCK — Visual QA preview: deterministic mock data.
 *
 * This is a VISUAL-QA TOOL ONLY. It is NOT the product and is NOT wired to any API.
 * There are no network calls, no secrets, no AI provider, no analytics, no tracking.
 *
 * The mock reproduces the *form* of the approved `MockRanca` (services/api/src/mock-ranca.ts)
 * and the iOS `UnstuckFlowViewModel` result synthesis (synthesizeWhy / curiosityHook) so the
 * preview renders the same contract shape the native app renders — deterministically.
 *
 * Mirrors:
 *  - Situation set + titles  → apps/iOS/Unstuck/Flow/Situation.swift
 *  - AnalysisResult shape    → apps/iOS/Unstuck/Analysis/Contracts.swift
 *  - SignalName displayNames → apps/iOS/Unstuck/Result/SignalItem.swift
 *  - MockRanca.analyze       → services/api/src/mock-ranca.ts
 *  - synthesizeWhy / curiosityHook → apps/iOS/Unstuck/Flow/UnstuckFlowViewModel.swift
 */

'use strict';

/** Locked situation set (mirrors Situation.swift). id === rawValue. */
const SITUATIONS = [
  { id: 'talking_stage', title: 'Talking stage' },
  { id: 'dating', title: 'Dating' },
  { id: 'situationship_hts', title: 'Situationship / HTS' },
  { id: 'relationship', title: 'Relationship' },
  { id: 'breaking_up', title: 'Breaking up' },
  { id: 'someone_from_past', title: 'Someone from my past' },
  { id: 'something_else', title: 'Something else' },
];

/** Signal display names (mirrors SignalName.displayName in SignalItem.swift). */
const SIGNAL_DISPLAY_NAMES = {
  interest: 'Interest',
  effort: 'Effort',
  consistency: 'Consistency',
  intent: 'Intent',
  clarity: 'Clarity',
  reciprocity: 'Reciprocity',
  compatibility: 'Compatibility',
  attachment: 'Attachment',
  risk: 'Risk',
};

/**
 * Deterministic mock analysis. Mirrors MockRanca.analyze exactly:
 * evidence quality drops without a Tell; confidence follows. Never echoes the user's
 * free-form text; never invents evidence; gives one next move.
 *
 * @param {string|null|undefined} tell  free-form "what's happening" text (situation field)
 */
function mockAnalyze(tell) {
  const hasTell = typeof tell === 'string' && tell.trim().length > 0;
  const overall = hasTell ? 'medium' : 'low';

  const signals = [
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

  const result = {
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

  return { result, whyExplanation: synthesizeWhy(result), curiosityHook: curiosityHook(result) };
}

/** Mirrors UnstuckFlowViewModel.synthesizeWhy: WHY derived from evidence across signals. */
function synthesizeWhy(result) {
  const evidences = result.signals.map((s) => s.evidence).slice(0, 3);
  if (evidences.length === 0) {
    return "There wasn't enough evidence in what you described to reach a firm conclusion.";
  }
  return 'This read is based on: ' + evidences.join(' ');
}

/** Mirrors UnstuckFlowViewModel.curiosityHook: genuine invitation only when confidence is low. */
function curiosityHook(result) {
  if (result.overallConfidence !== 'low') return null;
  return "There's more to see. Adding a little more context could sharpen this read.";
}

/** Confidence label text (mirrors ConfidenceIndicator.swift). */
function confidenceLabel(confidence) {
  return { high: 'High confidence', medium: 'Medium confidence', low: 'Low confidence' }[
    confidence
  ];
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    SITUATIONS,
    SIGNAL_DISPLAY_NAMES,
    mockAnalyze,
    synthesizeWhy,
    curiosityHook,
    confidenceLabel,
  };
}
// Browser exposure: make these available to app.js without an AMD/ESM build step.
if (typeof window !== 'undefined') {
  window.UNSTUCK_MOCK = {
    SITUATIONS,
    SIGNAL_DISPLAY_NAMES,
    mockAnalyze,
    synthesizeWhy,
    curiosityHook,
    confidenceLabel,
  };
}
