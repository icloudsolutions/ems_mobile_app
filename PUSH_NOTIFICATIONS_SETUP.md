# Push Notifications Setup Guide

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in the EMS Mobile App.

## Prerequisites

1. **Firebase Account**: Create a Firebase project at https://console.firebase.google.com
2. **Flutter Firebase CLI**: Install Firebase CLI tools
3. **Android/iOS Development Environment**: Set up for platform-specific configuration

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name (e.g., "EMS Mobile")
4. Follow the setup wizard
5. Enable Google Analytics (optional)

## Step 2: Add Firebase to Your Flutter App

### Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase

```bash
cd ems_mobile_app
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select platforms (Android, iOS, Web)
- Generate configuration files automatically

## Step 3: Android Configuration

### Update Android Files

1. **android/app/build.gradle**:
   - Ensure `minSdkVersion` is at least 21
   - Add Google Services plugin

2. **android/build.gradle**:
   - Add Google Services classpath

3. **android/app/src/main/AndroidManifest.xml**:
   - Add internet permission (if not already present)
   - Configure notification channel

### Google Services File

The `flutterfire configure` command should have created:
- `android/app/google-services.json`

If not, download it from Firebase Console:
1. Go to Project Settings
2. Select Android app
3. Download `google-services.json`
4. Place it in `android/app/`

## Step 4: iOS Configuration

### Update iOS Files

1. **ios/Podfile**:
   - Ensure platform is iOS 10.0 or higher

2. **ios/Runner/Info.plist**:
   - Add notification permissions

### Google Services File

The `flutterfire configure` command should have created:
- `ios/Runner/GoogleService-Info.plist`

If not, download it from Firebase Console:
1. Go to Project Settings
2. Select iOS app
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

### Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and enable "Remote notifications"

## Step 5: Update App Configuration

### Update app_config.dart

No changes needed - the notification service uses Firebase automatically.

### Verify Dependencies

Run:
```bash
flutter pub get
```

## Step 6: Test Notifications

### Get FCM Token

1. Run the app
2. Check console logs for FCM token
3. Copy the token

### Send Test Notification

1. Go to Firebase Console
2. Navigate to Cloud Messaging
3. Click "Send your first message"
4. Enter notification title and text
5. Click "Send test message"
6. Paste your FCM token
7. Send

## Step 7: Backend Integration (Odoo)

### Store FCM Tokens in Odoo

The app automatically sends FCM tokens to Odoo when:
- User logs in
- Token is refreshed

You'll need to:
1. Add `fcm_token` field to `res.users` model in Odoo
2. Create an API endpoint to receive tokens
3. Store tokens for sending notifications

### Send Notifications from Odoo

Use Firebase Admin SDK or FCM REST API to send notifications:

```python
# Example Odoo code
import requests

def send_notification(user_id, title, body, data=None):
    user = env['res.users'].browse(user_id)
    if not user.fcm_token:
        return
    
    url = 'https://fcm.googleapis.com/fcm/send'
    headers = {
        'Authorization': 'key=YOUR_SERVER_KEY',
        'Content-Type': 'application/json',
    }
    payload = {
        'to': user.fcm_token,
        'notification': {
            'title': title,
            'body': body,
        },
        'data': data or {},
    }
    requests.post(url, json=payload, headers=headers)
```

## Step 8: Notification Types

The app supports different notification types:

- **attendance**: Attendance-related notifications
- **fee**: Fee payment reminders
- **grade**: Grade updates
- **announcement**: General announcements

### Example Notification Payload

```json
{
  "notification": {
    "title": "New Grade Posted",
    "body": "Your Math exam grade has been posted"
  },
  "data": {
    "type": "grade",
    "student_id": "123",
    "subject": "Math"
  }
}
```

## Troubleshooting

### Android Issues

1. **Notifications not showing**:
   - Check notification channel is created
   - Verify Google Services JSON is correct
   - Check app has notification permissions

2. **Token not generated**:
   - Verify internet connection
   - Check Firebase configuration
   - Review console logs

### iOS Issues

1. **Notifications not showing**:
   - Verify Push Notifications capability is enabled
   - Check APNs certificates in Firebase
   - Ensure device is registered for remote notifications

2. **Permission denied**:
   - Check Info.plist permissions
   - Verify notification settings in iOS Settings

### General Issues

1. **Background messages not working**:
   - Ensure `firebaseMessagingBackgroundHandler` is top-level
   - Check background message handler is registered

2. **Token not sent to backend**:
   - Verify API service is initialized
   - Check network connectivity
   - Review API logs

## Security Considerations

1. **Server Key**: Keep Firebase Server Key secure
2. **Token Storage**: FCM tokens are stored securely
3. **User Privacy**: Only send relevant notifications
4. **Rate Limiting**: Implement rate limiting on backend

## Next Steps

1. Set up notification preferences in app
2. Implement notification categories
3. Add notification actions
4. Set up notification scheduling
5. Implement notification analytics

## Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [FCM REST API](https://firebase.google.com/docs/cloud-messaging/send-message)
