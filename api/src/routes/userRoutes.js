const express = require('express');
const router = express.Router();
const { searchUsers, getUserById } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

router.get('/search', protect, searchUsers);
router.get('/:id', protect, getUserById);

module.exports = router;
