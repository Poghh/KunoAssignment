const nodemailer = require('nodemailer');
const { randomUUID } = require('node:crypto');

const HttpError = require('../models/httpError');

let transporter;

function getMailProvider() {
  const raw = process.env.MAIL_PROVIDER;
  if (typeof raw !== 'string' || raw.trim().length === 0) {
    return 'mock';
  }
  return raw.trim().toLowerCase();
}

function parseBoolean(rawValue, fallback) {
  if (typeof rawValue !== 'string') {
    return fallback;
  }

  const normalized = rawValue.trim().toLowerCase();
  if (normalized === 'true' || normalized === '1') {
    return true;
  }
  if (normalized === 'false' || normalized === '0') {
    return false;
  }
  return fallback;
}

function getRequiredEnv(key) {
  const value = process.env[key];
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new HttpError(500, `Missing SMTP configuration: ${key}`);
  }
  return value.trim();
}

function resolveSmtpConfig() {
  const host = getRequiredEnv('SMTP_HOST');
  const user = getRequiredEnv('SMTP_USER');
  const pass = getRequiredEnv('SMTP_PASS');

  const rawPort = process.env.SMTP_PORT;
  const port = rawPort == null || rawPort === '' ? 587 : Number(rawPort);
  if (!Number.isInteger(port) || port <= 0) {
    throw new HttpError(500, 'Invalid SMTP_PORT configuration');
  }

  const secure = parseBoolean(process.env.SMTP_SECURE, port === 465);
  const rejectUnauthorized = parseBoolean(
    process.env.SMTP_TLS_REJECT_UNAUTHORIZED,
    true,
  );

  return {
    host,
    port,
    secure,
    auth: {
      user,
      pass,
    },
    tls: {
      rejectUnauthorized,
    },
  };
}

function getTransporter() {
  if (!transporter) {
    transporter = nodemailer.createTransport(resolveSmtpConfig());
  }
  return transporter;
}

async function verifySmtpConnection() {
  const provider = getMailProvider();
  if (provider === 'mock') {
    return {
      status: 'ready',
      provider: 'mock',
      message: 'Mail service is running in mock mode',
    };
  }

  if (provider !== 'smtp') {
    throw new HttpError(500, `Unsupported MAIL_PROVIDER: ${provider}`);
  }

  await getTransporter().verify();
  return {
    status: 'ready',
    provider: 'smtp',
  };
}

async function sendMail(payload) {
  const provider = getMailProvider();
  if (provider === 'mock') {
    const messageId = `mock-${randomUUID()}`;
    console.log('[MockMail] send:', {
      to: payload.to,
      subject: payload.subject,
      hasText: Boolean(payload.text),
      hasHtml: Boolean(payload.html),
      messageId,
    });

    return {
      messageId,
      accepted: [payload.to],
      rejected: [],
      response: 'mock-delivery',
      provider: 'mock',
    };
  }

  if (provider !== 'smtp') {
    throw new HttpError(500, `Unsupported MAIL_PROVIDER: ${provider}`);
  }

  const smtpUser = getRequiredEnv('SMTP_USER');
  const from = process.env.SMTP_FROM && process.env.SMTP_FROM.trim().length > 0
    ? process.env.SMTP_FROM.trim()
    : smtpUser;

  try {
    const info = await getTransporter().sendMail({
      from,
      to: payload.to,
      subject: payload.subject,
      text: payload.text,
      html: payload.html,
    });

    return {
      messageId: info.messageId,
      accepted: info.accepted,
      rejected: info.rejected,
      response: info.response,
      provider: 'smtp',
    };
  } catch (error) {
    throw new HttpError(502, 'Failed to send mail via SMTP', {
      reason: error.message,
    });
  }
}

module.exports = {
  verifySmtpConnection,
  sendMail,
};
