const express = require('express');
const router = express.Router({ mergeParams: true });
const {
  getShares,
  shareTask,
  updateSharePermission,
  revokeShare,
} = require('../controllers/taskShareController');
const { protect } = require('../middleware/authMiddleware');
const {
  requireTaskAccess,
  requireTaskOwner,
} = require('../middleware/permissionMiddleware');

router.use(protect);

router.route('/')
  .get(requireTaskAccess, getShares)
  .post(requireTaskOwner, shareTask);

router.route('/:shareId')
  .patch(requireTaskOwner, updateSharePermission)
  .delete(requireTaskOwner, revokeShare);

module.exports = router;
