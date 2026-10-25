const express = require('express');
const router = express.Router();
const { retryFailedEmail } = require('../controllers/emailLogController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.post('/:id/retry', retryFailedEmail);

module.exports = router;
