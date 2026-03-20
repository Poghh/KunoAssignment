const fs = require('node:fs/promises');
const path = require('node:path');
const { randomUUID } = require('node:crypto');
const sqlite3 = require('sqlite3');
const {
  convertToBaseAmount,
  normalizeCurrencyCode,
  resolveRateSnapshot,
} = require('./exchangeRateService');
const { hashPassword, verifyPassword } = require('./passwordService');

const DATA_FILE = path.join(__dirname, '..', 'data', 'data.json');
const MOCK_DATA_FILE = path.join(__dirname, '..', 'data', 'mockData.json');
const DB_FILE = path.join(__dirname, '..', 'data', 'app.sqlite');
const DEMO_USERNAME = 'demo@example.com';
const DEMO_PASSWORD = '123456';
const DEMO_DISPLAY_NAME = 'Demo User';
const DEMO_CATEGORY_SEEDS = Object.freeze([
  Object.freeze({
    name: 'Food',
    color: '#EF5350',
    icon: 'restaurant',
  }),
  Object.freeze({
    name: 'Transport',
    color: '#42A5F5',
    icon: 'directions_car',
  }),
  Object.freeze({
    name: 'Shopping',
    color: '#AB47BC',
    icon: 'shopping_bag',
  }),
  Object.freeze({
    name: 'Bills',
    color: '#FFA726',
    icon: 'lightbulb',
  }),
  Object.freeze({
    name: 'Entertainment',
    color: '#26A69A',
    icon: 'movie',
  }),
  Object.freeze({
    name: 'Health',
    color: '#66BB6A',
    icon: 'health_and_safety',
  }),
  Object.freeze({
    name: 'Salary',
    color: '#4CAF50',
    icon: 'work',
  }),
]);

let dbInstance = null;
let initializationPromise = null;

function createDatabaseConnection() {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(DB_FILE, (error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(db);
    });
  });
}

async function getDatabase() {
  if (!dbInstance) {
    dbInstance = await createDatabaseConnection();
  }

  return dbInstance;
}

async function run(sql, params = []) {
  const db = await getDatabase();
  return new Promise((resolve, reject) => {
    db.run(sql, params, function onRun(error) {
      if (error) {
        reject(error);
        return;
      }
      resolve({ changes: this.changes, lastID: this.lastID });
    });
  });
}

async function get(sql, params = []) {
  const db = await getDatabase();
  return new Promise((resolve, reject) => {
    db.get(sql, params, (error, row) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(row || null);
    });
  });
}

async function all(sql, params = []) {
  const db = await getDatabase();
  return new Promise((resolve, reject) => {
    db.all(sql, params, (error, rows) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(rows || []);
    });
  });
}

async function withTransaction(work) {
  await run('BEGIN');
  try {
    const result = await work();
    await run('COMMIT');
    return result;
  } catch (error) {
    try {
      await run('ROLLBACK');
    } catch {
      // Ignore rollback failure and rethrow original error.
    }
    throw error;
  }
}

async function createSchema() {
  await run('PRAGMA foreign_keys = ON');

  await run(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL UNIQUE COLLATE NOCASE,
      password TEXT NOT NULL,
      display_name TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL DEFAULT '',
      name TEXT NOT NULL,
      color TEXT NOT NULL DEFAULT '#4CAF50',
      icon TEXT NOT NULL DEFAULT 'category',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(user_id, name COLLATE NOCASE)
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS expenses (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL DEFAULT '',
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      currency_code TEXT NOT NULL DEFAULT 'USD',
      fx_rate_snapshot REAL NOT NULL DEFAULT 1,
      amount_in_base REAL NOT NULL DEFAULT 0,
      date TEXT NOT NULL,
      category_id TEXT NOT NULL,
      location TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
    )
  `);

  await migrateUserColumns();
  await migrateExpenseColumns();
  await migrateCategoryOwnership();
  await backfillExpenseCurrencyData();

  await run('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
  await run('CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id)');
  await run('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC)');
  await run('CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category_id)');
  await run(
    'CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at DESC)',
  );
  await run('CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON expenses(user_id)');
  await run('CREATE INDEX IF NOT EXISTS idx_expenses_amount_base ON expenses(amount_in_base)');
}

function toDateOnly(value) {
  return value.toISOString().slice(0, 10);
}

function daysAgo(value) {
  const date = new Date();
  date.setDate(date.getDate() - value);
  return toDateOnly(date);
}

function buildDemoExpenseSeeds(categoryIdByName) {
  return [
    {
      title: 'Lunch',
      amount: 9.5,
      currencyCode: 'USD',
      date: daysAgo(1),
      categoryId: categoryIdByName.food,
      location: 'The Pantry',
      notes: 'Team lunch',
    },
    {
      title: 'Fuel',
      amount: 18.0,
      currencyCode: 'USD',
      date: daysAgo(2),
      categoryId: categoryIdByName.transport,
      location: 'City Gas',
      notes: '',
    },
    {
      title: 'Groceries',
      amount: 46.75,
      currencyCode: 'USD',
      date: daysAgo(4),
      categoryId: categoryIdByName.food,
      location: 'Co-op Mart',
      notes: '',
    },
    {
      title: 'Movie Ticket',
      amount: 9.0,
      currencyCode: 'USD',
      date: daysAgo(6),
      categoryId: categoryIdByName.entertainment,
      location: 'CGV',
      notes: '',
    },
    {
      title: 'Taxi Ride',
      amount: 18.0,
      currencyCode: 'USD',
      date: daysAgo(8),
      categoryId: categoryIdByName.transport,
      location: 'Airport',
      notes: '',
    },
    {
      title: 'Protein Powder',
      amount: 24.5,
      currencyCode: 'USD',
      date: daysAgo(10),
      categoryId: categoryIdByName.health,
      location: 'Gym Store',
      notes: '',
    },
    {
      title: 'Internet Bill',
      amount: 450000,
      currencyCode: 'VND',
      date: daysAgo(12),
      categoryId: categoryIdByName.bills,
      location: 'VNPT',
      notes: '',
    },
    {
      title: 'Monthly Salary',
      amount: -2500,
      currencyCode: 'USD',
      date: daysAgo(14),
      categoryId: categoryIdByName.salary,
      location: 'Company Payroll',
      notes: 'Income',
    },
  ].filter((seed) => typeof seed.categoryId === 'string' && seed.categoryId.length > 0);
}

async function readSeedData() {
  const sourcePath = await fs
    .access(DATA_FILE)
    .then(() => DATA_FILE)
    .catch(() => MOCK_DATA_FILE);

  const raw = await fs.readFile(sourcePath, 'utf8');
  const parsed = JSON.parse(raw);

  return {
    categories: Array.isArray(parsed.categories) ? parsed.categories : [],
    expenses: Array.isArray(parsed.expenses) ? parsed.expenses : [],
  };
}

async function seedIfNeeded() {
  const categoryCountRow = await get('SELECT COUNT(1) AS count FROM categories');
  const expenseCountRow = await get('SELECT COUNT(1) AS count FROM expenses');
  const categoryCount = Number(categoryCountRow?.count || 0);
  const expenseCount = Number(expenseCountRow?.count || 0);

  if (categoryCount > 0 || expenseCount > 0) {
    return;
  }

  const seedData = await readSeedData();

  await withTransaction(async () => {
    for (const category of seedData.categories) {
      const timestamp = new Date().toISOString();
      await run(
        `
          INSERT INTO categories (id, user_id, name, color, icon, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        `,
        [
          category.id,
          '',
          category.name,
          category.color || '#4CAF50',
          category.icon || 'category',
          timestamp,
          timestamp,
        ],
      );
    }

    for (const expense of seedData.expenses) {
      const createdAt = expense.createdAt || new Date().toISOString();
      const updatedAt = expense.updatedAt || createdAt;
      const currencyCode = normalizeCurrencyCode(expense.currencyCode || 'USD');
      const fxRateSnapshot = resolveRateSnapshot({ currencyCode });
      const amountInBase = convertToBaseAmount({
        amount: expense.amount,
        currencyCode,
        rateSnapshot: fxRateSnapshot,
      });
      await run(
        `
          INSERT INTO expenses (
            id,
            user_id,
            title,
            amount,
            currency_code,
            fx_rate_snapshot,
            amount_in_base,
            date,
            category_id,
            location,
            notes,
            created_at,
            updated_at
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
          expense.id,
          '',
          expense.title,
          expense.amount,
          currencyCode,
          fxRateSnapshot,
          amountInBase,
          expense.date,
          expense.categoryId,
          expense.location || null,
          expense.notes || null,
          createdAt,
          updatedAt,
        ],
      );
    }
  });
}

async function ensureDemoAccountData() {
  let demoUser = await get(
    `
      SELECT id, email, password, display_name
      FROM users
      WHERE email = ?
      COLLATE NOCASE
      LIMIT 1
    `,
    [DEMO_USERNAME],
  );

  if (!demoUser) {
    const timestamp = new Date().toISOString();
    const passwordHash = await hashPassword(DEMO_PASSWORD);
    const userId = randomUUID();

    await run(
      `
        INSERT INTO users (id, email, password, display_name, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `,
      [userId, DEMO_USERNAME, passwordHash, DEMO_DISPLAY_NAME, timestamp, timestamp],
    );

    demoUser = {
      id: userId,
      email: DEMO_USERNAME,
      password: passwordHash,
      display_name: DEMO_DISPLAY_NAME,
    };
  } else {
    const shouldSetDisplayName = (demoUser.display_name || '').trim().length === 0;
    const isPasswordValid = await verifyPassword({
      password: DEMO_PASSWORD,
      storedPassword: demoUser.password,
    });

    if (!isPasswordValid || shouldSetDisplayName) {
      const updates = [];
      const params = [];

      if (!isPasswordValid) {
        const passwordHash = await hashPassword(DEMO_PASSWORD);
        updates.push('password = ?');
        params.push(passwordHash);
      }

      if (shouldSetDisplayName) {
        updates.push('display_name = ?');
        params.push(DEMO_DISPLAY_NAME);
      }

      updates.push('updated_at = ?');
      params.push(new Date().toISOString(), demoUser.id);

      await run(
        `
          UPDATE users
          SET ${updates.join(', ')}
          WHERE id = ?
        `,
        params,
      );
    }
  }

  const userId = demoUser.id;
  const existingCategories = await all(
    `
      SELECT id, name
      FROM categories
      WHERE user_id = ?
    `,
    [userId],
  );
  const existingByName = new Map(
    existingCategories.map((category) => [
      String(category.name || '').trim().toLowerCase(),
      category.id,
    ]),
  );

  for (const seed of DEMO_CATEGORY_SEEDS) {
    const key = seed.name.trim().toLowerCase();
    if (existingByName.has(key)) {
      continue;
    }

    const timestamp = new Date().toISOString();
    const categoryId = randomUUID();
    await run(
      `
        INSERT INTO categories (id, user_id, name, color, icon, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `,
      [categoryId, userId, seed.name, seed.color, seed.icon, timestamp, timestamp],
    );
    existingByName.set(key, categoryId);
  }

  const expenseCountRow = await get(
    'SELECT COUNT(1) AS count FROM expenses WHERE user_id = ?',
    [userId],
  );
  const expenseCount = Number(expenseCountRow?.count || 0);
  if (expenseCount > 0) {
    return;
  }

  const categoryIdByName = {
    food: existingByName.get('food') || '',
    transport: existingByName.get('transport') || '',
    shopping: existingByName.get('shopping') || '',
    bills: existingByName.get('bills') || '',
    entertainment: existingByName.get('entertainment') || '',
    health: existingByName.get('health') || '',
    salary: existingByName.get('salary') || '',
  };
  const expenseSeeds = buildDemoExpenseSeeds(categoryIdByName);

  await withTransaction(async () => {
    for (const seed of expenseSeeds) {
      const createdAt = new Date().toISOString();
      const updatedAt = createdAt;
      const currencyCode = normalizeCurrencyCode(seed.currencyCode || 'USD');
      const fxRateSnapshot = resolveRateSnapshot({ currencyCode });
      const amountInBase = convertToBaseAmount({
        amount: seed.amount,
        currencyCode,
        rateSnapshot: fxRateSnapshot,
      });

      await run(
        `
          INSERT INTO expenses (
            id,
            user_id,
            title,
            amount,
            currency_code,
            fx_rate_snapshot,
            amount_in_base,
            date,
            category_id,
            location,
            notes,
            created_at,
            updated_at
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
          randomUUID(),
          userId,
          seed.title,
          seed.amount,
          currencyCode,
          fxRateSnapshot,
          amountInBase,
          seed.date,
          seed.categoryId,
          seed.location || null,
          seed.notes || null,
          createdAt,
          updatedAt,
        ],
      );
    }
  });
}

async function migrateExpenseColumns() {
  const columns = await all('PRAGMA table_info(expenses)');
  const columnNames = new Set(columns.map((column) => column.name));

  if (!columnNames.has('user_id')) {
    await run("ALTER TABLE expenses ADD COLUMN user_id TEXT NOT NULL DEFAULT ''");
  }

  if (!columnNames.has('currency_code')) {
    await run("ALTER TABLE expenses ADD COLUMN currency_code TEXT NOT NULL DEFAULT 'USD'");
  }

  if (!columnNames.has('fx_rate_snapshot')) {
    await run('ALTER TABLE expenses ADD COLUMN fx_rate_snapshot REAL NOT NULL DEFAULT 1');
  }

  if (!columnNames.has('amount_in_base')) {
    await run('ALTER TABLE expenses ADD COLUMN amount_in_base REAL NOT NULL DEFAULT 0');
  }
}

async function migrateUserColumns() {
  const columns = await all('PRAGMA table_info(users)');
  const columnNames = new Set(columns.map((column) => column.name));

  if (!columnNames.has('display_name')) {
    await run("ALTER TABLE users ADD COLUMN display_name TEXT NOT NULL DEFAULT ''");
  }

  // Rename legacy 'username' column to 'email' for existing databases.
  if (columnNames.has('username') && !columnNames.has('email')) {
    await run('ALTER TABLE users RENAME COLUMN username TO email');
    await run('DROP INDEX IF EXISTS idx_users_username');
  }
}

async function migrateCategoryOwnership() {
  const schemaRow = await get(
    `
      SELECT sql
      FROM sqlite_master
      WHERE type = 'table' AND name = 'categories'
    `,
  );

  if (!schemaRow || typeof schemaRow.sql !== 'string') {
    return;
  }

  const normalizedSchema = schemaRow.sql.replace(/\s+/g, ' ').toLowerCase();
  const hasUserIdColumn = normalizedSchema.includes('user_id');
  const hasCompositeUnique = normalizedSchema.includes(
    'unique(user_id, name collate nocase)',
  );

  if (hasUserIdColumn && hasCompositeUnique) {
    return;
  }

  await run('PRAGMA foreign_keys = OFF');
  try {
    await run('ALTER TABLE expenses RENAME TO expenses_legacy');
    await run('ALTER TABLE categories RENAME TO categories_legacy');

    await run(`
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT '',
        name TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT '#4CAF50',
        icon TEXT NOT NULL DEFAULT 'category',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, name COLLATE NOCASE)
      )
    `);

    await run(`
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT '',
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        currency_code TEXT NOT NULL DEFAULT 'USD',
        fx_rate_snapshot REAL NOT NULL DEFAULT 1,
        amount_in_base REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        category_id TEXT NOT NULL,
        location TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    `);

    const legacyCategoryColumns = await all('PRAGMA table_info(categories_legacy)');
    const legacyCategoryColumnNames = new Set(
      legacyCategoryColumns.map((column) => column.name),
    );
    const categoryUserIdSelect = legacyCategoryColumnNames.has('user_id')
      ? "COALESCE(user_id, '')"
      : "''";

    await run(
      `
        INSERT INTO categories (id, user_id, name, color, icon, created_at, updated_at)
        SELECT
          id,
          ${categoryUserIdSelect} AS user_id,
          name,
          color,
          icon,
          created_at,
          updated_at
        FROM categories_legacy
      `,
    );

    const legacyExpenseColumns = await all('PRAGMA table_info(expenses_legacy)');
    const legacyExpenseColumnNames = new Set(
      legacyExpenseColumns.map((column) => column.name),
    );
    const expenseUserIdSelect = legacyExpenseColumnNames.has('user_id')
      ? "COALESCE(user_id, '')"
      : "''";
    const expenseCurrencyCodeSelect = legacyExpenseColumnNames.has('currency_code')
      ? "COALESCE(currency_code, 'USD')"
      : "'USD'";
    const expenseFxRateSnapshotSelect = legacyExpenseColumnNames.has('fx_rate_snapshot')
      ? 'COALESCE(fx_rate_snapshot, 1)'
      : '1';
    const expenseAmountInBaseSelect = legacyExpenseColumnNames.has('amount_in_base')
      ? 'COALESCE(amount_in_base, 0)'
      : '0';

    await run(
      `
        INSERT INTO expenses (
          id,
          user_id,
          title,
          amount,
          currency_code,
          fx_rate_snapshot,
          amount_in_base,
          date,
          category_id,
          location,
          notes,
          created_at,
          updated_at
        )
        SELECT
          id,
          ${expenseUserIdSelect} AS user_id,
          title,
          amount,
          ${expenseCurrencyCodeSelect} AS currency_code,
          ${expenseFxRateSnapshotSelect} AS fx_rate_snapshot,
          ${expenseAmountInBaseSelect} AS amount_in_base,
          date,
          category_id,
          location,
          notes,
          created_at,
          updated_at
        FROM expenses_legacy
      `,
    );

    await run('DROP TABLE expenses_legacy');
    await run('DROP TABLE categories_legacy');
  } finally {
    await run('PRAGMA foreign_keys = ON');
  }
}

async function backfillExpenseCurrencyData() {
  const rows = await all(
    `
      SELECT id, amount, currency_code, fx_rate_snapshot, amount_in_base
      FROM expenses
    `,
  );

  await withTransaction(async () => {
    for (const row of rows) {
      let currencyCode;
      try {
        currencyCode = normalizeCurrencyCode(row.currency_code || 'USD');
      } catch {
        currencyCode = 'USD';
      }

      const fxRateSnapshot =
        typeof row.fx_rate_snapshot === 'number' && Number.isFinite(row.fx_rate_snapshot)
          ? row.fx_rate_snapshot
          : resolveRateSnapshot({ currencyCode });

      const amountInBase =
        typeof row.amount_in_base === 'number' &&
        Number.isFinite(row.amount_in_base) &&
        row.amount_in_base !== 0
          ? row.amount_in_base
          : convertToBaseAmount({
              amount: row.amount,
              currencyCode,
              rateSnapshot: fxRateSnapshot,
            });

      await run(
        `
          UPDATE expenses
          SET currency_code = ?, fx_rate_snapshot = ?, amount_in_base = ?
          WHERE id = ?
        `,
        [currencyCode, fxRateSnapshot, amountInBase, row.id],
      );
    }
  });
}

async function initializeDatabase() {
  if (initializationPromise) {
    return initializationPromise;
  }

  initializationPromise = (async () => {
    await getDatabase();
    await createSchema();
    await seedIfNeeded();
    await ensureDemoAccountData();
  })();

  await initializationPromise;
}

module.exports = {
  all,
  get,
  initializeDatabase,
  run,
  withTransaction,
};
