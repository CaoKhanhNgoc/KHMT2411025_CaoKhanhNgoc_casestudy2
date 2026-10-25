const getBaseEmailLayout = (content) => `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Segoe UI', Arial, sans-serif; background-color: #f4f6f8; margin: 0; padding: 20px; color: #333; }
    .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
    .header { background-color: #1976D2; color: #ffffff; padding: 24px; text-align: center; }
    .header h1 { margin: 0; font-size: 22px; font-weight: 600; }
    .body { padding: 24px; font-size: 15px; line-height: 1.6; }
    .task-box { background-color: #f8fafc; border-left: 4px solid #1976D2; padding: 16px; margin: 20px 0; border-radius: 0 6px 6px 0; }
    .task-title { font-size: 17px; font-weight: bold; color: #1976D2; margin-bottom: 8px; }
    .meta-row { margin: 6px 0; font-size: 13px; color: #555; }
    .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
    .badge-high { background-color: #ffebee; color: #c62828; }
    .badge-medium { background-color: #fff8e1; color: #f57f17; }
    .badge-low { background-color: #e8f5e9; color: #2e7d32; }
    .footer { background-color: #f8fafc; padding: 16px; text-align: center; font-size: 12px; color: #888; border-top: 1px solid #edf2f7; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Hệ Thống Quản Lý Công Việc Nhóm</h1>
    </div>
    <div class="body">
      ${content}
    </div>
    <div class="footer">
      <p>Email này được gửi tự động từ hệ thống Task Manager. Vui lòng không trả lời trực tiếp.</p>
    </div>
  </div>
</body>
</html>
`;

const getTaskAssignedTemplate = ({ task, assigner, isPrimary }) => {
  const content = `
    <p>Xin chào,</p>
    <p><strong>${assigner.fullName}</strong> đã giao cho bạn một công việc mới${isPrimary ? ' với vai trò <strong>Phụ trách chính</strong>' : ''}:</p>
    <div class="task-box">
      <div class="task-title">${task.title}</div>
      <div class="meta-row"><strong>Mô tả:</strong> ${task.description || 'Không có mô tả'}</div>
      <div class="meta-row"><strong>Mức ưu tiên:</strong> <span class="badge badge-${task.priority}">${task.priority.toUpperCase()}</span></div>
      <div class="meta-row"><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Chưa đặt hạn'}</div>
    </div>
    <p>Vui lòng đăng nhập ứng dụng Task Manager để theo dõi và thực hiện công việc.</p>
  `;
  return getBaseEmailLayout(content);
};

const getTaskSharedTemplate = ({ task, sharer, permission }) => {
  const roleName = permission === 'editor' ? 'Chỉnh sửa (Editor)' : 'Chỉ xem (Viewer)';
  const content = `
    <p>Xin chào,</p>
    <p><strong>${sharer.fullName}</strong> đã chia sẻ công việc với bạn với quyền: <strong>${roleName}</strong>:</p>
    <div class="task-box">
      <div class="task-title">${task.title}</div>
      <div class="meta-row"><strong>Mô tả:</strong> ${task.description || 'Không có mô tả'}</div>
      <div class="meta-row"><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Chưa đặt hạn'}</div>
    </div>
    <p>Bạn có thể mở ứng dụng Task Manager để xem hoặc cùng tham gia công việc.</p>
  `;
  return getBaseEmailLayout(content);
};

const getTaskUpdatedTemplate = ({ task, updater, changesText }) => {
  const content = `
    <p>Xin chào,</p>
    <p>Công việc <strong>"${task.title}"</strong> vừa được cập nhật bởi <strong>${updater.fullName}</strong>:</p>
    <div class="task-box">
      <div class="task-title">${task.title}</div>
      <div class="meta-row"><strong>Nội dung thay đổi:</strong> ${changesText || 'Thông tin công việc được chỉnh sửa'}</div>
      <div class="meta-row"><strong>Trạng thái hiện tại:</strong> ${task.status}</div>
      <div class="meta-row"><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Chưa đặt hạn'}</div>
    </div>
    <p>Vui lòng kiểm tra lại tiến độ trên ứng dụng.</p>
  `;
  return getBaseEmailLayout(content);
};

const getTaskCompletedTemplate = ({ task, completer }) => {
  const content = `
    <p>Xin chào,</p>
    <p>🎉 Công việc <strong>"${task.title}"</strong> đã được đánh dấu <strong>HOÀN THÀNH</strong> bởi <strong>${completer.fullName}</strong>.</p>
    <div class="task-box">
      <div class="task-title">${task.title}</div>
      <div class="meta-row"><strong>Ngày hoàn thành:</strong> ${new Date().toLocaleDateString('vi-VN')}</div>
    </div>
    <p>Cảm ơn các thành viên đã hoàn thành công việc đúng hạn!</p>
  `;
  return getBaseEmailLayout(content);
};

const getTaskReminderTemplate = ({ task }) => {
  const content = `
    <p>Xin chào,</p>
    <p>⏰ <strong>Nhắc việc:</strong> Công việc sau đây sắp đến hạn hoàn thành trong vòng 24 giờ tới:</p>
    <div class="task-box">
      <div class="task-title">${task.title}</div>
      <div class="meta-row"><strong>Mức ưu tiên:</strong> <span class="badge badge-${task.priority}">${task.priority.toUpperCase()}</span></div>
      <div class="meta-row"><strong>Hạn hoàn thành:</strong> <span style="color: #c62828; font-weight: bold;">${task.dueDate ? new Date(task.dueDate).toLocaleString('vi-VN') : 'Sắp đến hạn'}</span></div>
    </div>
    <p>Vui lòng sắp xếp thời gian để hoàn thành công việc đúng tiến độ.</p>
  `;
  return getBaseEmailLayout(content);
};

module.exports = {
  getTaskAssignedTemplate,
  getTaskSharedTemplate,
  getTaskUpdatedTemplate,
  getTaskCompletedTemplate,
  getTaskReminderTemplate,
};
