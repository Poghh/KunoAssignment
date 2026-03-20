const { randomUUID } = require('node:crypto');

const { all, get, run } = require('./sqlite');
const {
  convertToBaseAmount,
  normalizeCurrencyCode,
  resolveRateSnapshot,
} = require('./exchangeRateService');
const HttpError = require('../models/httpError');

async function listExpenses(filters = {}, userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const conditions = ['user_id = ?'];
  const params = [userId];

  if (typeof filters.categoryId === 'string' && filters.categoryId.trim().length > 0) {
    conditions.push('category_id = ?');
    params.push(filters.categoryId.trim());
  }

  if (typeof filters.startDate === 'string' && filters.startDate.trim().length > 0) {
    conditions.push('date >= ?');
    params.push(filters.startDate.trim());
  }

  if (typeof filters.endDate === 'string' && filters.endDate.trim().length > 0) {
    conditions.push('date <= ?');
    params.push(filters.endDate.trim());
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const rows = await all(
    `
      SELECT
        id,
        title,
        amount,
        currency_code,
        fx_rate_snapshot,
        amount_in_base,
        date,
        category_id,
        notes,
        created_at,
        updated_at
      FROM expenses
      ${whereClause}
      ORDER BY date DESC, created_at DESC
    `,
    params,
  );

  return rows.map(toExpenseResponse);
}

async function createExpense(payload, userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const category = await get('SELECT id FROM categories WHERE id = ? AND user_id = ?', [
    payload.categoryId,
    userId,
  ]);

  if (!category) {
    throw new HttpError(400, 'Invalid categoryId');
  }

  const timestamp = new Date().toISOString();
  const expenseId = randomUUID();
  const currencyCode = resolveCurrencyCode(payload.currencyCode);
  const fxRateSnapshot = resolveRateSnapshot({
    currencyCode,
    date: payload.date,
  });
  const amountInBase = convertToBaseAmount({
    amount: payload.amount,
    currencyCode,
    rateSnapshot: fxRateSnapshot,
  });

  await run(
    `
      INSERT INTO expenses (
        id,
        user_id,
        title,
        amount,
        currency_code,
        fx_rate_snapshot,
        amount_in_base,
        date,
        category_id,
        notes,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `,
    [
      expenseId,
      userId,
      payload.title,
      payload.amount,
      currencyCode,
      fxRateSnapshot,
      amountInBase,
      payload.date,
      payload.categoryId,
      payload.notes || null,
      timestamp,
      timestamp,
    ],
  );

  const created = await get(
    `
      SELECT
        id,
        title,
        amount,
        currency_code,
        fx_rate_snapshot,
        amount_in_base,
        date,
        category_id,
        notes,
        created_at,
        updated_at
      FROM expenses
      WHERE id = ? AND user_id = ?
    `,
    [expenseId, userId],
  );

  return toExpenseResponse(created);
}

async function updateExpense(expenseId, payload, userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const existing = await get(
    `
      SELECT
        id,
        amount,
        currency_code,
        fx_rate_snapshot,
        date
      FROM expenses
      WHERE id = ? AND user_id = ?
    `,
    [expenseId, userId],
  );

  if (!existing) {
    throw new HttpError(404, 'Expense not found');
  }

  if (payload.categoryId) {
    const category = await get('SELECT id FROM categories WHERE id = ? AND user_id = ?', [
      payload.categoryId,
      userId,
    ]);
    if (!category) {
      throw new HttpError(400, 'Invalid categoryId');
    }
  }

  const fields = [];
  const params = [];
  const timestamp = new Date().toISOString();
  let nextAmount = Number(existing.amount);
  let nextCurrencyCode = existing.currency_code || 'USD';
  let nextDate = existing.date;
  let shouldRecalculateBase = false;

  if (Object.prototype.hasOwnProperty.call(payload, 'title')) {
    fields.push('title = ?');
    params.push(payload.title);
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'amount')) {
    fields.push('amount = ?');
    params.push(payload.amount);
    nextAmount = payload.amount;
    shouldRecalculateBase = true;
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'currencyCode')) {
    nextCurrencyCode = resolveCurrencyCode(payload.currencyCode);
    fields.push('currency_code = ?');
    params.push(nextCurrencyCode);
    shouldRecalculateBase = true;
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'date')) {
    fields.push('date = ?');
    params.push(payload.date);
    nextDate = payload.date;
    shouldRecalculateBase = true;
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'categoryId')) {
    fields.push('category_id = ?');
    params.push(payload.categoryId);
  }

  if (Object.prototype.hasOwnProperty.call(payload, 'notes')) {
    fields.push('notes = ?');
    params.push(payload.notes || null);
  }

  if (shouldRecalculateBase) {
    const fxRateSnapshot = resolveRateSnapshot({
      currencyCode: nextCurrencyCode,
      date: nextDate,
    });
    const amountInBase = convertToBaseAmount({
      amount: nextAmount,
      currencyCode: nextCurrencyCode,
      rateSnapshot: fxRateSnapshot,
    });

    fields.push('fx_rate_snapshot = ?');
    params.push(fxRateSnapshot);
    fields.push('amount_in_base = ?');
    params.push(amountInBase);
  }

  fields.push('updated_at = ?');
  params.push(timestamp, expenseId);

  await run(
    `
      UPDATE expenses
      SET ${fields.join(', ')}
      WHERE id = ? AND user_id = ?
    `,
    [...params, userId],
  );

  const updated = await get(
    `
      SELECT
        id,
        title,
        amount,
        currency_code,
        fx_rate_snapshot,
        amount_in_base,
        date,
        category_id,
        notes,
        created_at,
        updated_at
      FROM expenses
      WHERE id = ? AND user_id = ?
    `,
    [expenseId, userId],
  );

  return toExpenseResponse(updated);
}

async function deleteExpense(expenseId, userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const result = await run('DELETE FROM expenses WHERE id = ? AND user_id = ?', [
    expenseId,
    userId,
  ]);
  if (result.changes === 0) {
    throw new HttpError(404, 'Expense not found');
  }
}

function toExpenseResponse(row) {
  return {
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    amountInBase: Number(row.amount_in_base),
    currencyCode: row.currency_code,
    fxRateSnapshot: Number(row.fx_rate_snapshot),
    date: row.date,
    categoryId: row.category_id,
    notes: row.notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function resolveCurrencyCode(rawCode) {
  try {
    return normalizeCurrencyCode(rawCode || 'USD');
  } catch {
    throw new HttpError(400, 'Currency code must be USD or VND');
  }
}

module.exports = {
  listExpenses,
  createExpense,
  updateExpense,
  deleteExpense,
};
