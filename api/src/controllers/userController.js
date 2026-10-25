const User = require('../models/User');

// @desc    Search users by name or email
// @route   GET /api/users/search?q=
// @access  Private
const searchUsers = async (req, res, next) => {
  try {
    const query = req.query.q ? req.query.q.trim() : '';
    if (!query) {
      return res.status(200).json({
        success: true,
        data: [],
      });
    }

    const users = await User.find({
      _id: { $ne: req.user._id }, // Exclude current user
      $or: [
        { fullName: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } },
      ],
    })
      .select('fullName email avatarUrl')
      .limit(20);

    res.status(200).json({
      success: true,
      data: users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get user public info by ID
// @route   GET /api/users/:id
// @access  Private
const getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('fullName email avatarUrl createdAt');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng',
      });
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  searchUsers,
  getUserById,
};
