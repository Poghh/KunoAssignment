const { Router } = require('express');

const mailController = require('../controllers/mailController');
const asyncHandler = require('../utils/asyncHandler');

const router = Router();

router.get('/verify', asyncHandler(mailController.verifySmtp));
router.post('/send', asyncHandler(mailController.sendMail));

module.exports = router;
