const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// Determine user permission role on a task
const getTaskAccess = async (taskId, userId) => {
  const task = await Task.findById(taskId);
  if (!task) {
    return { task: null, access: null };
  }

  const userIdStr = userId.toString();

  // 1. Is Creator / Owner
  if (task.createdBy.toString() === userIdStr) {
    return { task, access: 'owner', isOwner: true, canEdit: true, canDelete: true };
  }

  // 2. Is Assignee
  const isAssignee = task.assigneeIds.some((id) => id.toString() === userIdStr);
  if (isAssignee) {
    return { task, access: 'assignee', isOwner: false, canEdit: true, canDelete: false };
  }

  // 3. Is Shared
  const share = await TaskShare.findOne({ taskId, userId });
  if (share) {
    const canEdit = share.permission === 'editor';
    return {
      task,
      access: share.permission,
      shareId: share._id,
      isOwner: false,
      canEdit,
      canDelete: false,
    };
  }

  return { task, access: null, isOwner: false, canEdit: false, canDelete: false };
};

// Check if user has read permission
const requireTaskAccess = async (req, res, next) => {
  try {
    const { taskId, id } = req.params;
    const targetTaskId = taskId || id;

    const accessInfo = await getTaskAccess(targetTaskId, req.user._id);
    if (!accessInfo.task) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy công việc' });
    }

    if (!accessInfo.access) {
      return res.status(403).json({
        success: false,
        message: 'Bạn không có quyền truy cập công việc này',
      });
    }

    req.taskAccess = accessInfo;
    req.task = accessInfo.task;
    next();
  } catch (error) {
    next(error);
  }
};

// Check if user has edit permission (owner, assignee, or editor)
const requireTaskEditor = async (req, res, next) => {
  try {
    const { taskId, id } = req.params;
    const targetTaskId = taskId || id;

    const accessInfo = await getTaskAccess(targetTaskId, req.user._id);
    if (!accessInfo.task) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy công việc' });
    }

    if (!accessInfo.canEdit) {
      return res.status(403).json({
        success: false,
        message: 'Bạn chỉ có quyền xem, không được phép chỉnh sửa công việc này',
      });
    }

    req.taskAccess = accessInfo;
    req.task = accessInfo.task;
    next();
  } catch (error) {
    next(error);
  }
};

// Check if user is owner / creator (can delete, manage assignees & shares)
const requireTaskOwner = async (req, res, next) => {
  try {
    const { taskId, id } = req.params;
    const targetTaskId = taskId || id;

    const accessInfo = await getTaskAccess(targetTaskId, req.user._id);
    if (!accessInfo.task) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy công việc' });
    }

    if (!accessInfo.isOwner) {
      return res.status(403).json({
        success: false,
        message: 'Chỉ người tạo mới có quyền thực hiện thao tác này',
      });
    }

    req.taskAccess = accessInfo;
    req.task = accessInfo.task;
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTaskAccess,
  requireTaskAccess,
  requireTaskEditor,
  requireTaskOwner,
};
