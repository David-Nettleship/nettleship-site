'use strict';

const AUTH_USER = 'nettleship';
const AUTH_PASS = '${password}';

exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;

  const authHeader = headers['authorization'];
  if (authHeader) {
    const b64 = authHeader[0].value.replace(/^Basic\s+/, '');
    const [user, ...rest] = Buffer.from(b64, 'base64').toString('utf-8').split(':');
    const pass = rest.join(':'); // handle passwords containing colons
    if (user === AUTH_USER && pass === AUTH_PASS) {
      callback(null, request);
      return;
    }
  }

  callback(null, {
    status: '401',
    statusDescription: 'Unauthorized',
    headers: {
      'www-authenticate': [{ key: 'WWW-Authenticate', value: 'Basic realm="Nettleship Family Site"' }],
      'cache-control': [{ key: 'Cache-Control', value: 'no-store' }],
    },
  });
};
