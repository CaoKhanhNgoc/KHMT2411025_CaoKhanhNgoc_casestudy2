const TaskShare = require('../models/TaskShare');
const { logActivity } = require('../services/taskService');

// @desc    Get shared users list of a task
// @route   GET /api/tasks/:id/shares
// @access  Private (Task Access)
const getShares = async (req, res, next) => {
  try {
    const shares = await TaskShare.find({ taskId: req.task._id })
      .populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: shares,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Share task with one or more users
// @route   POST /api/tasks/:id/shares
// @access  Private (Owner only)
const shareTask = async (req, res, next) => {
  try {
    const taskId = req.task._id;
    const sharedBy = req.user._id;

    // Body can be { userId, permission } or { shares: [{ userId, permission }] }
    let sharesToAdd = [];
    if (req.body.shares && Array.isArray(req.body.shares)) {
      sharesToAdd = req.body.shares;
    } else if (req.body.userId) {
      sharesToAdd = [{ userId: req.body.userId, permission: req.body.permission || 'viewer' }];
    } else {
      return res.status(400).json({
        success: false,
        message: 'Thông tin người nhận chia sẻ không hợp lệ',
      });
    }

    const createdShares = [];
    for (const item of sharesToAdd) {
      if (item.userId.toString() === req.user._id.toString()) {
        continue; // Don't share with creator self
      }

      const perm = ['viewer', 'editor'].includes(item.permission) ? item.permission : 'viewer';

      const share = await TaskShare.findOneAndUpdate(
        { taskId, userId: item.userId },
        { permission: perm, sharedBy },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      createdShares.push(share);
    }

    await logActivity(taskId, sharedBy, 'Chia sẻ công việc', {
      sharedCount: createdShares.length,
    });

    const populatedShares = await TaskShare.find({ taskId })
      .populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email');

    res.status(200).json({
      success: true,
      message: 'Chia sẻ công việc thành công',
      data: populatedShares,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update share permission (viewer / editor)
// @route   PATCH /api/tasks/:id/shares/:shareId
// @access  Private (Owner only)
const updateSharePermission = async (req, res, next) => {
  try {
    const { shareId } = req.params;
    const { permission } = req.body;

    if (!['viewer', 'editor'].includes(permission)) {
      return res.status(400).json({
        success: false,
        message: 'Quyền không hợp lệ, chỉ chấp nhận "viewer" hoặc "editor"',
      });
    }

    const share = await TaskShare.findOne({ _id: shareId, taskId: req.task._id });
    if (!share) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin chia sẻ',
      });
    }

    share.permission = permission;
    await share.save();

    await logActivity(req.task._id, req.user._id, 'Cập nhật quyền chia sẻ', {
      shareId,
      permission,
    });

    const populated = await TaskShare.findById(share._id)
      .populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email');

    res.status(200).json({
      success: true,
      message: 'Cập nhật quyền chia sẻ thành công',
      data: populated,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Revoke task share
// @route   DELETE /api/tasks/:id/shares/:shareId
// @access  Private (Owner only)
const revokeShare = async (req, res, next) => {
  try {
    const { shareId } = req.params;
    const share = await TaskShare.findOneAndDelete({ _id: shareId, taskId: req.task._id });

    if (!share) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin chia sẻ',
      });
    }

    await logActivity(req.task._id, req.user._id, 'Thu hồi quyền chia sẻ', {
      revokedUserId: share.userId,
    });

    res.status(200).json({
      success: true,
      message: 'Thu hồi quyền chia sẻ thành công',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getShares,
  shareTask,
  updateSharePermission,
  revokeShare,
};
