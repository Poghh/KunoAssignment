const { randomUUID } = require('node:crypto');

const { get, run } = require('./sqlite');
const { hashPassword, isPasswordHash, verifyPassword } = require('./passwordService');
const HttpError = require('../models/httpError');

async function registerUser(payload) {
  const existingUser = await get(
    `
      SELECT id
      FROM users
      WHERE email = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [payload.email],
  );

  if (existingUser) {
    throw new HttpError(409, 'Email already registered');
  }

  const userId = randomUUID();
  const timestamp = new Date().toISOString();
  const passwordHash = await hashPassword(payload.password);

  await run(
    `
      INSERT INTO users (id, email, password, display_name, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `,
    [userId, payload.email, passwordHash, '', timestamp, timestamp],
  );

  const createdUser = await getUserByEmail(payload.email);
  return toUserResponse(createdUser);
}

async function loginUser(payload) {
  const user = await getUserByEmail(payload.email);

  if (!user) {
    throw new HttpError(401, 'Invalid email or password');
  }

  const passwordValid = await verifyPassword({
    password: payload.password,
    storedPassword: user.password,
  });
  if (!passwordValid) {
    throw new HttpError(401, 'Invalid email or password');
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
  const existing = await getUserByEmail(payload.email);

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

  const updated = await getUserByEmail(payload.email);
  return toUserResponse(updated);
}

async function getUserProfile(email) {
  const user = await getUserByEmail(email);

  if (!user) {
    throw new HttpError(404, 'User not found');
  }

  return toUserResponse(user);
}

async function getUserByEmail(email) {
  return get(
    `
      SELECT
        id,
        email,
        password,
        display_name,
        created_at,
        updated_at
      FROM users
      WHERE email = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [email],
  );
}

function toUserResponse(user) {
  return {
    id: user.id,
    email: user.email,
    displayName: user.display_name || '',
    createdAt: user.created_at,
    updatedAt: user.updated_at,
  };
}

module.exports = {
  getUserByEmail,
  getUserProfile,
  loginUser,
  registerUser,
  updateDisplayName,
};
