const { Router } = require('express');

const categoryController = require('../controllers/categoryController');
const asyncHandler = require('../utils/asyncHandler');
const requireUserContext = require('../utils/requireUserContext');

const router = Router();
router.use(asyncHandler(requireUserContext));

router.get('/', asyncHandler(categoryController.getCategories));
router.post('/', asyncHandler(categoryController.createCategory));
router.delete('/:id', asyncHandler(categoryController.deleteCategory));

module.exports = router;
