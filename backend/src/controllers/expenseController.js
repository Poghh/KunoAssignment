const { validateExpensePayload } = require('../models/expenseModel');
const expenseService = require('../services/expenseService');

async function getExpenses(req, res) {
  const expenses = await expenseService.listExpenses(req.query, req.user.id);
  res.status(200).json({ data: expenses });
}

async function createExpense(req, res) {
  const validation = validateExpensePayload(req.body);

  if (!validation.isValid) {
    return res.status(400).json({ message: 'Validation failed', errors: validation.errors });
  }

  const createdExpense = await expenseService.createExpense(
    validation.sanitized,
    req.user.id,
  );
  return res.status(201).json({ data: createdExpense });
}

async function updateExpense(req, res) {
  const validation = validateExpensePayload(req.body, { isUpdate: true });

  if (!validation.isValid) {
    return res.status(400).json({ message: 'Validation failed', errors: validation.errors });
  }

  const updatedExpense = await expenseService.updateExpense(
    req.params.id,
    validation.sanitized,
    req.user.id,
  );
  return res.status(200).json({ data: updatedExpense });
}

async function deleteExpense(req, res) {
  await expenseService.deleteExpense(req.params.id, req.user.id);
  return res.status(204).send();
}

module.exports = {
  getExpenses,
  createExpense,
  updateExpense,
  deleteExpense,
};
