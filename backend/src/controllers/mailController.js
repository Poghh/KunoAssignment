const mailService = require('../services/mailService');

function validateSendMailPayload(payload) {
  const errors = {};
  const sanitized = {};

  const to = typeof payload?.to === 'string' ? payload.to.trim() : '';
  if (!to || !to.includes('@')) {
    errors.to = 'A valid recipient email is required';
  } else {
    sanitized.to = to;
  }

  const subject =
    typeof payload?.subject === 'string' ? payload.subject.trim() : '';
  if (!subject) {
    errors.subject = 'Subject is required';
  } else {
    sanitized.subject = subject;
  }

  const text = typeof payload?.text === 'string' ? payload.text.trim() : '';
  const html = typeof payload?.html === 'string' ? payload.html.trim() : '';

  if (!text && !html) {
    errors.content = 'Either text or html content is required';
  }

  if (text) {
    sanitized.text = text;
  }
  if (html) {
    sanitized.html = html;
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    sanitized,
  };
}

async function sendMail(req, res) {
  const validation = validateSendMailPayload(req.body);
  if (!validation.isValid) {
    return res.status(400).json({
      message: 'Validation failed',
      errors: validation.errors,
    });
  }

  const result = await mailService.sendMail(validation.sanitized);
  return res.status(200).json({ data: result });
}

async function verifySmtp(req, res) {
  const result = await mailService.verifySmtpConnection();
  return res.status(200).json({ data: result });
}

module.exports = {
  sendMail,
  verifySmtp,
};
