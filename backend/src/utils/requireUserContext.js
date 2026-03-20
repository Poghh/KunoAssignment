const { get } = require('../services/sqlite');
const HttpError = require('../models/httpError');

async function requireUserContext(req, _res, next) {
  const rawUsername = req.header('x-username');
  const username = typeof rawUsername === 'string' ? rawUsername.trim() : '';

  if (username.length < 2) {
    throw new HttpError(401, 'Missing user context');
  }

  const user = await get(
    `
      SELECT id, username, display_name
      FROM users
      WHERE username = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [username],
  );

  if (!user) {
    throw new HttpError(401, 'Invalid user context');
  }

  req.user = {
    id: user.id,
    username: user.username,
    displayName: user.display_name || '',
  };
  next();
}

module.exports = requireUserContext;
