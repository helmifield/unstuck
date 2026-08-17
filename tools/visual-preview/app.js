/**
 * UNSTUCK — Visual QA preview controller.
 *
 * Visual-QA tool only. Reproduces the approved Phase 3A iOS flow in the browser:
 * Launch → What's Going On? → Select Situation → Tell → Analysis → The Read.
 *
 * Mock-only, deterministic (mock.js). No network, no secrets, no tracking.
 * Mirrors the iOS state machine in apps/iOS/Unstuck/Flow/UnstuckFlowViewModel.swift
 * and FlowContainerView.swift (forward always available; back reversible; honest
 * loading/loaded/failed states; curiosity hook only when confidence is low).
 */

'use strict';

(function () {
  // Load mock module (browser global from mock.js; CJS module in node tests).
  var mock = (typeof module !== 'undefined' && module.exports)
    ? require('./mock.js')
    : window.UNSTUCK_MOCK;

  var SITUATIONS = mock.SITUATIONS;
  var SIGNAL_DISPLAY_NAMES = mock.SIGNAL_DISPLAY_NAMES;
  var mockAnalyze = mock.mockAnalyze;
  var confidenceLabel = mock.confidenceLabel;

  // Flow steps mirror UnstuckFlowStep.swift. States that correspond to screens.
  var STEPS = ['launch', 'whatsGoingOn', 'selectSituation', 'tell', 'loading', 'result'];
  var STEP_TOTAL = 4; // UnstuckFlowStep.allCases.count - 1 (progress excludes launch)

  var state = {
    step: 'launch',
    selectedSituation: null,
    tellText: '',
    result: null,            // { result, whyExplanation, curiosityHook }
    resultMode: 'loaded',    // 'loading' | 'loaded' | 'failed'
    failureMessage: '',
  };

  var els = {};

  function $(sel) { return document.querySelector(sel); }
  function $$(sel) { return Array.prototype.slice.call(document.querySelectorAll(sel)); }

  function init() {
    els.situationList = $('#situation-list');
    els.situationHelper = $('#situation-helper');
    els.tellInput = $('#tell-input');
    els.tellGuidance = $('#tell-guidance');
    els.resultContainer = $('#result-container');
    els.resultActions = $('#result-actions');
    els.getReadBtn = $('#screen-tell .btn-primary');
    els.continueSituationBtn = $('#screen-selectSituation .btn-primary');

    renderSituations();
    bindActions();
    bindDevControls();
    render();
  }

  // ---- Rendering ----

  function renderSituations() {
    els.situationList.innerHTML = '';
    SITUATIONS.forEach(function (s) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'situation-option';
      btn.dataset.id = s.id;
      btn.setAttribute('aria-pressed', 'false');
      btn.innerHTML =
        '<span class="title">' + escapeHtml(s.title) + '</span>' +
        '<span class="selected-label">Selected</span>';
      btn.addEventListener('click', function () {
        state.selectedSituation = s.id;
        updateSituationSelection();
        render();
      });
      els.situationList.appendChild(btn);
    });
  }

  function updateSituationSelection() {
    $$('.situation-option').forEach(function (opt) {
      var isSel = opt.dataset.id === state.selectedSituation;
      opt.classList.toggle('selected', isSel);
      opt.setAttribute('aria-pressed', isSel ? 'true' : 'false');
    });
    var has = !!state.selectedSituation;
    els.continueSituationBtn.disabled = !has;
    els.situationHelper.hidden = has;
  }

  function renderStepProgress() {
    $$('[data-step-progress]').forEach(function (host) {
      var current = parseInt(host.dataset.step, 10);
      host.innerHTML = '';
      for (var i = 0; i < STEP_TOTAL; i++) {
        var dot = document.createElement('span');
        dot.className = 'dot';
        if (i < current) dot.classList.add('filled');
        if (i === current - 1) dot.classList.add('current');
        host.appendChild(dot);
      }
    });
  }

  function renderTell() {
    els.tellInput.value = state.tellText;
    updateTellGuidance();
    els.getReadBtn.disabled = !canContinueFromTell();
  }

  // Mirrors UnstuckFlowViewModel.tellGuidance / canContinueFromTell.
  function updateTellGuidance() {
    var trimmed = state.tellText.trim();
    var guidance = null;
    if (trimmed.length === 0) {
      guidance = 'Add a little about what\u2019s happening so we can read it.';
    } else if (trimmed.length < 12) {
      guidance = 'A bit more helps \u2014 what specifically is going on?';
    }
    if (guidance) {
      els.tellGuidance.textContent = guidance;
      els.tellGuidance.hidden = false;
    } else {
      els.tellGuidance.hidden = true;
    }
  }

  function canContinueFromTell(text) {
    var value = (typeof text === 'string') ? text : state.tellText;
    return value.trim().length >= 12;
  }

  function renderResult() {
    els.resultContainer.innerHTML = '';
    els.resultActions.innerHTML = '';

    if (state.resultMode === 'loading') {
      // Loading screen is its own screen; nothing to render here.
      return;
    }

    if (state.resultMode === 'failed') {
      els.resultContainer.innerHTML =
        '<div class="stack-lg">' +
        '  <p class="failed-title">We couldn\u2019t get a read.</p>' +
        '  <p class="failed-msg">' + escapeHtml(state.failureMessage) + '</p>' +
        '</div>';
      els.resultActions.innerHTML =
        '<button class="btn-primary" data-action="retry">Try again</button>';
      return;
    }

    var loaded = state.result;
    if (!loaded) return;
    var r = loaded.result;

    var html = '';
    // THE READ (visually dominant)
    html += '<div class="read reveal-item">' + escapeHtml(r.read) + '</div>';
    // Overall read + confidence
    html += '<div class="overall-row reveal-item"><span class="overall-label">Overall read</span>' +
      confidenceHtml(r.overallConfidence) + '</div>';
    // SIGNALS
    html += '<div class="reveal-item"><h2 class="section-header">Signals</h2>';
    if (!r.signals.length) {
      html += '<p class="t-secondary">Not enough evidence to read signals yet.</p>';
    } else {
      r.signals.forEach(function (s) {
        var name = SIGNAL_DISPLAY_NAMES[s.name] || s.name;
        html += '<div class="signal">' +
          '  <div class="signal-head"><span class="signal-name">' + escapeHtml(name) + '</span>' +
          confidenceHtml(s.confidence) + '</div>' +
          '  <p class="signal-reading">' + escapeHtml(s.reading) + '</p>' +
          '  <p class="signal-evidence">' + escapeHtml(s.evidence) + '</p>' +
          '</div>';
      });
    }
    html += '</div>';
    // WHY
    html += '<div class="reveal-item"><h2 class="section-header">Why</h2>' +
      '<p class="why-text">' + escapeHtml(loaded.whyExplanation) + '</p></div>';
    // WHAT THIS DOESN'T MEAN
    if (r.doesNotMean && r.doesNotMean.length) {
      html += '<div class="reveal-item"><h2 class="section-header">What this doesn\u2019t mean</h2><ul class="does-not-mean-list">';
      r.doesNotMean.forEach(function (item) {
        html += '<li>&mdash; ' + escapeHtml(item) + '</li>';
      });
      html += '</ul></div>';
    }
    // NEXT MOVE
    html += '<div class="reveal-item"><h2 class="section-header">Next move</h2>' +
      '<p class="next-move-text">' + escapeHtml(r.nextMove) + '</p></div>';
    // CURIOSITY HOOK (optional, genuine — only when provided)
    if (loaded.curiosityHook) {
      html += '<button class="curiosity reveal-item" data-action="curiosity">' +
        '<span class="label">Curious</span>' +
        '<span class="hook">' + escapeHtml(loaded.curiosityHook) + '</span></button>';
    }
    els.resultContainer.innerHTML = html;
    els.resultActions.innerHTML =
      '<button class="btn-primary" data-action="reset">Start over</button>';
  }

  function confidenceHtml(level) {
    return '<span class="confidence" data-level="' + escapeAttr(level) + '">' +
      '<span class="dot" aria-hidden="true"></span>' +
      escapeHtml(confidenceLabel(level)) + '</span>';
  }

  // ---- Navigation (forward always available; back reversible) ----

  function go(nextStep) {
    state.step = nextStep;
    render();
  }

  function next() {
    var idx = STEPS.indexOf(state.step);
    // From tell → loading → result (loading is a transient screen we still allow visiting).
    var nxt = STEPS[idx + 1] || state.step;
    go(nxt);
  }

  function requestAnalysis() {
    // Deterministic mock analysis; honest loading transition (calm, short — no fake delay).
    state.resultMode = 'loading';
    go('loading');
    var computed = mockAnalyze(state.tellText.trim() || null);
    // Brief, honest transition (not a fake progress bar). Calm and short.
    setTimeout(function () {
      state.result = computed;
      state.resultMode = 'loaded';
      go('result');
    }, 650);
  }

  function reset() {
    state.step = 'launch';
    state.selectedSituation = null;
    state.tellText = '';
    state.result = null;
    state.resultMode = 'loaded';
    state.failureMessage = '';
    updateSituationSelection();
    render();
  }

  // ---- Screen visibility ----

  function render() {
    STEPS.forEach(function (s) {
      var el = document.getElementById('screen-' + s);
      if (!el) return;
      el.hidden = (s !== state.step);
    });
    // Loading screen is a transient; show it when step === loading.
    renderStepProgress();
    if (state.step === 'selectSituation') updateSituationSelection();
    if (state.step === 'tell') renderTell();
    if (state.step === 'result') renderResult();
    // Re-bind any data-action buttons that were rendered dynamically.
    bindDynamicActions();
    updateDevActiveState();
  }

  // ---- Event wiring ----

  function bindActions() {
    document.body.addEventListener('click', function (e) {
      var t = e.target.closest('[data-action]');
      if (!t) return;
      var action = t.dataset.action;
      switch (action) {
        case 'begin': go('whatsGoingOn'); break;
        case 'continue':
          if (state.step === 'whatsGoingOn') go('selectSituation');
          else if (state.step === 'selectSituation') go('tell');
          break;
        case 'get-read': requestAnalysis(); break;
        case 'retry': requestAnalysis(); break;
        case 'reset': reset(); break;
        case 'curiosity':
          // Mirrors iOS: in this slice, curiosity returns to gather more context (no fake destination).
          reset();
          go('tell');
          break;
      }
    });

    if (els.tellInput) {
      els.tellInput.addEventListener('input', function (e) {
        state.tellText = e.target.value;
        updateTellGuidance();
        els.getReadBtn.disabled = !canContinueFromTell();
      });
    }

    // Keyboard: Enter to advance primary action where appropriate; Esc to reset on result.
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && state.step === 'result') reset();
    });
  }

  function bindDynamicActions() {
    // Dynamic result buttons are handled by the delegated body listener above.
  }

  function bindDevControls() {
    var devStateRow = $('#dev-state-row');
    devStateRow.addEventListener('click', function (e) {
      var b = e.target.closest('[data-jump]');
      if (!b) return;
      handleJump(b.dataset.jump);
    });

    // Other jump buttons (result-no-tell, failed, reset) outside the state row.
    $$('.dev-btn[data-jump]').forEach(function (b) {
      if (b.closest('#dev-state-row')) return;
      b.addEventListener('click', function () { handleJump(b.dataset.jump); });
    });

    var reducedBtn = $('#dev-reduced-motion');
    reducedBtn.addEventListener('click', function () {
      var pressed = reducedBtn.getAttribute('aria-pressed') === 'true';
      reducedBtn.setAttribute('aria-pressed', String(!pressed));
      document.body.classList.toggle('force-reduced-motion', !pressed);
    });
  }

  function handleJump(target) {
    switch (target) {
      case 'launch': reset(); break;
      case 'whatsGoingOn':
        reset(); go('whatsGoingOn'); break;
      case 'selectSituation':
        reset(); state.selectedSituation = SITUATIONS[0].id; go('selectSituation');
        updateSituationSelection(); render(); break;
      case 'tell':
        reset(); state.selectedSituation = SITUATIONS[0].id;
        state.tellText = 'We\u2019ve been talking for a few weeks but plans keep getting vague.';
        go('tell'); updateSituationSelection(); render(); break;
      case 'loading':
        state.resultMode = 'loading'; go('loading'); break;
      case 'result':
        state.tellText = 'We\u2019ve been talking for a few weeks but plans keep getting vague.';
        state.result = mockAnalyze(state.tellText); state.resultMode = 'loaded'; go('result'); break;
      case 'result-no-tell':
        state.tellText = ''; state.result = mockAnalyze(null); state.resultMode = 'loaded';
        go('result'); break;
      case 'failed':
        state.resultMode = 'failed';
        state.failureMessage = 'We couldn\u2019t reach the read right now. Try again in a moment.';
        go('result'); break;
      case 'reset': reset(); break;
    }
  }

  function updateDevActiveState() {
    $$('.dev-btn[data-jump]').forEach(function (b) {
      var j = b.dataset.jump;
      var active = false;
      if (j === state.step) active = true;
      if (j === 'result-no-tell' && state.step === 'result' && state.result && state.result.result.overallConfidence === 'low') active = true;
      if (j === 'failed' && state.step === 'result' && state.resultMode === 'failed') active = true;
      b.setAttribute('aria-pressed', active ? 'true' : 'false');
    });
  }

  // ---- Small helpers ----

  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
  function escapeAttr(s) { return escapeHtml(s); }

  if (typeof window !== 'undefined') {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
    } else {
      init();
    }
    window.UNSTUCK_PREVIEW = { state: state, mockAnalyze: mockAnalyze, reset: reset };
  }

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { canContinueFromTell: canContinueFromTell, STEPS: STEPS };
  }
})();
