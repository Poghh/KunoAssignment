const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function validateRegisterPayload(payload) {
  const errors = {};
  const sanitized = {};

  const email = typeof payload.email === 'string' ? payload.email.trim() : '';
  if (!EMAIL_REGEX.test(email)) {
    errors.email = 'Enter a valid email address';
  } else if (email.length > 254) {
    errors.email = 'Email must be less than 254 characters';
  } else {
    sanitized.email = email;
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

  const email = typeof payload.email === 'string' ? payload.email.trim() : '';
  if (!EMAIL_REGEX.test(email)) {
    errors.email = 'Enter a valid email address';
  } else {
    sanitized.email = email;
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

  const email = typeof payload.email === 'string' ? payload.email.trim() : '';
  if (!EMAIL_REGEX.test(email)) {
    errors.email = 'Email is required';
  } else {
    sanitized.email = email;
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
