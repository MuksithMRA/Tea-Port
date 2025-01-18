const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

module.exports = async function (req, res) {
    try {
        // Load config file
        const configPath = path.join(__dirname, 'config.json');
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

        // Initialize Firebase Admin SDK
        if (!admin.apps.length) {
            admin.initializeApp({
                credential: admin.credential.cert(config.firebase)
            });
        }
        console.log(req.req.body);

        // Handle payload based on request type
        const payload = typeof req.req.body === 'string' ? JSON.parse(req.req.body) : req.req.body;

        if (!payload) {
            throw new Error('No payload provided');
        }

        const { token, title, body, data } = payload;

        // Validate required fields
        if (!token || !title || !body) {
            throw new Error('Missing required fields: token, title, or body');
        }

        // Prepare notification message
        const message = {
            token: token,
            notification: {
                title: title,
                body: body
            },
            data: data || {},
            android: {
                priority: 'high',
                notification: {
                    channelId: 'tea_port_channel',
                    priority: 'high',
                    sound: 'default',
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            },
            apns: {
                headers: {
                    'apns-priority': '10'
                },
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        'content-available': 1
                    }
                }
            }
        };

        // Send the message
        const response = await admin.messaging().send(message);

        return {
            success: true,
            message: 'Push notification sent successfully',
            messageId: response
        };
    } catch (error) {
        console.error('Error sending push notification:', error);

        throw new Error(error.message || 'Error sending push notification');
    }
};
