const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// Helper to get all task IDs accessible by the user
const getAccessibleTaskIds = async (userId) => {
  const shares = await TaskShare.find({ userId }).select('taskId');
  const sharedTaskIds = shares.map((s) => s.taskId);

  const tasks = await Task.find({
    $or: [
      { createdBy: userId },
      { assigneeIds: userId },
      { _id: { $in: sharedTaskIds } },
    ],
  }).select('_id');

  return tasks.map((t) => t._id);
};

// @desc    Get tasks count by status
// @route   GET /api/statistics/tasks
// @access  Private
const getTasksStatistics = async (req, res, next) => {
  try {
    const accessibleIds = await getAccessibleTaskIds(req.user._id);

    const total = accessibleIds.length;
    const todo = await Task.countDocuments({ _id: { $in: accessibleIds }, status: 'todo' });
    const inProgress = await Task.countDocuments({ _id: { $in: accessibleIds }, status: 'in_progress' });
    const completed = await Task.countDocuments({ _id: { $in: accessibleIds }, status: 'completed' });

    res.status(200).json({
      success: true,
      data: {
        total,
        todo,
        inProgress,
        completed,
        completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get assignments statistics (created, assigned, primary, shared)
// @route   GET /api/statistics/assignments
// @access  Private
const getAssignmentsStatistics = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const createdCount = await Task.countDocuments({ createdBy: userId });
    const assignedCount = await Task.countDocuments({ assigneeIds: userId });
    const primaryCount = await Task.countDocuments({ primaryAssigneeId: userId });
    const sharedCount = await TaskShare.countDocuments({ userId });

    res.status(200).json({
      success: true,
      data: {
        createdCount,
        assignedCount,
        primaryCount,
        sharedCount,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get deadlines statistics (overdue, dueSoon, onTrack)
// @route   GET /api/statistics/deadlines
// @access  Private
const getDeadlinesStatistics = async (req, res, next) => {
  try {
    const accessibleIds = await getAccessibleTaskIds(req.user._id);

    const now = new Date();
    const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const overdueTasks = await Task.find({
      _id: { $in: accessibleIds },
      status: { $ne: 'completed' },
      dueDate: { $lt: now },
    }).select('title dueDate priority status');

    const dueSoonTasks = await Task.find({
      _id: { $in: accessibleIds },
      status: { $ne: 'completed' },
      dueDate: { $gte: now, $lte: in24Hours },
    }).select('title dueDate priority status');

    const onTrackCount = await Task.countDocuments({
      _id: { $in: accessibleIds },
      status: { $ne: 'completed' },
      dueDate: { $gt: in24Hours },
    });

    const noDueDateCount = await Task.countDocuments({
      _id: { $in: accessibleIds },
      status: { $ne: 'completed' },
      dueDate: null,
    });

    res.status(200).json({
      success: true,
      data: {
        overdueCount: overdueTasks.length,
        dueSoonCount: dueSoonTasks.length,
        onTrackCount,
        noDueDateCount,
        overdueTasks,
        dueSoonTasks,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTasksStatistics,
  getAssignmentsStatistics,
  getDeadlinesStatistics,
};
