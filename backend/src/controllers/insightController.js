const insightService = require('../services/insightService');

async function getMonthlyInsight(req, res) {
  const insight = await insightService.getMonthlyInsight(req.user.id);
  res.status(200).json({ data: insight });
}

async function getCategoryInsight(req, res) {
  const insight = await insightService.getCategoryInsight(req.user.id);
  res.status(200).json({ data: insight });
}

async function getDailyAverageInsight(req, res) {
  const insight = await insightService.getDailyAverageInsight(req.user.id);
  res.status(200).json({ data: insight });
}

async function getTopDayInsight(req, res) {
  const insight = await insightService.getTopDayInsight(req.user.id);
  res.status(200).json({ data: insight });
}

module.exports = {
  getMonthlyInsight,
  getCategoryInsight,
  getDailyAverageInsight,
  getTopDayInsight,
};
