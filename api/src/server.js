require('dotenv').config();
const http = require('http');
const cron = require('node-cron');
const app = require('./app');
const connectDB = require('./config/database');
const { checkAndSendDeadlineReminders } = require('./services/notificationService');

const PORT = process.env.PORT || 3000;

// Connect to MongoDB
connectDB();

// Schedule reminder check (runs every hour at minute 0: '0 * * * *')
// For testing/development flexibility, runs once upon start then every hour
cron.schedule('0 * * * *', () => {
  console.log('[Scheduler] Running deadline reminder check...');
  checkAndSendDeadlineReminders();
});

const server = http.createServer(app);

server.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
  console.log('[Scheduler] Deadline reminder scheduler initialized.');
});
