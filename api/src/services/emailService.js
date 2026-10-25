const transporter = require('../config/email');
const EmailLog = require('../models/EmailLog');

const sendEmail = async ({
  taskId = null,
  recipientEmail,
  eventType,
  subject,
  htmlContent,
}) => {
  let emailLog;
  try {
    emailLog = await EmailLog.create({
      taskId,
      recipientEmail,
      eventType,
      subject,
      htmlContent,
      status: 'pending',
      attempts: 0,
    });
  } catch (err) {
    console.error('Failed to create email log:', err.message);
  }

  try {
    const fromAddress = process.env.EMAIL_FROM || '"Task Manager" <no-reply@taskmanager.com>';
    
    // Only attempt actual transport send if SMTP settings or ethereal configured
    const mailOptions = {
      from: fromAddress,
      to: recipientEmail,
      subject,
      html: htmlContent,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`Email sent [${eventType}] to ${recipientEmail}: ${info.messageId || 'OK'}`);

    if (emailLog) {
      emailLog.status = 'sent';
      emailLog.sentAt = new Date();
      emailLog.attempts += 1;
      await emailLog.save();
    }

    return { success: true, emailLog };
  } catch (error) {
    console.error(`Email sending failed [${eventType}] to ${recipientEmail}:`, error.message);

    if (emailLog) {
      emailLog.status = 'failed';
      emailLog.errorMessage = error.message;
      emailLog.attempts += 1;
      await emailLog.save();
    }

    return { success: false, error: error.message, emailLog };
  }
};

const retryEmail = async (emailLogId) => {
  const emailLog = await EmailLog.findById(emailLogId);
  if (!emailLog) {
    throw new Error('Không tìm thấy bản ghi email cần gửi lại');
  }

  try {
    const fromAddress = process.env.EMAIL_FROM || '"Task Manager" <no-reply@taskmanager.com>';
    const mailOptions = {
      from: fromAddress,
      to: emailLog.recipientEmail,
      subject: emailLog.subject,
      html: emailLog.htmlContent,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`Retry email succeeded to ${emailLog.recipientEmail}: ${info.messageId || 'OK'}`);

    emailLog.status = 'sent';
    emailLog.sentAt = new Date();
    emailLog.errorMessage = null;
    emailLog.attempts += 1;
    await emailLog.save();

    return { success: true, emailLog };
  } catch (error) {
    console.error(`Retry email failed to ${emailLog.recipientEmail}:`, error.message);
    emailLog.status = 'failed';
    emailLog.errorMessage = error.message;
    emailLog.attempts += 1;
    await emailLog.save();

    return { success: false, error: error.message, emailLog };
  }
};

module.exports = {
  sendEmail,
  retryEmail,
};
