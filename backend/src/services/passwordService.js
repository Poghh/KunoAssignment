const { randomBytes, scrypt: scryptCallback, timingSafeEqual } = require('node:crypto');
const { promisify } = require('node:util');

const scrypt = promisify(scryptCallback);
const HASH_PREFIX = 'scrypt';
const KEY_LENGTH = 64;
const SCRYPT_OPTIONS = {
  N: 16384,
  r: 8,
  p: 1,
  maxmem: 32 * 1024 * 1024,
};

async function hashPassword(password) {
  const salt = randomBytes(16).toString('base64url');
  const derivedKey = await scrypt(password, salt, KEY_LENGTH, SCRYPT_OPTIONS);
  return `${HASH_PREFIX}$${salt}$${Buffer.from(derivedKey).toString('base64url')}`;
}

async function verifyPassword({
  password,
  storedPassword,
}) {
  if (typeof password !== 'string' || typeof storedPassword !== 'string') {
    return false;
  }

  if (!isPasswordHash(storedPassword)) {
    return password === storedPassword;
  }

  const parts = storedPassword.split('$');
  if (parts.length !== 3) {
    return false;
  }

  try {
    const salt = parts[1];
    const storedHash = parts[2];
    const derivedKey = await scrypt(password, salt, KEY_LENGTH, SCRYPT_OPTIONS);
    const storedHashBuffer = Buffer.from(storedHash, 'base64url');
    const derivedBuffer = Buffer.from(derivedKey);

    if (storedHashBuffer.length !== derivedBuffer.length) {
      return false;
    }

    return timingSafeEqual(storedHashBuffer, derivedBuffer);
  } catch (_) {
    return false;
  }
}

function isPasswordHash(value) {
  return typeof value === 'string' && value.startsWith(`${HASH_PREFIX}$`);
}

module.exports = {
  hashPassword,
  isPasswordHash,
  verifyPassword,
};
