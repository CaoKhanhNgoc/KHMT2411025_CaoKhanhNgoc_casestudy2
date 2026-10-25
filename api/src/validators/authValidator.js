const validateRegisterInput = (data) => {
  const errors = {};
  const { fullName, email, password } = data;

  if (!fullName || fullName.trim() === '') {
    errors.fullName = 'Họ tên không được để trống';
  }

  if (!email || email.trim() === '') {
    errors.email = 'Email không được để trống';
  } else if (!/^\S+@\S+\.\S+$/.test(email)) {
    errors.email = 'Email không đúng định dạng';
  }

  if (!password) {
    errors.password = 'Mật khẩu không được để trống';
  } else if (password.length < 6) {
    errors.password = 'Mật khẩu phải có ít nhất 6 ký tự';
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
};

const validateLoginInput = (data) => {
  const errors = {};
  const { email, password } = data;

  if (!email || email.trim() === '') {
    errors.email = 'Email không được để trống';
  }

  if (!password) {
    errors.password = 'Mật khẩu không được để trống';
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
};

const validateChangePasswordInput = (data) => {
  const errors = {};
  const { currentPassword, newPassword } = data;

  if (!currentPassword) {
    errors.currentPassword = 'Mật khẩu hiện tại không được để trống';
  }

  if (!newPassword) {
    errors.newPassword = 'Mật khẩu mới không được để trống';
  } else if (newPassword.length < 6) {
    errors.newPassword = 'Mật khẩu mới phải có ít nhất 6 ký tự';
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
};

module.exports = {
  validateRegisterInput,
  validateLoginInput,
  validateChangePasswordInput,
};
