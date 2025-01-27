importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDjJFBvOClSS9imP9mhb8hDCQ4iLkyJDu8",
    authDomain: "medoment-tea-serve.firebaseapp.com",
    projectId: "medoment-tea-serve",
    storageBucket: "medoment-tea-serve.firebasestorage.app",
    messagingSenderId: "47791069713",
    appId: "1:47791069713:web:81e6fafe094631aae26fb0"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.setBackgroundMessageHandler(function(payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    const notificationTitle = payload.notification.title || 'Background Message';
    const notificationOptions = {
        body: payload.notification.body || '',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        tag: payload.data?.type || 'default',
        data: payload.data || {},
        requireInteraction: true,
        actions: [
            {
                action: 'open',
                title: 'Open'
            }
        ]
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});
