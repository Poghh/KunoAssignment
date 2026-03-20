require('dotenv').config();

const app = require('./app');
const { initializeDatabase } = require('./services/sqlite');

const PORT = process.env.PORT || 3000;

async function bootstrap() {
  try {
    await initializeDatabase();

    app.listen(PORT, () => {
      console.log(`Expense API running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap();
