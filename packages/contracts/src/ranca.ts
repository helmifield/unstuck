import type { AnalysisResult } from './analysis.js';
import { z } from 'zod';

/**
 * Ranca is the orchestration boundary between UNSTUCK and AI providers
 * (docs/ARCHITECTURE.md). The client never contains private AI provider
 * credentials, and UNSTUCK must depend on this abstraction — never directly
 * on a specific provider (OpenAI, Anthropic, Google, …).
 *
 * This file defines ONLY the interface. No provider is embedded yet.
 * Concrete implementations will live behind the backend and receive provider
 * credentials server-side only.
 */

/**
 * Opaque, provider-agnostic request handed to Ranca.
 * Raw screenshots and raw conversations are temporary by default and must never
 * be persisted by the orchestrator beyond the request (docs/ARCHITECTURE.md).
 */
export interface RancaRequest {
  /** Free-form situation description ("Tell"), if provided. */
  readonly situation?: string;
  /** Whether the caller opted into optional conversation/screenshot ("Show"). */
  readonly hasConversationEvidence: boolean;
  /** Request id used for audit/tracing; never logged with raw content. */
  readonly requestId: string;
}

/**
 * Zod validation schema for `RancaRequest` (the API endpoint body).
 * Additive: validates input at the trust boundary (docs/SECURITY.md "input validation").
 * `situation` is bounded to prevent abusive payloads; it is never logged verbatim.
 */
export const RancaRequestSchema = z.object({
  situation: z.string().min(1).max(8000).optional(),
  hasConversationEvidence: z.boolean(),
  requestId: z.string().min(1).max(128),
});
export type RancaRequestParsed = z.infer<typeof RancaRequestSchema>;

/** A provider-agnostic orchestrator. Implementations are injected at runtime. */
export interface Ranca {
  /**
   * Produce an evidence-based, uncertainty-aware AnalysisResult.
   * Implementations MUST:
   *   - treat all user text/screenshots as untrusted input (prompt-injection defense),
   *   - never persist raw material beyond the request,
   *   - never allow conversation content to override UNSTUCK system policy.
   */
  analyze(request: RancaRequest): Promise<AnalysisResult>;
}

/**
 * Factory type used by the backend to obtain a Ranca instance from config,
 * keeping the interface decoupled from any concrete provider.
 */
export type RancaFactory = (config: RancaProviderConfig) => Ranca;

/** Provider-agnostic config. Credentials live server-side only and are NEVER
 *  part of this type's serialized form. */
export interface RancaProviderConfig {
  readonly providerId: string;
  /** Secret reference (e.g. a secret-manager key), never the raw credential. */
  readonly credentialRef: string;
  readonly timeoutMs: number;
}

/** No-op stub used only as a type-checking placeholder. Not wired anywhere. */
export const RANCA_INTERFACE_VERSION = 1 as const;
