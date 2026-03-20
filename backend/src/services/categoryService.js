const { randomUUID } = require('node:crypto');

const { all, get, run } = require('./sqlite');
const HttpError = require('../models/httpError');

async function listCategories(userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const rows = await all(
    `
      SELECT id, name, color, icon
      FROM categories
      WHERE user_id = ?
      ORDER BY rowid ASC
    `,
    [userId],
  );

  return rows.map((row) => ({
    id: row.id,
    name: row.name,
    color: row.color,
    icon: row.icon,
  }));
}

async function createCategory(payload, userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const existing = await get(
    'SELECT id FROM categories WHERE user_id = ? AND LOWER(name) = LOWER(?)',
    [userId, payload.name],
  );

  if (existing) {
    throw new HttpError(409, 'Category already exists');
  }

  const categoryId = randomUUID();
  const timestamp = new Date().toISOString();
  const newCategory = {
    id: categoryId,
    name: payload.name,
    color: payload.color || '#4CAF50',
    icon: payload.icon || 'category',
  };

  await run(
    `
      INSERT INTO categories (id, user_id, name, color, icon, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
    [
      newCategory.id,
      userId,
      newCategory.name,
      newCategory.color,
      newCategory.icon,
      timestamp,
      timestamp,
    ],
  );

  return newCategory;
}

async function deleteCategory(categoryId, userId) {
  if (!userId) {
    throw new HttpError(401, 'Missing user context');
  }

  const targetCategory = await get(
    'SELECT id FROM categories WHERE id = ? AND user_id = ?',
    [categoryId, userId],
  );
  if (!targetCategory) {
    throw new HttpError(404, 'Category not found');
  }

  const usageRow = await get(
    'SELECT COUNT(1) AS count FROM expenses WHERE user_id = ? AND category_id = ?',
    [userId, categoryId],
  );
  const usageCount = Number(usageRow?.count || 0);
  if (usageCount > 0) {
    throw new HttpError(409, 'Cannot delete category with existing transactions');
  }

  await run('DELETE FROM categories WHERE id = ? AND user_id = ?', [
    categoryId,
    userId,
  ]);
}

async function ensureCategoryExists(categoryId, userId) {
  const category = await get('SELECT id FROM categories WHERE id = ? AND user_id = ?', [
    categoryId,
    userId,
  ]);

  if (!category) {
    throw new HttpError(400, 'Invalid categoryId');
  }
}

module.exports = {
  listCategories,
  createCategory,
  deleteCategory,
  ensureCategoryExists,
};
