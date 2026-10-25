const express = require('express');
const router = express.Router();
const {
  getTasksStatistics,
  getAssignmentsStatistics,
  getDeadlinesStatistics,
} = require('../controllers/statisticsController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/tasks', getTasksStatistics);
router.get('/assignments', getAssignmentsStatistics);
router.get('/deadlines', getDeadlinesStatistics);

module.exports = router;
