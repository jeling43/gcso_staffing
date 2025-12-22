# Shift Assignment Guide

## Overview
The GCSO Staffing application now provides a simple and clear way to assign employees to specific shifts with both shift group (A or B) and shift time (Days, Nights, or Split shifts).

## How Shift Assignment Works

### Shift Components
Each employee can be assigned to a shift that consists of two parts:

1. **Shift Group**: Either "A" or "B"
   - These groups follow a swing schedule: 3 days on, 2 days off, 2 days on, 3 days off
   - When Group A is working, Group B is off, and vice versa

2. **Shift Time**: The time period they work
   - **Day**: Daytime hours (06:00-18:00)
   - **Night**: Nighttime hours (18:00-06:00)  
   - **Split-1200**: Split shift (12:00-24:00)
   - **Split-1400**: Split shift (14:00-02:00)

### Full Shift Assignment Example
- "B Shift - Day" = B group working daytime hours
- "A Shift - Night" = A group working nighttime hours
- "B Shift - Split-1200" = B group working 12:00-24:00 split shift

## Assigning Shifts to Employees

### For New Employees
1. Navigate to the **Employees** screen
2. Click the **"Add Employee"** floating action button (supervisors only)
3. Fill in employee details (name, badge number, rank)
4. Select **Shift Group**: Choose "A Shift" or "B Shift"
5. Select **Shift Time**: Choose "Days", "Nights", "Split 1200", or "Split 1400"
6. Click **"Add"** to save

### For Existing Employees
1. Navigate to the **Employees** screen
2. Click the edit icon next to the employee you want to modify (supervisors only)
3. Update the **Shift Group** and/or **Shift Time** as needed
4. Click **"Save"** to apply changes

### Viewing Shift Assignments
On the **Employees** screen, each employee's card displays their full shift assignment in the subtitle:
```
LT Johnson #P001
Sarah Johnson • Supervisor
B Shift - Day
```

## Benefits of This System

1. **Clear Visibility**: Easily see what shift each employee is assigned to
2. **Flexible Assignment**: Assign any combination of shift group and time
3. **Simple Management**: Change assignments through an intuitive UI
4. **Automatic Scheduling**: The system automatically determines who's on duty based on the swing schedule

## Technical Details

- Shift assignments are stored in the `Employee` model with `shiftGroup` and `shiftType` properties
- The schedule provider automatically creates schedule entries based on these assignments
- The swing schedule calculation determines which shift group works on any given day
