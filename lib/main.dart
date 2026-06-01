import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/database_helper.dart';
import 'screens/dashboard_screen.dart';
import 'screens/guests_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/check_in_out_screen.dart';
import 'screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos los colores base
    const primaryNavy = Color(0xFF14213D);
    const accentGold = Color(0xFFFCA311);
    const backgroundGrey = Color(0xFFF8F9FA);

    return MaterialApp(
      title: 'Hotel SingaINN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentGold,
          surface: backgroundGrey,
        ),
        scaffoldBackgroundColor: backgroundGrey,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .copyWith(
              headlineMedium: GoogleFonts.playfairDisplay(
                color: primaryNavy,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: GoogleFonts.playfairDisplay(
                color: primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
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
            borderSide: const BorderSide(color: primaryNavy, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GuestsScreen(),
    const ReservationsScreen(),
    const CheckInOutScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hotel SingaINN',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF14213D),
        elevation: 0,
        centerTitle: false,
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFFCA311).withValues(alpha: 0.2),
            selectedIconTheme: const IconThemeData(color: Color(0xFFFCA311)),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: GoogleFonts.inter(
              color: const Color(0xFF14213D),
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: GoogleFonts.inter(color: Colors.grey),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Huéspedes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online_outlined),
                selectedIcon: Icon(Icons.book_online),
                label: Text('Reservas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.meeting_room_outlined),
                selectedIcon: Icon(Icons.meeting_room),
                label: Text('Check-In/Out'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Reportes'),
              ),
            ],
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: Color(0xFFE0E0E0),
          ),
          // Contenido Principal
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
