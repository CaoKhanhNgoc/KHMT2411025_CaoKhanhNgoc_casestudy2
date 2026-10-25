const TaskActivity = require('../models/TaskActivity');

const logActivity = async (taskId, userId, action, details = {}) => {
  try {
    await TaskActivity.create({
      taskId,
      userId,
      action,
      details,
    });
  } catch (error) {
    console.error('Error logging task activity:', error.message);
  }
};

module.exports = { logActivity };
