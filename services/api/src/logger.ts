import { LoggerService } from '@nestjs/common';

/**
 * Minimal structured logger.
 *
 * Security: never logs raw chat content, screenshots, secrets, access tokens,
 * or unnecessary personal data (docs/SECURITY.md). Only structured fields that
 * are safe for audit purposes.
 */
export class StructuredLogger implements LoggerService {
  private static levelRank: Record<string, number> = {
    fatal: 0,
    error: 1,
    warn: 2,
    info: 3,
    debug: 4,
    trace: 5,
  };

  constructor(
    private readonly level: string,
    private readonly service = 'api',
  ) {}

  private enabled(lvl: string): boolean {
    const max = StructuredLogger.levelRank[this.level] ?? 3;
    return (StructuredLogger.levelRank[lvl] ?? 3) <= max;
  }

  private emit(lvl: string, msg: string, meta?: Record<string, unknown>): void {
    if (!this.enabled(lvl)) return;
    const line = JSON.stringify({
      level: lvl,
      service: this.service,
      msg,
      ts: new Date().toISOString(),
      ...meta,
    });
    if (lvl === 'error' || lvl === 'fatal') {
      process.stderr.write(line + '\n');
    } else {
      process.stdout.write(line + '\n');
    }
  }

  log(msg: string, meta?: Record<string, unknown>): void {
    this.emit('info', msg, meta);
  }
  error(msg: string, meta?: Record<string, unknown>): void {
    this.emit('error', msg, meta);
  }
  warn(msg: string, meta?: Record<string, unknown>): void {
    this.emit('warn', msg, meta);
  }
  debug(msg: string, meta?: Record<string, unknown>): void {
    this.emit('debug', msg, meta);
  }
  verbose(msg: string, meta?: Record<string, unknown>): void {
    this.emit('trace', msg, meta);
  }
  fatal(msg: string, meta?: Record<string, unknown>): void {
    this.emit('fatal', msg, meta);
  }
}
