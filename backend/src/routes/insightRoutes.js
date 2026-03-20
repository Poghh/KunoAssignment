const { Router } = require('express');

const insightController = require('../controllers/insightController');
const asyncHandler = require('../utils/asyncHandler');
const requireUserContext = require('../utils/requireUserContext');

const router = Router();
router.use(asyncHandler(requireUserContext));

router.get('/monthly', asyncHandler(insightController.getMonthlyInsight));
router.get('/category', asyncHandler(insightController.getCategoryInsight));
router.get('/daily-average', asyncHandler(insightController.getDailyAverageInsight));
router.get('/top-day', asyncHandler(insightController.getTopDayInsight));

module.exports = router;
