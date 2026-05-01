const nodemailer = require('nodemailer');

const sendWaitlistEmail = async (userEmail, referralCode, position) => {
    console.log('📬 Attempting to send email using host:', process.env.EMAIL_HOST);
    
    try {
        const transporter = nodemailer.createTransport({
            host: process.env.EMAIL_HOST,
            port: parseInt(process.env.EMAIL_PORT) || 587,
            secure: false, 
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS,
            },
            tls: {
                rejectUnauthorized: false
            }
        });

        const mailOptions = {
            from: `"FormForge AI" <${process.env.EMAIL_USER}>`,
            to: userEmail,
            subject: 'Welcome to FormForge AI! 🚀',
            html: `
                <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: auto; padding: 30px; background-color: #000; color: #fff; border-radius: 20px;">
                    <div style="text-align: center; margin-bottom: 30px;">
                        <h1 style="color: #4ade80; margin: 0; font-size: 28px;">FORMFORGE AI</h1>
                        <p style="color: #666; text-transform: uppercase; letter-spacing: 2px; font-size: 10px;">Verification Successful</p>
                    </div>

                    <h2 style="text-align: center; font-size: 24px; margin-bottom: 10px;">You're in the elite.</h2>
                    <p style="text-align: center; color: #aaa; margin-bottom: 30px;">Thanks for joining the waitlist. Here is your current standing:</p>
                    
                    <div style="display: flex; justify-content: center; gap: 20px; margin-bottom: 30px; text-align: center;">
                        <div style="background: #111; border: 1px solid #333; padding: 20px; border-radius: 15px; width: 45%;">
                            <p style="margin: 0; font-size: 10px; color: #666; text-transform: uppercase;">Waitlist Rank</p>
                            <h2 style="margin: 5px 0; font-size: 32px; color: #fff;">#${position}</h2>
                        </div>
                    </div>

                    <div style="background: #111; border: 1px solid #4ade80; padding: 25px; border-radius: 20px; text-align: center; margin-bottom: 30px;">
                        <p style="margin: 0; font-size: 10px; color: #4ade80; text-transform: uppercase; letter-spacing: 1px;">Your Referral Code</p>
                        <h1 style="margin: 10px 0; font-size: 42px; letter-spacing: 5px; font-family: monospace;">${referralCode}</h1>
                        <p style="margin: 0; color: #666; font-size: 12px;">Share this code with friends to boost your rank!</p>
                    </div>

                    <p style="text-align: center; font-size: 14px; color: #aaa; line-height: 1.6;">
                        Every person who signs up using your code will move you up the line. 
                        Keep an eye on your inbox for early access updates.
                    </p>
                    
                    <div style="text-align: center; margin-top: 40px; border-top: 1px solid #222; padding-top: 20px;">
                        <p style="font-size: 10px; color: #444; text-transform: uppercase; letter-spacing: 1px;">FormForge AI Team &copy; 2026</p>
                    </div>
                </div>
            `,
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('✅ Email sent: %s', info.messageId);
    } catch (error) {
        console.error('❌ Email Service Error:', error);
    }
};

module.exports = { sendWaitlistEmail };
