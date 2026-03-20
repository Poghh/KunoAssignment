const BASE_CURRENCY = 'USD';
const USD_TO_VND = 25500;

const TO_BASE_RATES = {
  USD: 1,
  VND: 1 / USD_TO_VND,
};

function normalizeCurrencyCode(rawCode) {
  const normalized = typeof rawCode === 'string' ? rawCode.trim().toUpperCase() : 'USD';
  if (!Object.prototype.hasOwnProperty.call(TO_BASE_RATES, normalized)) {
    throw new Error(`Unsupported currency code: ${rawCode}`);
  }
  return normalized;
}

function resolveRateSnapshot({ currencyCode }) {
  const normalizedCurrency = normalizeCurrencyCode(currencyCode);
  return TO_BASE_RATES[normalizedCurrency];
}

function convertToBaseAmount({ amount, currencyCode, rateSnapshot }) {
  const normalizedCurrency = normalizeCurrencyCode(currencyCode);
  const rate =
    typeof rateSnapshot === 'number' && Number.isFinite(rateSnapshot)
      ? rateSnapshot
      : resolveRateSnapshot({ currencyCode: normalizedCurrency });

  return Number((Number(amount) * rate).toFixed(8));
}

function getFromBaseMultiplier(currencyCode) {
  const normalizedCurrency = normalizeCurrencyCode(currencyCode);
  const toBaseRate = TO_BASE_RATES[normalizedCurrency];
  return Number((1 / toBaseRate).toFixed(8));
}

module.exports = {
  BASE_CURRENCY,
  convertToBaseAmount,
  getFromBaseMultiplier,
  normalizeCurrencyCode,
  resolveRateSnapshot,
};
