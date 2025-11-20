import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Screens
import 'add_expense_page.dart';
import 'analytics_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'home_page.dart';

void main() {
  runApp(const homepage());
}

class homepage extends StatelessWidget {
  const homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(useMaterial3: false),
      home: const HomePage(),
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

  // PageList of all icons
  // Ei list index wise kaj kore, 0 index e home screen 2 index e analytics evabe
  //  Eta Page routing e help kortese
  final List<Widget> pages = const [
    HomeScreen(),
    AddExpenseScreen(),
    AnalyticsScreen(),
    SearchScreen(),
    SettingsScreen(),

    // Center(child: Text("Home Screen")),
    // Center(child: Text("Analytics Screen")),
    // Center(child: Text("Search Screen")),
    // Center(child: Text("Settings Screen")),
  ];

// This List is use to changing the AppBar title
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
        backgroundColor: Colors.blue,

        // Status bar style
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black, // Status bar background
          statusBarIconBrightness: Brightness.light, // Status bar icons (white)
        ),
      ),

      // AppBar Ends Here

      // Body: Demo Text ; further will show full screen
      body: pages[currentIndex],

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
