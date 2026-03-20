const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const expenseRoutes = require('./routes/expenseRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const insightRoutes = require('./routes/insightRoutes');
const mailRoutes = require('./routes/mailRoutes');
const HttpError = require('./models/httpError');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use('/auth', authRoutes);
app.use('/expenses', expenseRoutes);
app.use('/categories', categoryRoutes);
app.use('/insights', insightRoutes);
app.use('/mail', mailRoutes);

app.use((_req, _res, next) => {
  next(new HttpError(404, 'Route not found'));
});

app.use((err, _req, res, _next) => {
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    message: err.message || 'Internal Server Error',
    ...(err.details ? { details: err.details } : {}),
  });
});

module.exports = app;
