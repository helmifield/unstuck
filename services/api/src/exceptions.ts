import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * Centralized error handling.
 *
 * Never exposes sensitive information in error messages (docs/SECURITY.md).
 * Returns a generic message for unexpected errors; preserves the NestJS
 * exception message only for known HTTP errors where the message is safe.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const body = exception.getResponse();
      message =
        typeof body === 'string'
          ? body
          : (body as { message?: unknown }).message?.toString() ?? exception.message;
    } else if (exception instanceof Error) {
      // Do not leak internal error text to clients.
      message = 'Internal server error';
    }

    // Audit log without secrets/path params; query/body never logged.
    const audit = {
      method: req.method,
      path: req.path,
      status,
      hasException: !!exception,
    };
    // Logging is performed via injected logger elsewhere; keep filter pure here.
    // The global logger is surfaced in main.ts; for audit we write to stderr.
    process.stderr.write(
      JSON.stringify({ level: 'error', service: 'api', msg: 'request_error', ...audit }) + '\n',
    );

    res.status(status).json({ statusCode: status, message });
  }
}
