const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');
const { validateTaskInput } = require('../validators/taskValidator');
const { logActivity } = require('../services/taskService');

// @desc    Get all accessible tasks with filter, search, sort, scope
// @route   GET /api/tasks
// @access  Private
const getTasks = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { scope, status, priority, q, sortBy, order } = req.query;

    let filter = {};

    // 1. Determine Scope
    if (scope === 'created') {
      filter.createdBy = userId;
    } else if (scope === 'assigned') {
      filter.assigneeIds = userId;
    } else if (scope === 'shared') {
      const shares = await TaskShare.find({ userId }).select('taskId');
      const sharedTaskIds = shares.map((s) => s.taskId);
      filter._id = { $in: sharedTaskIds };
    } else {
      // Default: All tasks where user is creator, assignee, or shared
      const shares = await TaskShare.find({ userId }).select('taskId');
      const sharedTaskIds = shares.map((s) => s.taskId);
      filter.$or = [
        { createdBy: userId },
        { assigneeIds: userId },
        { _id: { $in: sharedTaskIds } },
      ];
    }

    // 2. Filter by status & priority
    if (status && status !== 'all') {
      filter.status = status;
    }
    if (priority && priority !== 'all') {
      filter.priority = priority;
    }

    // 3. Search query
    if (q && q.trim()) {
      filter.title = { $regex: q.trim(), $options: 'i' };
    }

    // 4. Sorting
    let sortOptions = { createdAt: -1 };
    const sortDirection = order === 'asc' ? 1 : -1;
    if (sortBy === 'dueDate') {
      sortOptions = { dueDate: sortDirection, createdAt: -1 };
    } else if (sortBy === 'priority') {
      sortOptions = { priority: sortDirection, createdAt: -1 };
    } else if (sortBy === 'createdAt') {
      sortOptions = { createdAt: sortDirection };
    }

    const tasks = await Task.find(filter)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl')
      .sort(sortOptions);

    res.status(200).json({
      success: true,
      count: tasks.length,
      data: tasks,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create a new task
// @route   POST /api/tasks
// @access  Private
const createTask = async (req, res, next) => {
  try {
    const { isValid, errors } = validateTaskInput(req.body);
    if (!isValid) {
      return res.status(400).json({ success: false, errors, message: 'Dữ liệu không hợp lệ' });
    }

    const {
      title,
      description,
      startDate,
      dueDate,
      priority,
      status,
      assigneeIds,
      primaryAssigneeId,
    } = req.body;

    const task = await Task.create({
      title: title.trim(),
      description: description ? description.trim() : '',
      createdBy: req.user._id,
      assigneeIds: assigneeIds || [],
      primaryAssigneeId: primaryAssigneeId || null,
      startDate: startDate || null,
      dueDate: dueDate || null,
      priority: priority || 'medium',
      status: status || 'todo',
    });

    await logActivity(task._id, req.user._id, 'Tạo công việc', {
      title: task.title,
      priority: task.priority,
      status: task.status,
    });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    res.status(201).json({
      success: true,
      message: 'Tạo công việc thành công',
      data: populatedTask,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get task detail
// @route   GET /api/tasks/:id
// @access  Private
const getTaskById = async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    res.status(200).json({
      success: true,
      data: {
        ...task.toObject(),
        userAccess: req.taskAccess.access,
        isOwner: req.taskAccess.isOwner,
        canEdit: req.taskAccess.canEdit,
        canDelete: req.taskAccess.canDelete,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update task details
// @route   PUT /api/tasks/:id
// @access  Private (Owner, Assignee, Editor)
const updateTask = async (req, res, next) => {
  try {
    const { isValid, errors } = validateTaskInput(req.body);
    if (!isValid) {
      return res.status(400).json({ success: false, errors, message: 'Dữ liệu không hợp lệ' });
    }

    const task = req.task;
    const oldValues = {
      title: task.title,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status,
    };

    const { title, description, startDate, dueDate, priority, status } = req.body;

    task.title = title.trim();
    if (description !== undefined) task.description = description.trim();
    if (startDate !== undefined) task.startDate = startDate || null;
    if (dueDate !== undefined) task.dueDate = dueDate || null;
    if (priority) task.priority = priority;
    if (status) task.status = status;

    await task.save();

    await logActivity(task._id, req.user._id, 'Chỉnh sửa thông tin công việc', {
      before: oldValues,
      after: {
        title: task.title,
        dueDate: task.dueDate,
        priority: task.priority,
        status: task.status,
      },
    });

    const updatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    res.status(200).json({
      success: true,
      message: 'Cập nhật công việc thành công',
      data: updatedTask,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete task
// @route   DELETE /api/tasks/:id
// @access  Private (Owner only)
const deleteTask = async (req, res, next) => {
  try {
    const taskId = req.task._id;
    await Task.findByIdAndDelete(taskId);
    await TaskShare.deleteMany({ taskId });
    await TaskActivity.deleteMany({ taskId });

    res.status(200).json({
      success: true,
      message: 'Xóa công việc thành công',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update task status
// @route   PATCH /api/tasks/:id/status
// @access  Private (Owner, Assignee, Editor)
const updateTaskStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    if (!['todo', 'in_progress', 'completed'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Trạng thái không hợp lệ (todo, in_progress, completed)',
      });
    }

    const task = req.task;
    const oldStatus = task.status;
    task.status = status;
    await task.save();

    await logActivity(task._id, req.user._id, 'Cập nhật trạng thái', {
      from: oldStatus,
      to: status,
    });

    res.status(200).json({
      success: true,
      message: 'Cập nhật trạng thái thành công',
      data: task,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get task activities
// @route   GET /api/tasks/:id/activities
// @access  Private
const getTaskActivities = async (req, res, next) => {
  try {
    const activities = await TaskActivity.find({ taskId: req.task._id })
      .populate('userId', 'fullName email avatarUrl')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: activities,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTasks,
  createTask,
  getTaskById,
  updateTask,
  deleteTask,
  updateTaskStatus,
  getTaskActivities,
};
