# Send Push Notification Function

This Appwrite function sends push notifications to specific users using Firebase Cloud Messaging (FCM).

## Setup

1. Create a Firebase project and download the service account key
2. Replace the Firebase credentials in `src/index.js`
3. Deploy the function to Appwrite

## Usage

The function expects a JSON payload with the following structure:

```json
{
  "token": "FCM_TOKEN",
  "title": "Notification Title",
  "body": "Notification Body",
  "data": {
    "orderId": "123",
    "type": "new_order"
  }
}
```

### Required Fields
- `token`: FCM token of the target device
- `title`: Notification title
- `body`: Notification message body

### Optional Fields
- `data`: Additional data to send with the notification

## Response

Success Response:
```json
{
  "success": true,
  "message": "Push notification sent successfully",
  "messageId": "message-id-from-fcm"
}
```

Error Response:
```json
{
  "success": false,
  "message": "Error message"
}
```
