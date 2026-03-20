const {
  validateDisplayNamePayload,
  validateLoginPayload,
  validateRegisterPayload,
} = require('../models/authModel');
const authService = require('../services/authService');

async function register(req, res) {
  const validation = validateRegisterPayload(req.body);

  if (!validation.isValid) {
    return res.status(400).json({ message: 'Validation failed', errors: validation.errors });
  }

  const user = await authService.registerUser(validation.sanitized);
  return res.status(201).json({ data: user });
}

async function login(req, res) {
  const validation = validateLoginPayload(req.body);

  if (!validation.isValid) {
    return res.status(400).json({ message: 'Validation failed', errors: validation.errors });
  }

  const user = await authService.loginUser(validation.sanitized);
  return res.status(200).json({ data: user });
}

async function getProfile(req, res) {
  const username = typeof req.params.username === 'string' ? req.params.username.trim() : '';
  if (username.length < 2) {
    return res.status(400).json({ message: 'Validation failed', errors: { username: 'Username is required' } });
  }

  const user = await authService.getUserProfile(username);
  return res.status(200).json({ data: user });
}

async function updateProfileDisplayName(req, res) {
  const validation = validateDisplayNamePayload(req.body);

  if (!validation.isValid) {
    return res.status(400).json({ message: 'Validation failed', errors: validation.errors });
  }

  const user = await authService.updateDisplayName(validation.sanitized);
  return res.status(200).json({ data: user });
}

module.exports = {
  getProfile,
  login,
  register,
  updateProfileDisplayName,
};
