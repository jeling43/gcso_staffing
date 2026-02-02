# GCSO Staffing Tracker

A modern Flutter web application for the Sheriff's Office Patrol Division that tracks current staffing by shift assignment.

## Features

- **Shift-Based Dashboard**: Real-time view of staff on duty by shift (Day, Night, Split)
- **Employee Management**: Manage Patrol employees with shift assignments
- **Schedule Management**: Anyone can view and update schedules for employees across different shifts
- **Responsive Design**: Works on desktop and mobile browsers

## Shifts

The application tracks staffing across three shifts in the Patrol Division with a **swing schedule rotation**:

### Shift Types
- **Day Shift** - Officers working daytime hours (5 employees total)
- **Night Shift** - Officers working nighttime hours (5 employees total)
- **Split Shift** - Officers working split hours (2 employees total)
  - Split 1: 1200-2400 (12:00 PM - 12:00 AM)
  - Split 2: 1400-2400 (2:00 PM - 12:00 AM)

### Shift Groups (Swing Schedule)
- **A Shift**: 6 employees (2 Day, 2 Night, 2 Split)
- **B Shift**: 6 employees (3 Day, 3 Night)

### Swing Schedule Rotation
**Pattern**: 3 days on, 2 days off, 2 days on, 3 days off (10-day cycle)
- B Shift starts: January 2, 2026
- When B is working, A is off, and vice versa

Total: 12 Patrol Division employees

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

### Deploying to GitHub Pages

This repository includes a GitHub Actions workflow for deploying to GitHub Pages:

1. **Enable GitHub Pages** in your repository:
   - Go to Settings → Pages
   - Under "Source", select "GitHub Actions"

2. **Run the deployment workflow**:
   - Go to the Actions tab
   - Select "Deploy [GitHub Pages]"
   - Click "Run workflow"
   - Select the branch (usually `main`)
   - Click "Run workflow"

3. Once the workflow completes, your app will be available at:
   `https://[username].github.io/[repository-name]/`

The workflow will:
- Build the Flutter web app
- Upload the build artifacts
- Deploy to GitHub Pages

## Project Structure

```
lib/
├── main.dart              # App entry point and navigation
├── models/                # Data models
│   ├── division.dart      # Division enum (Patrol only)
│   ├── employee.dart      # Employee model with shifts
│   └── schedule_entry.dart # Schedule entry model
├── providers/             # State management
│   ├── employee_provider.dart
│   └── schedule_provider.dart
├── screens/               # UI screens
│   ├── dashboard_screen.dart  # Shift-based dashboard
│   ├── employee_screen.dart   # Employee management
│   └── schedule_screen.dart   # Schedule management
└── widgets/               # Reusable widgets
    └── shift_card.dart    # Shift display card
```

## Technologies Used

- **Flutter** - UI framework
- **Provider** - State management
- **Material Design 3** - UI components

## License

This project is proprietary software for the Sheriff's Office.