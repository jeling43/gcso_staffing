# GCSO Staffing Tracker

A modern Flutter web application for the Sheriff's Office that tracks current staffing across divisions.

## Features

- **Staffing Dashboard**: Real-time view of staff on duty across all divisions (Jail, Patrol, Courthouse)
- **On-Call Tracking**: Track which employees are on-call for each division
- **Employee Management**: Manage employees with division assignments (employees can only be assigned to one division)
- **Schedule Management**: Supervisors can update schedules for employees
- **Responsive Design**: Works on desktop and mobile browsers

## Divisions

The application tracks staffing across three main divisions:
- **Jail** - Security staff at the county jail
- **Patrol** - Officers on patrol duty
- **Courthouse** - Staff assigned to courthouse security

## User Roles

- **Supervisors**: Can add/edit employees, update schedules, and manage on-call assignments
- **Regular Employees**: Can view staffing information and schedules

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0.0 or higher)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/jeling43/gcso_staffing.git
   cd gcso_staffing
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the web app:
   ```bash
   flutter run -d chrome
   ```

### Building for Production

```bash
flutter build web
```

The built files will be in `build/web/`.

## Project Structure

```
lib/
├── main.dart              # App entry point and navigation
├── models/                # Data models
│   ├── division.dart      # Division enum
│   ├── employee.dart      # Employee model
│   ├── schedule_entry.dart # Schedule entry model
│   └── on_call_assignment.dart # On-call assignment model
├── providers/             # State management
│   ├── employee_provider.dart
│   ├── schedule_provider.dart
│   └── on_call_provider.dart
├── screens/               # UI screens
│   ├── dashboard_screen.dart
│   ├── on_call_screen.dart
│   ├── employee_screen.dart
│   └── schedule_screen.dart
└── widgets/               # Reusable widgets
    └── division_card.dart
```

## Technologies Used

- **Flutter** - UI framework
- **Provider** - State management
- **Material Design 3** - UI components

## License

This project is proprietary software for the Sheriff's Office.