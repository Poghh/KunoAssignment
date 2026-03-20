const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

function isValidDateString(value) {
  if (!DATE_PATTERN.test(value)) {
    return false;
  }

  const parsed = new Date(`${value}T00:00:00`);
  return !Number.isNaN(parsed.getTime());
}

function validateExpensePayload(payload, options = {}) {
  const { isUpdate = false } = options;
  const errors = {};
  const sanitized = {};
  const supportedCurrencies = new Set(['USD', 'VND']);

  if (isUpdate && Object.keys(payload).length === 0) {
    errors.body = 'At least one field is required for update';
  }

  if (!isUpdate || Object.prototype.hasOwnProperty.call(payload, 'title')) {
    if (typeof payload.title !== 'string' || payload.title.trim().length < 2) {
      errors.title = 'Title must be at least 2 characters';
    } else if (payload.title.trim().length > 80) {
      errors.title = 'Title must be less than 80 characters';
    } else {
      sanitized.title = payload.title.trim();
    }
  }

  if (!isUpdate || Object.prototype.hasOwnProperty.call(payload, 'amount')) {
    const amount = Number(payload.amount);
    if (!Number.isFinite(amount) || amount === 0) {
      errors.amount = 'Amount must be a non-zero number';
    } else {
      sanitized.amount = Number(amount.toFixed(2));
    }
  }

  if (!isUpdate || Object.prototype.hasOwnProperty.call(payload, 'currencyCode')) {
    const rawCurrency =
      payload.currencyCode == null ? 'USD' : String(payload.currencyCode).trim().toUpperCase();
    if (!supportedCurrencies.has(rawCurrency)) {
      errors.currencyCode = 'Currency code must be USD or VND';
    } else {
      sanitized.currencyCode = rawCurrency;
    }
  }

  if (!isUpdate || Object.prototype.hasOwnProperty.call(payload, 'date')) {
    if (typeof payload.date !== 'string' || !isValidDateString(payload.date)) {
      errors.date = 'Date must be in YYYY-MM-DD format';
    } else {
      sanitized.date = payload.date;
    }
  }

  if (!isUpdate || Object.prototype.hasOwnProperty.call(payload, 'categoryId')) {
    if (typeof payload.categoryId !== 'string' || payload.categoryId.trim().length === 0) {
      errors.categoryId = 'Category is required';
    } else {
      sanitized.categoryId = payload.categoryId.trim();
    }
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'notes')) {
    if (payload.notes != null && typeof payload.notes !== 'string') {
      errors.notes = 'Notes must be a string';
    } else if (typeof payload.notes === 'string' && payload.notes.length > 300) {
      errors.notes = 'Notes must be less than 300 characters';
    } else {
      sanitized.notes = payload.notes ? payload.notes.trim() : null;
    }
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    sanitized,
  };
}

module.exports = {
  validateExpensePayload,
};
