const EmailLog = require('../models/EmailLog');
const { retryEmail } = require('../services/emailService');

// @desc    Get email logs for a task
// @route   GET /api/tasks/:id/email-logs
// @access  Private
const getTaskEmailLogs = async (req, res, next) => {
  try {
    const emailLogs = await EmailLog.find({ taskId: req.task._id })
      .select('-htmlContent')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: emailLogs,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Retry sending failed email
// @route   POST /api/email-logs/:id/retry
// @access  Private
const retryFailedEmail = async (req, res, next) => {
  try {
    const result = await retryEmail(req.params.id);

    res.status(200).json({
      success: result.success,
      message: result.success ? 'Đã thử gửi lại email thành công' : 'Gửi lại email thất bại',
      data: result.emailLog,
      error: result.error,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTaskEmailLogs,
  retryFailedEmail,
};
