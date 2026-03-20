const { randomUUID } = require('node:crypto');

const { get, run } = require('./sqlite');
const { hashPassword, isPasswordHash, verifyPassword } = require('./passwordService');
const HttpError = require('../models/httpError');

async function registerUser(payload) {
  const existingUser = await get(
    `
      SELECT id
      FROM users
      WHERE username = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [payload.username],
  );

  if (existingUser) {
    throw new HttpError(409, 'Username already exists');
  }

  const userId = randomUUID();
  const timestamp = new Date().toISOString();
  const passwordHash = await hashPassword(payload.password);

  await run(
    `
      INSERT INTO users (id, username, password, display_name, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `,
    [userId, payload.username, passwordHash, '', timestamp, timestamp],
  );

  const createdUser = await getUserByUsername(payload.username);
  return toUserResponse(createdUser);
}

async function loginUser(payload) {
  const user = await getUserByUsername(payload.username);

  if (!user) {
    throw new HttpError(401, 'Invalid username or password');
  }

  const passwordValid = await verifyPassword({
    password: payload.password,
    storedPassword: user.password,
  });
  if (!passwordValid) {
    throw new HttpError(401, 'Invalid username or password');
  }

  if (!isPasswordHash(user.password)) {
    const timestamp = new Date().toISOString();
    const upgradedHash = await hashPassword(payload.password);
    await run(
      `
        UPDATE users
        SET password = ?, updated_at = ?
        WHERE id = ?
      `,
      [upgradedHash, timestamp, user.id],
    );
  }

  return toUserResponse(user);
}

async function updateDisplayName(payload) {
  const existing = await getUserByUsername(payload.username);

  if (!existing) {
    throw new HttpError(404, 'User not found');
  }

  const timestamp = new Date().toISOString();
  await run(
    `
      UPDATE users
      SET display_name = ?, updated_at = ?
      WHERE id = ?
    `,
    [payload.displayName, timestamp, existing.id],
  );

  const updated = await getUserByUsername(payload.username);
  return toUserResponse(updated);
}

async function getUserProfile(username) {
  const user = await getUserByUsername(username);

  if (!user) {
    throw new HttpError(404, 'User not found');
  }

  return toUserResponse(user);
}

async function getUserByUsername(username) {
  return get(
    `
      SELECT
        id,
        username,
        password,
        display_name,
        created_at,
        updated_at
      FROM users
      WHERE username = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [username],
  );
}

function toUserResponse(user) {
  return {
    id: user.id,
    username: user.username,
    displayName: user.display_name || '',
    createdAt: user.created_at,
    updatedAt: user.updated_at,
  };
}

module.exports = {
  getUserProfile,
  loginUser,
  registerUser,
  updateDisplayName,
};
