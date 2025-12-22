# Changelog

## [Unreleased]

### Changed
- Simplified `ShiftCard` widget to display only shift name and color
  - Removed staff list display from the card itself
  - Made the card more compact and focused on shift identification
  
### Added
- Added `shiftType` property to `Employee` model for tracking shift time assignment (Days, Nights, Split-1200, Split-1400)
- Added `shiftAssignment` getter to `Employee` for displaying full shift information (e.g., "B Shift - Days")
- Added shift group (A/B) and shift time dropdowns to employee Add/Edit dialogs
- Employee screen now displays shift assignments directly in the employee list

### Improved
- Employee shift assignment is now more explicit with dedicated fields
- Schedule provider now uses employee's `shiftType` property instead of ID-based logic
- Better UI for assigning employees to specific shift combinations (e.g., "B shift nights", "A split 1200")
