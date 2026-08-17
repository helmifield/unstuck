/**
 * Smoke test for the visual QA preview (Node, zero-dependency, no DOM).
 *
 * Verifies the deterministic mock produces the approved contract shape and that the
 * preview's gating logic mirrors the iOS view-model. Run with: node tools/visual-preview/test.js
 */

'use strict';

const mock = require('./mock.js');
const app = require('./app.js');

let failures = 0;
function assert(name, cond) {
  if (cond) {
    console.log('  ok  - ' + name);
  } else {
    console.error('  FAIL- ' + name);
    failures++;
  }
}

// ---- Mock contract shape (mirrors MockRanca + AnalysisResult) ----
const withTell = mock.mockAnalyze('We have been talking for a few weeks.');
assert('with-tell overall is medium', withTell.result.overallConfidence === 'medium');
assert('with-tell has 2 signals', withTell.result.signals.length === 2);
assert('with-tell signal has name/reading/confidence/evidence',
  withTell.result.signals.every(s => s.name && s.reading && s.confidence && s.evidence));
assert('with-tell doesNotMean present', withTell.result.doesNotMean.length === 2);
assert('with-tell nextMove present', typeof withTell.result.nextMove === 'string');
assert('with-tell never echoes user text',
  !JSON.stringify(withTell.result).includes('talking for a few weeks'));
assert('with-tell curiosity hook is null (confidence medium)', withTell.curiosityHook === null);
assert('with-tell WHY mentions evidence', withTell.whyExplanation.startsWith('This read is based on:'));

const noTell = mock.mockAnalyze(null);
assert('no-tell overall is low', noTell.result.overallConfidence === 'low');
assert('no-tell curiosity hook present (low confidence)', typeof noTell.curiosityHook === 'string');
assert('no-tell read mentions not enough', /not enough/i.test(noTell.result.read));

// Determinism: same input → identical output.
assert('deterministic for same input', JSON.stringify(mock.mockAnalyze('x')) === JSON.stringify(mock.mockAnalyze('x')));

// ---- Gating logic mirrors UnstuckFlowViewModel ----
const canContinue = app.canContinueFromTell;
assert('empty tell cannot continue', canContinue('') === false);
assert('whitespace tell cannot continue', canContinue('    \n ') === false);
assert('short tell cannot continue', canContinue('hi') === false);
assert('>=12 chars can continue', canContinue('We have been talking.') === true);

// ---- Situation set is locked ----
const ids = mock.SITUATIONS.map(s => s.id).sort();
assert('situation set locked', JSON.stringify(ids) === JSON.stringify([
  'breaking_up', 'dating', 'relationship', 'situationship_hts',
  'someone_from_past', 'something_else', 'talking_stage',
]));
assert('talking_stage title', mock.SITUATIONS.find(s => s.id === 'talking_stage').title === 'Talking stage');
assert('something_else title', mock.SITUATIONS.find(s => s.id === 'something_else').title === 'Something else');

if (failures === 0) {
  console.log('\nAll visual-preview smoke checks passed.');
  process.exit(0);
} else {
  console.error('\n' + failures + ' visual-preview smoke check(s) FAILED.');
  process.exit(1);
}
