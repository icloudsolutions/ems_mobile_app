# EMS Mobile App - Setup Guide

## Quick Start

1. **Install Flutter** (if not already installed)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Configure the App**
   ```dart
   // Edit lib/core/config/app_config.dart
   static const String baseUrl = 'https://your-odoo-server.com';
   static const String database = 'your_database_name';
   ```

3. **Install Dependencies**
   ```bash
   cd ems_mobile_app
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Odoo Configuration

### Required Odoo Modules
- `ics_ems_core` - Core EMS module
- `ics_ems_parent_portal` - Parent portal access
- Portal module (standard Odoo)

### User Setup

1. **For Students:**
   - Create user in Odoo
   - Link to `ics.student` record via `user_id` field
   - Grant portal access

2. **For Parents:**
   - Create user in Odoo
   - Link to `ics.parent` record via `user_id` field
   - Grant portal access
   - Associate with student records

3. **For Teachers:**
   - Create user in Odoo
   - Link to `ics.teacher` record via `user_id` field
   - Grant appropriate access rights

### API Access

The app uses Odoo's JSON-RPC API. Ensure:
- JSON-RPC is enabled on your Odoo instance
- Users have appropriate access rights
- CORS is configured if needed (for web builds)

## Testing

### Test Users

Create test users in Odoo for each role:
- Student user with linked student record
- Parent user with linked parent record and associated students
- Teacher user with linked teacher record

### Test Login

Use the credentials created above to test login functionality.

## Customization

### Theme Colors

Edit `lib/core/theme/app_theme.dart` to customize:
- Primary color
- Secondary color
- Accent color
- App bar styling

### Adding Features

1. **New Screen:**
   - Create in appropriate `features/[role]/screens/` directory
   - Add route in `lib/core/router/app_router.dart`

2. **New API Endpoint:**
   - Add method in `lib/core/services/api_service.dart`
   - Use in provider or service

3. **New Model:**
   - Create in `lib/core/models/`
   - Add fromJson/toJson methods

## Troubleshooting

### Build Errors
- Run `flutter clean` then `flutter pub get`
- Check Flutter version: `flutter --version`
- Ensure all dependencies are compatible

### Runtime Errors
- Check API configuration (baseUrl, database)
- Verify user credentials
- Check Odoo logs for API errors
- Enable debug mode: `flutter run --debug`

### No Data Showing
- Verify user has associated records in Odoo
- Check API permissions
- Review console logs for errors
- Test API endpoints directly

## Next Steps

1. Customize theme and branding
2. Add additional features as needed
3. Configure push notifications (optional)
4. Set up CI/CD for builds
5. Deploy to app stores
