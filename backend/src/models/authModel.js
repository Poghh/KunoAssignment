function validateRegisterPayload(payload) {
  const errors = {};
  const sanitized = {};

  if (typeof payload.username !== 'string' || payload.username.trim().length < 2) {
    errors.username = 'Username must be at least 2 characters';
  } else if (payload.username.trim().length > 40) {
    errors.username = 'Username must be less than 40 characters';
  } else {
    sanitized.username = payload.username.trim();
  }

  if (typeof payload.password !== 'string' || payload.password.trim().length < 6) {
    errors.password = 'Password must be at least 6 characters';
  } else if (payload.password.trim().length > 120) {
    errors.password = 'Password must be less than 120 characters';
  } else {
    sanitized.password = payload.password.trim();
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    sanitized,
  };
}

function validateLoginPayload(payload) {
  const errors = {};
  const sanitized = {};

  if (typeof payload.username !== 'string' || payload.username.trim().length < 2) {
    errors.username = 'Username is invalid';
  } else {
    sanitized.username = payload.username.trim();
  }

  if (typeof payload.password !== 'string' || payload.password.trim().length < 6) {
    errors.password = 'Password is invalid';
  } else {
    sanitized.password = payload.password.trim();
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    sanitized,
  };
}

function validateDisplayNamePayload(payload) {
  const errors = {};
  const sanitized = {};

  if (typeof payload.username !== 'string' || payload.username.trim().length < 2) {
    errors.username = 'Username is required';
  } else {
    sanitized.username = payload.username.trim();
  }

  if (typeof payload.displayName !== 'string' || payload.displayName.trim().length < 2) {
    errors.displayName = 'Display name must be at least 2 characters';
  } else if (payload.displayName.trim().length > 60) {
    errors.displayName = 'Display name must be less than 60 characters';
  } else {
    sanitized.displayName = payload.displayName.trim();
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    sanitized,
  };
}

module.exports = {
  validateDisplayNamePayload,
  validateLoginPayload,
  validateRegisterPayload,
};
