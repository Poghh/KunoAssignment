const { Router } = require('express');

const expenseController = require('../controllers/expenseController');
const asyncHandler = require('../utils/asyncHandler');
const requireUserContext = require('../utils/requireUserContext');

const router = Router();
router.use(asyncHandler(requireUserContext));

router.get('/', asyncHandler(expenseController.getExpenses));
router.post('/', asyncHandler(expenseController.createExpense));
router.put('/:id', asyncHandler(expenseController.updateExpense));
router.delete('/:id', asyncHandler(expenseController.deleteExpense));

module.exports = router;
