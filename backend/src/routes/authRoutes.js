const { Router } = require('express');

const authController = require('../controllers/authController');
const asyncHandler = require('../utils/asyncHandler');

const router = Router();

router.post('/register', asyncHandler(authController.register));
router.post('/login', asyncHandler(authController.login));
router.get('/profile/:username', asyncHandler(authController.getProfile));
router.put('/profile/display-name', asyncHandler(authController.updateProfileDisplayName));

module.exports = router;
