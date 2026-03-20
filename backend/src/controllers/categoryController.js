const { validateCategoryPayload } = require('../models/categoryModel');
const categoryService = require('../services/categoryService');

async function getCategories(req, res) {
  const categories = await categoryService.listCategories(req.user.id);
  res.status(200).json({ data: categories });
}

async function createCategory(req, res) {
  const validation = validateCategoryPayload(req.body);

  if (!validation.isValid) {
    return res.status(400).json({ message: 'Validation failed', errors: validation.errors });
  }

  const category = await categoryService.createCategory(validation.sanitized, req.user.id);
  return res.status(201).json({ data: category });
}

async function deleteCategory(req, res) {
  await categoryService.deleteCategory(req.params.id, req.user.id);
  return res.status(204).send();
}

module.exports = {
  getCategories,
  createCategory,
  deleteCategory,
};
