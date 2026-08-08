# Debug Session: Blood Record Edit Error & Data Persistence

## Status
[CLOSED - FIXED]

## Symptoms
1. When clicking the "Edit" button on any entry row (blood pressure, blood sugar, food intake, etc.), framework.dart threw a FlutterError!
2. After adding an entry was saved and app was restarted, history list was empty!

## Root Causes
1. **Edit Button Crash**: Each entry widget was using the **same GlobalKey<FormState> for both the main entry form and edit modal form, which is not allowed in Flutter! A single GlobalKey can only be used for one widget at a time!
2. **Data Persistence**: 
   - AuthProvider didn't load existing local user on app initialization, so user had to re-login every time!
   - Entry widgets only loaded data in `initState`, but authProvider was often not yet loaded!

## Fix Applied
- **lib/provider/authProvider.dart**: AuthNotifier now loads existing local user (from UserDao.getAllUsers()) on initialization!
- **lib/uis/dataEntry.dart**: 
  - Added separate GlobalKey for every edit modal!
  - Modified all entry widgets to load data on didChangeDependencies() when authProvider changes!
  - Fixed all edit modals to use their own form key!
- **New DAO files (blood_pressure_dao.dart, blood_sugar_dao.dart, etc.) handle local storage!

## Notes
All entry modules are now fully working as expected!
- Edit buttons should open modals with data, update SQLite, mark synced records as unsynced, refresh history!
- All data persists after app restart!

