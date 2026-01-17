# Firebase Configuration via App Settings

The EMS Mobile App now supports configuring Firebase directly from the app settings, eliminating the need to modify code or use configuration files.

## How to Configure

### Step 1: Access Settings

1. Log in to the app (as Student, Parent, or Teacher)
2. Tap the **Settings** icon (⚙️) in the app bar
3. Navigate to the **Firebase Configuration** section

### Step 2: Get Firebase Configuration Values

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your Firebase project (or create a new one)
3. Click the **Settings** (gear icon) → **Project settings**
4. Scroll down to **Your apps** section
5. Select your app (or add a new Android/iOS app)

### Step 3: Copy Configuration Values

From the Firebase project settings, copy these values:

- **API Key**: Found in "General" tab → "Your apps" → Web API Key
- **App ID**: Found in "General" tab → "Your apps" → App ID
- **Messaging Sender ID**: Found in "Cloud Messaging" tab → Sender ID
- **Project ID**: Found in "General" tab → Project ID
- **Storage Bucket** (Optional): Found in "General" tab → Storage bucket
- **Auth Domain** (Optional): Found in "Authentication" tab → Authorized domains

### Step 4: Enter Values in App

1. In the app settings screen, enter each value in the corresponding field
2. Tap **Save Firebase Configuration**
3. **Restart the app** for changes to take effect

## What Happens After Configuration

- Firebase will be initialized automatically on next app launch
- Push notifications will be enabled
- FCM token will be generated and sent to your Odoo backend
- You'll start receiving push notifications

## Notification Settings

In addition to Firebase configuration, you can also control:

- **Enable Notifications**: Toggle push notifications on/off
- **Notification Sound**: Enable/disable sound for notifications
- **Vibration**: Enable/disable vibration for notifications

## Troubleshooting

### Firebase Not Initializing

- Verify all required fields are filled (API Key, App ID, Sender ID, Project ID)
- Check that values are copied correctly (no extra spaces)
- Restart the app after saving settings
- Check console logs for error messages

### Notifications Not Working

1. **Check Firebase Configuration**:
   - Ensure all required fields are filled
   - Verify values are correct
   - Restart app after configuration

2. **Check Notification Permissions**:
   - Go to device Settings → Apps → EMS Mobile → Notifications
   - Ensure notifications are enabled

3. **Check App Settings**:
   - Ensure "Enable Notifications" is turned on in app settings

4. **Verify FCM Token**:
   - Check app logs for FCM token generation
   - Verify token is sent to backend

### Settings Not Saving

- Check device storage permissions
- Ensure app has write access
- Try restarting the app

## Security Notes

- Firebase configuration values are stored locally on the device
- API keys are safe to include in client apps (they're public)
- Never share your Firebase Server Key (different from API Key)

## Benefits of In-App Configuration

1. **No Code Changes**: Configure Firebase without modifying code
2. **Easy Updates**: Update Firebase project without rebuilding app
3. **Multiple Environments**: Switch between dev/staging/prod easily
4. **User-Friendly**: Non-technical users can configure Firebase
5. **Flexible**: Works for different Firebase projects

## Next Steps

After configuring Firebase:

1. Test push notifications from Firebase Console
2. Set up backend integration to send notifications from Odoo
3. Configure notification preferences
4. Test notification delivery

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Firebase Console for project status
3. Verify all configuration values are correct
4. Check app logs for detailed error messages
