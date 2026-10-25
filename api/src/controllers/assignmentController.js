const Task = require('../models/Task');
const User = require('../models/User');
const { logActivity } = require('../services/taskService');
const { notifyTaskAssigned } = require('../services/notificationService');

// @desc    Get assignees list of a task
// @route   GET /api/tasks/:id/assignees
// @access  Private (Task Access)
const getAssignees = async (req, res, next) => {
  try {
    const task = await Task.findById(req.task._id)
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    res.status(200).json({
      success: true,
      data: {
        assignees: task.assigneeIds,
        primaryAssignee: task.primaryAssigneeId,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Assign task to one or more users
// @route   POST /api/tasks/:id/assignees
// @access  Private (Owner or Editor)
const assignUsers = async (req, res, next) => {
  try {
    const { userIds, primaryAssigneeId } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Danh sách người được giao không được để trống',
      });
    }

    const task = req.task;

    // Filter valid user IDs and merge with existing
    const currentAssigneeIds = task.assigneeIds.map((id) => id.toString());
    const newAssigneeIds = userIds.map((id) => id.toString());
    const newlyAddedIds = newAssigneeIds.filter((id) => !currentAssigneeIds.includes(id));
    const mergedAssignees = Array.from(new Set([...currentAssigneeIds, ...newAssigneeIds]));

    task.assigneeIds = mergedAssignees;

    if (primaryAssigneeId) {
      if (!mergedAssignees.includes(primaryAssigneeId.toString())) {
        task.assigneeIds.push(primaryAssigneeId);
      }
      task.primaryAssigneeId = primaryAssigneeId;
    } else if (!task.primaryAssigneeId && mergedAssignees.length > 0) {
      task.primaryAssigneeId = mergedAssignees[0];
    }

    await task.save();

    await logActivity(task._id, req.user._id, 'Giao việc cho thành viên', {
      assignedUserCount: userIds.length,
      primaryAssigneeId: task.primaryAssigneeId,
    });

    // Notify newly assigned users
    if (newlyAddedIds.length > 0) {
      const assignedUsers = await User.find({ _id: { $in: newlyAddedIds } });
      notifyTaskAssigned(task, req.user, assignedUsers).catch(console.error);
    }

    const updatedTask = await Task.findById(task._id)
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    res.status(200).json({
      success: true,
      message: 'Giao việc thành công',
      data: {
        assignees: updatedTask.assigneeIds,
        primaryAssignee: updatedTask.primaryAssigneeId,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Set primary assignee
// @route   PATCH /api/tasks/:id/assignees/:userId
// @access  Private (Owner or Editor)
const updateAssigneeRole = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const task = req.task;

    const isAssignee = task.assigneeIds.some((id) => id.toString() === userId);
    if (!isAssignee) {
      return res.status(400).json({
        success: false,
        message: 'Người dùng này chưa có trong danh sách giao việc của công việc',
      });
    }

    task.primaryAssigneeId = userId;
    await task.save();

    await logActivity(task._id, req.user._id, 'Chỉ định người phụ trách chính', {
      primaryAssigneeId: userId,
    });

    const updatedTask = await Task.findById(task._id)
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    res.status(200).json({
      success: true,
      message: 'Đã cập nhật người phụ trách chính',
      data: {
        assignees: updatedTask.assigneeIds,
        primaryAssignee: updatedTask.primaryAssigneeId,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Remove an assignee from task
// @route   DELETE /api/tasks/:id/assignees/:userId
// @access  Private (Owner or Editor)
const removeAssignee = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const task = req.task;

    task.assigneeIds = task.assigneeIds.filter((id) => id.toString() !== userId);

    if (task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId) {
      task.primaryAssigneeId = task.assigneeIds.length > 0 ? task.assigneeIds[0] : null;
    }

    await task.save();

    await logActivity(task._id, req.user._id, 'Hủy giao việc thành viên', {
      removedUserId: userId,
    });

    res.status(200).json({
      success: true,
      message: 'Đã hủy giao việc thành công',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAssignees,
  assignUsers,
  updateAssigneeRole,
  removeAssignee,
};
