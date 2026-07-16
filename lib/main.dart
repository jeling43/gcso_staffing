import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GCSOStaffingApp());
}

/// Main application widget for GCSO Staffing Tracker
class GCSOStaffingApp extends StatelessWidget {
  const GCSOStaffingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProxyProvider<EmployeeProvider, ScheduleProvider>(
          create: (context) =>
              ScheduleProvider(context.read<EmployeeProvider>().employees),
          update: (context, employeeProvider, previous) {
            if (previous == null) {
              return ScheduleProvider(employeeProvider.employees);
            }
            previous.updateEmployees(employeeProvider.employees);
            return previous;
          },
        ),
      ],
      child: MaterialApp(
        title: 'GCSO Staffing Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F172A), // Slate-900
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 2,
            highlightElevation: 4,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: const Color(0xFF0F172A),
            selectedIconTheme:
                const IconThemeData(color: Colors.white, size: 26),
            unselectedIconTheme:
                IconThemeData(color: Colors.white.withOpacity(0.7), size: 24),
            selectedLabelTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
            unselectedLabelTextStyle:
                TextStyle(color: Colors.white.withOpacity(0.7)),
            indicatorColor: Colors.white.withOpacity(0.2),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 8,
            indicatorColor: const Color(0xFF0F172A).withOpacity(0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                );
              }
              return TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
            }),
          ),
          dividerTheme: DividerThemeData(
            color: Colors.grey.shade200,
            thickness: 1,
          ),
        ),
        home: const MainNavigationShell(),
      ),
    );
  }
}

/// Main navigation shell with bottom navigation
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    BadgeDashboardScreen(),
    ProtectedScreen(child: DashboardScreen()),
    ProtectedScreen(child: EmployeeScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use rail navigation for larger screens
        if (constraints.maxWidth > 600) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  extended: constraints.maxWidth > 800,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: constraints.maxWidth > 800
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'GCSO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shield,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.badge_outlined),
                      selectedIcon: Icon(Icons.badge),
                      label: Text('On-Duty Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Staffing Overview'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Employees'),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      child: _screens[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Use bottom navigation for smaller screens
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge),
                  label: 'On-Duty',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Staffing',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Employees',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
