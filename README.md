# Case Study 2 - Ứng Dụng Quản Lý và Giao Công Việc Nhóm

## 📌 Thông Tin Sinh Viên
- **Họ và tên:** Cao Khánh Ngọc
- **Mã số sinh viên (MSSV):** KHMT2411025
- **Tên Repository GitHub:** `casestudy2_KHMT2411025_CaoKhanhNgoc`
- **Công nghệ sử dụng:** Flutter • Node.js/Express REST API • MongoDB • Email Notification (Nodemailer)

---

## 📂 Cấu Trúc Dự Án
```
casestudy2/
├── README.md                 # Thông tin sinh viên & hướng dẫn chạy dự án
├── .gitignore
├── api/                      # Backend REST API (Node.js, Express, MongoDB Mongoose)
│   ├── package.json
│   ├── .env.example
│   └── src/
│       ├── server.js
│       ├── app.js
│       ├── config/           # Cấu hình MongoDB, Nodemailer Transporter
│       ├── controllers/      # Bộ điều khiển nghiệp vụ (Auth, Task, Assignment, Share, Notification, Statistics)
│       ├── middleware/       # JWT Auth, Phân quyền (Viewer/Editor/Owner), Validation, Error handling
│       ├── models/           # Mongoose Schemas (User, Task, TaskShare, Notification, EmailLog, TaskActivity)
│       ├── routes/           # REST API Endpoints
│       ├── services/         # Email Service, Notification Service, Task Scheduler nhắc việc
│       ├── utils/            # Mẫu email HTML
│       └── validators/       # Kiểm tra hợp lệ dữ liệu đầu vào
└── TaskManager/              # Frontend Mobile App (Flutter)
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── models/           # Dart Data Models
        ├── services/         # API Client & Services tương tác Backend
        ├── screens/          # Giao diện (Auth, Tasks, Assignment, Sharing, Notifications, Profile/Stats)
        ├── widgets/          # Reusable Widgets (TaskCard, Badges, UserSelector, LoadingView)
        └── utils/            # Định dạng ngày giờ, Constants, Validators
```

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### 1. Backend API (`api/`)
1. Truy cập thư mục `api`:
   ```bash
   cd api
   ```
2. Cài đặt các thư viện:
   ```bash
   npm install
   ```
3. Tạo file `.env` từ `.env.example`:
   ```env
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/task_manager_db
   JWT_SECRET=super_secret_jwt_key_2411025
   JWT_EXPIRES_IN=7d
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_SECURE=false
   SMTP_USER=your_email@gmail.com
   SMTP_PASS=your_app_password
   EMAIL_FROM=Task Manager <no-reply@taskmanager.com>
   ```
4. Khởi chạy server:
   ```bash
   npm run dev
   # Hoặc npm start
   ```
   API sẽ chạy tại: `http://localhost:3000/api`

### 2. Frontend Flutter (`TaskManager/`)
1. Truy cập thư mục `TaskManager`:
   ```bash
   cd TaskManager
   ```
2. Cài đặt các gói Flutter:
   ```bash
   flutter pub get
   ```
3. Chạy ứng dụng trên thiết bị giả lập / thật / Windows / Chrome:
   ```bash
   flutter run
   ```
   *Lưu ý: Đối với Android Emulator, cấu hình API URL trỏ tới `http://10.0.2.2:3000/api` (đã được cấu hình tự động trong `api_client.dart`).*

---

## 🌿 Danh Sách Nhánh Git (Git Branches)
- `main`: Nhánh chính chứa toàn bộ mã nguồn tích hợp hoàn chỉnh.
- `feature/A-auth-and-account`: Chức năng Quản lý tài khoản và xác thực (Đăng ký, Đăng nhập, Đăng xuất, Cập nhật thông tin, Đổi mật khẩu).
- `feature/B-task-management`: Chức năng Quản lý công việc (CRUD công việc, trạng thái, mức độ ưu tiên, ngày bắt đầu & hạn chót, tìm kiếm, lọc, sắp xếp).
- `feature/C-assignment-and-sharing`: Chức năng Giao việc và Chia sẻ phân quyền (Chỉ định người phụ trách chính, cấp quyền Viewer/Editor, thu hồi quyền).
- `feature/D-notifications-and-email`: Chức năng Thông báo trong ứng dụng & Gửi email tự động khi giao việc/chia sẻ/hoàn thành, nhắc việc đến hạn.
- `feature/E-statistics-and-utilities`: Thống kê số liệu công việc, Lịch sử hoạt động (Activity log), Tiện ích giao diện.
