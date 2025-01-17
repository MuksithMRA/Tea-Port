const admin = require('firebase-admin');

module.exports = async function (req, res) {
    // Initialize Firebase Admin SDK
    if (!admin.apps.length) {
        admin.initializeApp({
            credential: admin.credential.cert({
                // Add your Firebase Admin SDK credentials here
                "type": "service_account",
                "project_id": "your-project-id",
                // ... other credentials from your service account key
            })
        });
    }

    try {
        const payload = JSON.parse(req.payload);
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
                    channelId: 'tea_serve_channel',
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
        
        return res.json({
            success: true,
            message: 'Push notification sent successfully',
            messageId: response
        });
    } catch (error) {
        console.error('Error sending push notification:', error);
        
        return res.json({
            success: false,
            message: error.message || 'Error sending push notification'
        }, 500);
    }
};
