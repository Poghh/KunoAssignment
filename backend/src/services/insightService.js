const { all } = require('./sqlite');

function toDate(dateValue) {
  return new Date(`${dateValue}T00:00:00`);
}

function getMonthRange(referenceDate = new Date()) {
  const monthStart = new Date(referenceDate.getFullYear(), referenceDate.getMonth(), 1);
  const nextMonthStart = new Date(referenceDate.getFullYear(), referenceDate.getMonth() + 1, 1);
  return { monthStart, nextMonthStart };
}

function filterByDateRange(expenses, startDate, endDate) {
  return expenses.filter((expense) => {
    const date = toDate(expense.date);
    return date >= startDate && date < endDate;
  });
}

function onlyExpenseRecords(expenses) {
  return expenses.filter((expense) => Number(expense.amount) > 0);
}

function getTotal(expenses) {
  return Number(expenses.reduce((sum, item) => sum + item.amount, 0).toFixed(2));
}

async function readInsightSource(userId) {
  const [categories, expenses] = await Promise.all([
    all(
      `
        SELECT id, name, color, icon
        FROM categories
        WHERE user_id = ?
      `,
      [userId],
    ),
    all(
      `
        SELECT
          id,
          title,
          amount_in_base AS amount,
          date,
          category_id AS categoryId,
          notes,
          created_at AS createdAt,
          updated_at AS updatedAt
        FROM expenses
        WHERE user_id = ?
      `,
      [userId],
    ),
  ]);

  return {
    categories: categories.map((item) => ({
      id: item.id,
      name: item.name,
      color: item.color,
      icon: item.icon,
    })),
    expenses: expenses.map((item) => ({
      id: item.id,
      title: item.title,
      amount: Number(item.amount),
      date: item.date,
      categoryId: item.categoryId,
      notes: item.notes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    })),
  };
}

async function getMonthlyInsight(userId) {
  const data = await readInsightSource(userId);
  const now = new Date();

  const { monthStart, nextMonthStart } = getMonthRange(now);
  const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);

  const thisMonthExpenses = onlyExpenseRecords(
    filterByDateRange(data.expenses, monthStart, nextMonthStart),
  );
  const lastMonthExpenses = onlyExpenseRecords(
    filterByDateRange(data.expenses, lastMonthStart, monthStart),
  );

  const totalThisMonth = getTotal(thisMonthExpenses);
  const totalLastMonth = getTotal(lastMonthExpenses);

  let percentageChange = 0;
  if (totalLastMonth === 0 && totalThisMonth > 0) {
    percentageChange = 100;
  } else if (totalLastMonth > 0) {
    percentageChange = Number(
      (((totalThisMonth - totalLastMonth) / totalLastMonth) * 100).toFixed(2),
    );
  }

  return {
    month: monthStart.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
    totalThisMonth,
    totalLastMonth,
    percentageChange,
  };
}

async function getCategoryInsight(userId) {
  const data = await readInsightSource(userId);
  const now = new Date();
  const { monthStart, nextMonthStart } = getMonthRange(now);

  const thisMonthExpenses = onlyExpenseRecords(
    filterByDateRange(data.expenses, monthStart, nextMonthStart),
  );

  if (thisMonthExpenses.length === 0) {
    return {
      mostSpentCategory: null,
      total: 0,
      percentageOfMonth: 0,
    };
  }

  const grouped = thisMonthExpenses.reduce((acc, expense) => {
    acc[expense.categoryId] = (acc[expense.categoryId] || 0) + expense.amount;
    return acc;
  }, {});

  const [categoryId, categoryTotal] = Object.entries(grouped).sort((a, b) => b[1] - a[1])[0];

  const category = data.categories.find((item) => item.id === categoryId);
  const monthTotal = getTotal(thisMonthExpenses);

  return {
    mostSpentCategory: {
      id: categoryId,
      name: category ? category.name : 'Unknown',
      color: category ? category.color : '#9E9E9E',
      total: Number(categoryTotal.toFixed(2)),
    },
    total: monthTotal,
    percentageOfMonth:
      monthTotal === 0 ? 0 : Number(((Number(categoryTotal) / monthTotal) * 100).toFixed(2)),
  };
}

async function getDailyAverageInsight(userId) {
  const data = await readInsightSource(userId);
  const now = new Date();
  const { monthStart, nextMonthStart } = getMonthRange(now);

  const thisMonthExpenses = onlyExpenseRecords(
    filterByDateRange(data.expenses, monthStart, nextMonthStart),
  );
  const totalThisMonth = getTotal(thisMonthExpenses);
  const daysElapsed = now.getDate();

  const uniqueExpenseDays = new Set(thisMonthExpenses.map((expense) => expense.date));

  return {
    dailyAverage: daysElapsed === 0 ? 0 : Number((totalThisMonth / daysElapsed).toFixed(2)),
    totalThisMonth,
    daysElapsed,
    activeExpenseDays: uniqueExpenseDays.size,
  };
}

async function getTopDayInsight(userId) {
  const data = await readInsightSource(userId);
  const now = new Date();
  const { monthStart, nextMonthStart } = getMonthRange(now);

  const thisMonthExpenses = onlyExpenseRecords(
    filterByDateRange(data.expenses, monthStart, nextMonthStart),
  );

  if (thisMonthExpenses.length === 0) {
    return {
      topDay: null,
      total: 0,
    };
  }

  const groupedByDay = thisMonthExpenses.reduce((acc, expense) => {
    acc[expense.date] = (acc[expense.date] || 0) + expense.amount;
    return acc;
  }, {});

  const [topDay, total] = Object.entries(groupedByDay).sort((a, b) => b[1] - a[1])[0];

  return {
    topDay,
    weekday: toDate(topDay).toLocaleDateString('en-US', { weekday: 'long' }),
    total: Number(Number(total).toFixed(2)),
  };
}

module.exports = {
  getMonthlyInsight,
  getCategoryInsight,
  getDailyAverageInsight,
  getTopDayInsight,
};
