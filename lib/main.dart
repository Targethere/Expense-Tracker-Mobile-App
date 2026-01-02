import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Screens
import 'add_expense_page.dart';
import 'analytics_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'home_page.dart';
import 'screens/login_screen.dart';

// Providers
import 'providers/expense_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/preferences_provider.dart';

// Services
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermissions();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PreferencesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// Auth Wrapper to check authentication status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading screen while checking auth
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If authenticated, set user ID in expense provider and show home
        if (authProvider.isAuthenticated) {
          // Set user ID in expense provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
            final preferencesProvider = Provider.of<PreferencesProvider>(context, listen: false);
            
            expenseProvider.setUserId(authProvider.currentUserId!);
            expenseProvider.setProviders(preferencesProvider, authProvider);
          });
          
          return const HomePage();
        }

        // Not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  // Ei list index wise kaj kore, 0 index e home screen, 1 index e add screen,
  // 2 index e analytics, evabe. Eta page routing e help kortese.
  final List<Widget> pages = const [
    HomeScreen(),
    AddExpenseScreen(),
    AnalyticsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  // Ei list ta use hocche AppBar er title change korar jonno
  final List<String> titles = [
    "Expense Tracker",
    "Add Expense",
    "Analytics",
    "Search",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(titles[currentIndex]),
        backgroundColor: const Color.fromARGB(255, 6, 129, 211),

        // Status bar style
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black, // Status bar background
          statusBarIconBrightness: Brightness.light, // Status bar icons (white)
        ),
      ),
      // AppBar Ends Here

      // Body: index onujayi page dekhabe
      body: pages[currentIndex],
      // etar mane holo, index wise routing korbe, dhoro 'currentIndex = 1' hole AddExpenseScreen dekhabe

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: "Analytics",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
