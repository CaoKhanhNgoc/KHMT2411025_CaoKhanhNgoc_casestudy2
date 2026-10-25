const Notification = require('../models/Notification');
const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const User = require('../models/User');
const { sendEmail } = require('./emailService');
const {
  getTaskAssignedTemplate,
  getTaskSharedTemplate,
  getTaskUpdatedTemplate,
  getTaskCompletedTemplate,
  getTaskReminderTemplate,
} = require('../utils/emailTemplates');

// In-app Notification helper
const createInAppNotification = async ({ userId, taskId, type, title, message }) => {
  try {
    return await Notification.create({
      userId,
      taskId,
      type,
      title,
      message,
    });
  } catch (error) {
    console.error('Failed to create in-app notification:', error.message);
  }
};

// 1. Notify Task Assigned
const notifyTaskAssigned = async (task, assigner, assigneeUsers) => {
  for (const user of assigneeUsers) {
    if (user._id.toString() === assigner._id.toString()) continue;

    const isPrimary = task.primaryAssigneeId && task.primaryAssigneeId.toString() === user._id.toString();
    const title = 'Bạn được giao công việc mới';
    const message = `${assigner.fullName} đã giao công việc "${task.title}" cho bạn${isPrimary ? ' (Phụ trách chính)' : ''}.`;

    // In-app
    await createInAppNotification({
      userId: user._id,
      taskId: task._id,
      type: 'assigned',
      title,
      message,
    });

    // Email
    if (user.email) {
      const htmlContent = getTaskAssignedTemplate({ task, assigner, isPrimary });
      await sendEmail({
        taskId: task._id,
        recipientEmail: user.email,
        eventType: 'TASK_ASSIGNED',
        subject: `[Task Manager] ${title}: ${task.title}`,
        htmlContent,
      });
    }
  }
};

// 2. Notify Task Shared
const notifyTaskShared = async (task, sharer, sharedUser, permission) => {
  if (sharedUser._id.toString() === sharer._id.toString()) return;

  const roleName = permission === 'editor' ? 'chỉnh sửa (Editor)' : 'chỉ xem (Viewer)';
  const title = 'Công việc được chia sẻ với bạn';
  const message = `${sharer.fullName} đã chia sẻ công việc "${task.title}" với quyền ${roleName}.`;

  // In-app
  await createInAppNotification({
    userId: sharedUser._id,
    taskId: task._id,
    type: 'shared',
    title,
    message,
  });

  // Email
  if (sharedUser.email) {
    const htmlContent = getTaskSharedTemplate({ task, sharer, permission });
    await sendEmail({
      taskId: task._id,
      recipientEmail: sharedUser.email,
      eventType: 'TASK_SHARED',
      subject: `[Task Manager] ${title}: ${task.title}`,
      htmlContent,
    });
  }
};

// 3. Notify Task Updated
const notifyTaskUpdated = async (task, updater, changesText) => {
  // Collect all stakeholders (creator + assignees + editors) except updater
  const stakeholderIds = new Set();
  if (task.createdBy.toString() !== updater._id.toString()) {
    stakeholderIds.add(task.createdBy.toString());
  }
  task.assigneeIds.forEach((id) => {
    if (id.toString() !== updater._id.toString()) {
      stakeholderIds.add(id.toString());
    }
  });

  const shares = await TaskShare.find({ taskId: task._id });
  shares.forEach((s) => {
    if (s.userId.toString() !== updater._id.toString()) {
      stakeholderIds.add(s.userId.toString());
    }
  });

  const users = await User.find({ _id: { $in: Array.from(stakeholderIds) } });

  for (const user of users) {
    const title = 'Công việc có thông tin thay đổi';
    const message = `${updater.fullName} đã cập nhật công việc "${task.title}".`;

    await createInAppNotification({
      userId: user._id,
      taskId: task._id,
      type: 'updated',
      title,
      message,
    });

    if (user.email) {
      const htmlContent = getTaskUpdatedTemplate({ task, updater, changesText });
      await sendEmail({
        taskId: task._id,
        recipientEmail: user.email,
        eventType: 'TASK_UPDATED',
        subject: `[Task Manager] Cập nhật công việc: ${task.title}`,
        htmlContent,
      });
    }
  }
};

// 4. Notify Task Completed
const notifyTaskCompleted = async (task, completer) => {
  const stakeholderIds = new Set();
  if (task.createdBy.toString() !== completer._id.toString()) {
    stakeholderIds.add(task.createdBy.toString());
  }
  task.assigneeIds.forEach((id) => {
    if (id.toString() !== completer._id.toString()) {
      stakeholderIds.add(id.toString());
    }
  });

  const users = await User.find({ _id: { $in: Array.from(stakeholderIds) } });

  for (const user of users) {
    const title = 'Công việc đã hoàn thành';
    const message = `${completer.fullName} đã hoàn thành công việc "${task.title}".`;

    await createInAppNotification({
      userId: user._id,
      taskId: task._id,
      type: 'completed',
      title,
      message,
    });

    if (user.email) {
      const htmlContent = getTaskCompletedTemplate({ task, completer });
      await sendEmail({
        taskId: task._id,
        recipientEmail: user.email,
        eventType: 'TASK_COMPLETED',
        subject: `[Task Manager] Hoàn thành công việc: ${task.title}`,
        htmlContent,
      });
    }
  }
};

// 5. Automatic Deadline Reminders (tasks due within next 24 hours)
const checkAndSendDeadlineReminders = async () => {
  try {
    const now = new Date();
    const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const upcomingTasks = await Task.find({
      status: { $ne: 'completed' },
      dueDate: { $gte: now, $lte: in24Hours },
    }).populate('assigneeIds');

    for (const task of upcomingTasks) {
      for (const user of task.assigneeIds) {
        // Prevent duplicate reminder within 12 hours
        const recentReminder = await Notification.findOne({
          userId: user._id,
          taskId: task._id,
          type: 'reminder',
          createdAt: { $gte: new Date(now.getTime() - 12 * 60 * 60 * 1000) },
        });

        if (!recentReminder) {
          const title = 'Nhắc việc: Sắp đến hạn hoàn thành';
          const message = `Công việc "${task.title}" sắp đến hạn trong vòng 24 giờ tới.`;

          await createInAppNotification({
            userId: user._id,
            taskId: task._id,
            type: 'reminder',
            title,
            message,
          });

          if (user.email) {
            const htmlContent = getTaskReminderTemplate({ task });
            await sendEmail({
              taskId: task._id,
              recipientEmail: user.email,
              eventType: 'TASK_REMINDER',
              subject: `[Task Manager] ${title}: ${task.title}`,
              htmlContent,
            });
          }
        }
      }
    }
  } catch (error) {
    console.error('Error during deadline reminder check:', error.message);
  }
};

module.exports = {
  createInAppNotification,
  notifyTaskAssigned,
  notifyTaskShared,
  notifyTaskUpdated,
  notifyTaskCompleted,
  checkAndSendDeadlineReminders,
};
