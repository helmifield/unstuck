/**
 * UNSTUCK — Visual QA preview server.
 *
 * Zero-dependency static file server (Node 20+ built-ins only) for the isolated
 * visual-QA preview. Serves only the files under tools/visual-preview/. It makes NO
 * network calls, reads NO secrets, and is NOT part of the product or any workspace.
 *
 * Usage:  node tools/visual-preview/server.js [port]
 * Default port: 4173  (override with the first arg or PORT env var).
 */

'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const PORT = Number(process.argv[2] || process.env.PORT || 4173);

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.json': 'application/json; charset=utf-8',
  '.ico': 'image/x-icon',
  '.map': 'application/json; charset=utf-8',
};

// Allow only these files; everything else 404s. Keeps the tool tightly scoped.
const ALLOWED = new Set(['index.html', 'styles.css', 'app.js', 'mock.js']);

function safeJoin(file) {
  const resolved = path.resolve(ROOT, file);
  if (resolved !== ROOT && !resolved.startsWith(ROOT + path.sep)) return null; // no traversal
  const base = path.basename(resolved);
  return ALLOWED.has(base) ? resolved : null;
}

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent((req.url || '/').split('?')[0]);
  let file = urlPath === '/' ? 'index.html' : urlPath.replace(/^\/+/, '');
  const filePath = safeJoin(file);
  if (!filePath) {
    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('404 Not Found');
    return;
  }
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
      res.end('404 Not Found');
      return;
    }
    const ext = path.extname(filePath).toLowerCase();
    const headers = {
      'content-type': MIME[ext] || 'application/octet-stream',
      'cache-control': 'no-store',
      'x-content-type-options': 'nosniff',
      'x-frame-options': 'DENY',
      'referrer-policy': 'no-referrer',
    };
    res.writeHead(200, headers);
    res.end(data);
  });
});

server.listen(PORT, '127.0.0.1', () => {
  const url = `http://127.0.0.1:${PORT}/`;
  console.log('UNSTUCK visual QA preview (dev-only, mock data, no network)');
  console.log(`  Serving: ${ROOT}`);
  console.log(`  Open:     ${url}`);
  console.log('  Press Ctrl+C to stop.');
});

module.exports = server;
