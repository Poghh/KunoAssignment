const { get } = require('../services/sqlite');
const HttpError = require('../models/httpError');

async function requireUserContext(req, _res, next) {
  const rawEmail = req.header('x-username');
  const email = typeof rawEmail === 'string' ? rawEmail.trim() : '';

  if (email.length < 3) {
    throw new HttpError(401, 'Missing user context');
  }

  const user = await get(
    `
      SELECT id, email, display_name
      FROM users
      WHERE email = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [email],
  );

  if (!user) {
    throw new HttpError(401, 'Invalid user context');
  }

  req.user = {
    id: user.id,
    email: user.email,
    displayName: user.display_name || '',
  };
  next();
}

module.exports = requireUserContext;
