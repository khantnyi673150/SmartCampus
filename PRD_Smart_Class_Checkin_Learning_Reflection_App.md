# Product Requirement Document (PRD)
## Smart Class Check-in & Learning Reflection App

## Problem Statement
Universities still use manual attendance methods such as paper sign-in sheets or roll calls. These methods are slow, easy to manipulate, and difficult to track over time. Instructors also lack structured data about student learning progress for each class session.

The system should provide a simple digital solution that verifies physical attendance using QR code + GPS, and collects short reflection data before and after class.

## Target User
- **Students:** Check in/check out, submit reflections, and confirm attendance status.
- **Instructors:** Review attendance and reflection records.
- **Department/Admin staff:** Monitor attendance data for reporting.

## Feature List

- **Home Screen:** Buttons for Check-in, Finish Class, and View Records.
- **Check-in Flow:** Enter student info, scan classroom QR, capture GPS and timestamp, submit pre-class reflection.
- **Finish Class Flow:** Enter student info, scan QR again, capture GPS and timestamp, submit post-class reflection.
- **Records View:** Separate Check-in and Check-out history, searchable records, attendance sheet, map link for GPS location.
- **Attendance Status:** Show `Finished` when both check-in and check-out exist for the same student/day, otherwise `Not finished`.
- **Local Storage:** Save all data on device for offline-friendly lab testing.

## User Flow
1. Student opens app from Home Screen.
2. Student selects **Check-in**.
3. Student enters Student ID and Name.
4. Student fills pre-class reflection.
5. Student scans classroom QR and submits check-in.
6. After class, student selects **Finish Class**.
7. Student enters Student ID and Name, fills post-class reflection.
8. Student scans classroom QR and submits check-out.
9. Student/instructor opens **View Records** to check history and attendance sheet.

## Data Fields
- `studentId`
- `studentName`
- `timestamp`
- `latitude`
- `longitude`
- `qrValue`
- `previousTopic`
- `expectedTopic`
- `mood`
- `learnedToday`
- `feedback`
- `attendance` (`Finished` / `Not finished`)

## Tech Stack
- **Framework:** Flutter
- **Language:** Dart
- **GPS:** Geolocator
- **QR Scanner:** Mobile Scanner
- **Local Storage:** Shared Preferences (prototype local storage)
- **Web Hosting:** Firebase Hosting
