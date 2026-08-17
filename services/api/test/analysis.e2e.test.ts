import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { AppModule } from '../src/app.module.js';
import { AllExceptionsFilter } from '../src/exceptions.js';

/**
 * Analysis endpoint integration tests. Confirms the iOS→API→Ranca-boundary→analysis
 * contract path: input validation at the trust boundary, the dev-safe mock provider
 * behind the Ranca boundary, and a contract-valid AnalysisResult. The user's free-form
 * text is never asserted to be echoed back (privacy: no raw conversation in responses).
 */
describe('POST /analysis (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = module.createNestApplication();
    app.useGlobalFilters(new AllExceptionsFilter());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns 200 with a contract-valid AnalysisResult for a Tell-only request', async () => {
    const res = await request(app.getHttpServer())
      .post('/analysis')
      .send({
        situation: 'We have been talking for a few weeks but plans keep getting vague.',
        hasConversationEvidence: false,
        requestId: 'test-req-1',
      })
      .expect(200);

    const body = res.body;
    expect(typeof body.read).toBe('string');
    expect(body.read.length).toBeGreaterThan(0);
    expect(Array.isArray(body.signals)).toBe(true);
    expect(body.signals.length).toBeGreaterThan(0);
    for (const s of body.signals) {
      expect(typeof s.name).toBe('string');
      expect(typeof s.reading).toBe('string');
      expect(['high', 'medium', 'low']).toContain(s.confidence);
      expect(typeof s.evidence).toBe('string');
      expect(s.evidence.length).toBeGreaterThan(0);
    }
    expect(Array.isArray(body.doesNotMean)).toBe(true);
    expect(typeof body.nextMove).toBe('string');
    expect(['high', 'medium', 'low']).toContain(body.overallConfidence);
    // Privacy: the user's situation text must not be echoed back in the response.
    expect(JSON.stringify(body)).not.toContain('plans keep getting vague');
  });

  it('returns 200 with a low-confidence read when no Tell is provided', async () => {
    const res = await request(app.getHttpServer())
      .post('/analysis')
      .send({ hasConversationEvidence: false, requestId: 'test-req-2' })
      .expect(200);
    expect(res.body.overallConfidence).toBe('low');
  });

  it('rejects an invalid request body with 400', async () => {
    await request(app.getHttpServer())
      .post('/analysis')
      .send({ hasConversationEvidence: false }) // missing requestId
      .expect(400);
  });

  it('rejects an oversized situation payload with 400', async () => {
    await request(app.getHttpServer())
      .post('/analysis')
      .send({
        situation: 'x'.repeat(8001),
        hasConversationEvidence: false,
        requestId: 'test-req-3',
      })
      .expect(400);
  });

  it('applies security headers to the analysis route', async () => {
    const res = await request(app.getHttpServer())
      .post('/analysis')
      .send({ hasConversationEvidence: false, requestId: 'test-req-4' });
    expect(res.headers['x-content-type-options']).toBe('nosniff');
    expect(res.headers['cache-control']).toBe('no-store');
  });
});
