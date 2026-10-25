const express = require('express');
const router = express.Router();
const {
  getTasks,
  createTask,
  getTaskById,
  updateTask,
  deleteTask,
  updateTaskStatus,
  getTaskActivities,
} = require('../controllers/taskController');
const { protect } = require('../middleware/authMiddleware');
const {
  requireTaskAccess,
  requireTaskEditor,
  requireTaskOwner,
} = require('../middleware/permissionMiddleware');

router.use(protect);

router.route('/')
  .get(getTasks)
  .post(createTask);

router.route('/:id')
  .get(requireTaskAccess, getTaskById)
  .put(requireTaskEditor, updateTask)
  .delete(requireTaskOwner, deleteTask);

router.patch('/:id/status', requireTaskEditor, updateTaskStatus);
router.get('/:id/activities', requireTaskAccess, getTaskActivities);

module.exports = router;
