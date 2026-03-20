const { CATEGORY_ICON_KEYS } = require('../constants/categoryIcons');

function validateCategoryPayload(payload) {
  const errors = {};
  const sanitized = {};
  const allowedIconKeys = new Set(CATEGORY_ICON_KEYS);

  if (typeof payload.name !== 'string' || payload.name.trim().length < 2) {
    errors.name = 'Category name must be at least 2 characters';
  } else if (payload.name.trim().length > 40) {
    errors.name = 'Category name must be less than 40 characters';
  } else {
    sanitized.name = payload.name.trim();
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'color')) {
    if (typeof payload.color !== 'string' || !/^#[0-9A-Fa-f]{6}$/.test(payload.color)) {
      errors.color = 'Color must be a valid hex value like #4CAF50';
    } else {
      sanitized.color = payload.color;
    }
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'icon')) {
    if (typeof payload.icon !== 'string' || payload.icon.trim().length === 0) {
      errors.icon = 'Icon must be a non-empty string';
    } else if (!allowedIconKeys.has(payload.icon.trim())) {
      errors.icon = `Icon is invalid. Allowed icons: ${CATEGORY_ICON_KEYS.join(', ')}`;
    } else {
      sanitized.icon = payload.icon.trim();
    }
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    sanitized,
  };
}

module.exports = {
  validateCategoryPayload,
};
