# Smart Class Check-in & Learning Reflection App

Mobile lab-test prototype for university attendance verification and learning reflection.

## Project Overview
This app allows students to:
- Check in before class
- Check out after class
- Verify attendance with QR scan + GPS location
- Submit pre-class and post-class reflection forms
- View records and attendance sheet with search and map links

## Main Features
- **Home Screen** with 3 actions: Check-in, Finish Class, View Records
- **Check-in Flow**
	- Student ID + Student Name
	- Previous topic, expected topic, mood
	- QR scan + GPS + timestamp capture
- **Finish Class Flow**
	- Student ID + Student Name
	- Learned today + feedback
	- QR scan + GPS + timestamp capture
- **View Records**
	- Separate Check-in and Check-out history
	- Attendance Sheet table view
	- Search by ID, name, date, time, status
	- `Open in Maps` action for GPS coordinates
- **Attendance Status Rule**
	- `Finished`: same student has both check-in and check-out on the same day
	- `Not finished`: checked in but no matching check-out

## Tech Stack
- Flutter + Dart
- `geolocator` (GPS)
- `mobile_scanner` (QR code scan)
- `shared_preferences` (local prototype storage)
- Firebase Hosting (web deployment)

## Project Structure
- `lib/screens/` – UI screens (`home`, `checkin`, `finish_class`, `records`, `qr_scanner`)
- `lib/models/` – data models
- `lib/data/local_db.dart` – local storage and attendance logic
- `lib/services/location_service.dart` – GPS permission/location handling
- `PRD_Smart_Class_Checkin_Learning_Reflection_App.md` – short PRD

## Run Locally
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build Web
```bash
flutter build web
```

## Firebase Hosting Deployment
This project is configured to deploy to:
- `smart-campus-checkin-2026`

Deploy command:
```bash
firebase deploy --only hosting
```

## GitHub Repository
- https://github.com/khantnyi673150/SmartCampus
