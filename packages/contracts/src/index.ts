/**
 * UNSTUCK shared contracts.
 *
 * This package is the single source of truth that keeps the iOS client and the
 * NestJS backend strongly aligned. It intentionally contains NO product features:
 * only the foundational request/response shapes, confidence levels, and the
 * Ranca AI orchestration abstraction that UNSTUCK will eventually call.
 *
 * Everything here is a contract, not an implementation.
 */

export * from './health.js';
export * from './analysis.js';
export * from './ranca.js';
