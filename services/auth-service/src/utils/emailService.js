const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const sesClient = new SESClient({
  region: process.env.AWS_REGION || 'us-east-1'
});

const SENDER_EMAIL = process.env.SES_SENDER_EMAIL || 'noreply@calmroot.com';

const sendEmergencyAlert = async ({
  contactName,
  contactEmail,
  userName,
  userFirstName,
  relationship,
  riskLevel,
}) => {
  const subject = `Checking in on ${userFirstName} — A gentle heads up from CalmRoot`;

  const htmlBody = `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: 'DM Sans', Arial, sans-serif; background: #F7F5F0; margin: 0; padding: 20px; }
    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
    .header { background: linear-gradient(135deg, #2D5A3D, #4A7C59); padding: 32px; text-align: center; }
    .header h1 { color: white; margin: 0; font-size: 24px; }
    .header p { color: rgba(255,255,255,0.8); margin: 8px 0 0; }
    .body { padding: 32px; }
    .body p { color: #2C3E2D; line-height: 1.6; }
    .tip-box { background: #EEF2EC; border-left: 4px solid #4A7C59; border-radius: 8px; padding: 16px; margin: 20px 0; }
    .crisis { background: #FEF2F2; border: 1px solid #FCA5A5; border-radius: 8px; padding: 16px; margin: 20px 0; }
    .crisis p { color: #991B1B; margin: 0; }
    .footer { background: #0D1117; padding: 20px; text-align: center; }
    .footer p { color: #8B949E; font-size: 12px; margin: 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🌿 CalmRoot</h1>
      <p>Wellness Support Network</p>
    </div>
    <div class="body">
      <p>Hi <strong>${contactName}</strong>,</p>
      
      <p>You're receiving this because <strong>${userName}</strong> 
      listed you as their trusted ${relationship} in CalmRoot, 
      a mental health support platform.</p>
      
      <p>Our wellness AI has noticed that 
      <strong>${userFirstName}</strong> may be going through 
      a challenging time emotionally. This is <strong>not an 
      emergency alert</strong>, but a gentle heads-up so you 
      can check in with them.</p>
      
      <div class="tip-box">
        <p><strong>💚 Simple ways you can help:</strong></p>
        <ul>
          <li>Send a text saying you're thinking of them</li>
          <li>Invite them for a walk, coffee, or a call</li>
          <li>Just listen without judgment</li>
          <li>Remind them they are loved and not alone</li>
        </ul>
      </div>
      
      <div class="crisis">
        <p>🆘 If you believe ${userFirstName} is in 
        <strong>immediate danger</strong>, please:<br/>
        Call iCall: <strong>9152987821</strong> | 
        Emergency: <strong>112</strong></p>
      </div>
      
      <p>Thank you for being part of 
      <strong>${userFirstName}'s</strong> support network. 
      Your care makes a real difference. 💙</p>
      
      <p>Warm regards,<br/>The CalmRoot Team</p>
    </div>
    <div class="footer">
      <p>This message was sent by CalmRoot's wellness monitoring system.</p>
      <p>${userName} consented to this notification during registration.</p>
      <p>© 2025 CalmRoot. Ground Yourself. Grow Together.</p>
    </div>
  </div>
</body>
</html>`;

  const textBody = `
Hi ${contactName},

You're receiving this because ${userName} listed you as their 
trusted ${relationship} in CalmRoot.

Our wellness AI has noticed ${userFirstName} may be going through 
a challenging time. Please consider reaching out to check on them.

Simple ways to help:
- Send a text saying you're thinking of them
- Invite them for a walk or call
- Just listen without judgment

If you believe they are in immediate danger:
iCall: 9152987821 | Emergency: 112

Thank you for being part of their support network.

The CalmRoot Team
`;

  try {
    await sesClient.send(new SendEmailCommand({
      Source: SENDER_EMAIL,
      Destination: {
        ToAddresses: [contactEmail]
      },
      Message: {
        Subject: { Data: subject, Charset: 'UTF-8' },
        Body: {
          Html: { Data: htmlBody, Charset: 'UTF-8' },
          Text: { Data: textBody, Charset: 'UTF-8' }
        }
      }
    }));
    console.log(`✅ Emergency alert sent to ${contactEmail}`);
    return { success: true };
  } catch (error) {
    console.error('SES send failed:', error);
    return { success: false, error: error.message };
  }
};

module.exports = { sendEmergencyAlert };
