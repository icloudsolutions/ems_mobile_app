# EMS Mobile App

A Flutter mobile application for the Education Management System, designed for Students, Parents, and Teachers.

## Features

### For Students
- View personal profile and information
- Check attendance records and statistics
- View grades and GPA
- Monitor fee payments and due amounts
- Access academic information

### For Parents
- View all registered children
- Monitor children's attendance
- Track fee payments and invoices
- View report cards and academic progress
- Access detailed information for each child

### For Teachers
- View assigned students/classes
- Mark student attendance
- Enter and manage grades
- View class statistics
- Manage assignments

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Access to Odoo instance with EMS modules installed

### Installation

1. **Clone/Navigate to the project directory:**
   ```bash
   cd ems_mobile_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API settings:**
   - Open `lib/core/config/app_config.dart`
   - Update the following:
     ```dart
     static const String baseUrl = 'https://your-odoo-instance.com';
     static const String database = 'your_database';
     ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Configuration

### API Configuration

Edit `lib/core/config/app_config.dart` to configure:
- **baseUrl**: Your Odoo instance URL
- **database**: Your Odoo database name
- **apiTimeout**: API request timeout duration

### User Roles

The app automatically detects user roles based on Odoo user groups:
- **Student**: Users with student portal access
- **Parent**: Users with parent portal access  
- **Teacher**: Users with teacher/employee access

You may need to adjust the role detection logic in `lib/core/services/auth_service.dart` based on your Odoo group IDs.

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── providers/       # State management (Provider)
│   ├── router/          # Navigation routing
│   ├── services/        # API and storage services
│   └── theme/           # App theming
├── features/
│   ├── auth/            # Authentication screens
│   ├── student/         # Student-specific screens
│   ├── parent/          # Parent-specific screens
│   └── teacher/         # Teacher-specific screens
└── main.dart            # App entry point
```

## Dependencies

Key dependencies used:
- **provider**: State management
- **go_router**: Navigation
- **dio**: HTTP client
- **shared_preferences**: Local storage
- **flutter_secure_storage**: Secure credential storage
- **table_calendar**: Calendar widget for attendance
- **intl**: Internationalization and date formatting

## API Integration

The app uses Odoo's JSON-RPC API for communication. The `ApiService` class handles:
- Authentication
- CRUD operations (search_read, create, write, unlink)
- Session management

## Security

- Credentials are stored securely using `flutter_secure_storage`
- Session tokens are managed automatically
- API calls include proper authentication headers

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **API Connection Errors**
   - Verify `baseUrl` and `database` in `app_config.dart`
   - Check network connectivity
   - Ensure Odoo instance is accessible

2. **Authentication Fails**
   - Verify username/password
   - Check user has appropriate portal access in Odoo
   - Verify user groups are correctly configured

3. **No Data Displayed**
   - Check user has associated records (student/parent/teacher)
   - Verify API permissions in Odoo
   - Check console for error messages

## Development

### Adding New Features

1. Create models in `lib/core/models/`
2. Add API methods in `lib/core/services/api_service.dart`
3. Create providers in `lib/core/providers/`
4. Build screens in `lib/features/[role]/screens/`
5. Update router in `lib/core/router/app_router.dart`

### Code Style

Follow Flutter/Dart style guidelines:
- Use meaningful variable names
- Add comments for complex logic
- Follow the existing project structure
- Use Provider for state management

## License

This project is part of the Education Management System and follows the same license as the main EMS project.

## Support

For issues or questions, please contact the development team or refer to the main EMS documentation.
