const validateTaskInput = (data) => {
  const errors = {};
  const { title, priority, status } = data;

  if (!title || title.trim() === '') {
    errors.title = 'Tiêu đề công việc không được để trống';
  } else if (title.length > 200) {
    errors.title = 'Tiêu đề không được vượt quá 200 ký tự';
  }

  if (priority && !['low', 'medium', 'high'].includes(priority)) {
    errors.priority = 'Mức độ ưu tiên phải là low, medium hoặc high';
  }

  if (status && !['todo', 'in_progress', 'completed'].includes(status)) {
    errors.status = 'Trạng thái phải là todo, in_progress hoặc completed';
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
};

module.exports = { validateTaskInput };
