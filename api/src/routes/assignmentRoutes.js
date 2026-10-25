const express = require('express');
const router = express.Router({ mergeParams: true });
const {
  getAssignees,
  assignUsers,
  updateAssigneeRole,
  removeAssignee,
} = require('../controllers/assignmentController');
const { protect } = require('../middleware/authMiddleware');
const {
  requireTaskAccess,
  requireTaskEditor,
} = require('../middleware/permissionMiddleware');

router.use(protect);

router.route('/')
  .get(requireTaskAccess, getAssignees)
  .post(requireTaskEditor, assignUsers);

router.route('/:userId')
  .patch(requireTaskEditor, updateAssigneeRole)
  .delete(requireTaskEditor, removeAssignee);

module.exports = router;
