import 'package:flutter/material.dart'; // package that adds buttons functions
import 'login.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(ElderlyCareApp());
}

/// Home Page

class ElderlyCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'ElderNest App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),

      /// Routes 
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => BottomTabScreen(),
        '/register': (context) => RegisterScreen(),
        '/menu': (context) => MenuTab(), 
      },
    );
  }
}



/// Bottom Panel 

class BottomTabScreen extends StatefulWidget {

  final bool showWelcome; // Add this line


  const BottomTabScreen({Key? key, this.showWelcome = false}) : super(key: key); // Modify constructor


  @override
  _BottomTabScreenState createState() => _BottomTabScreenState();
}

class _BottomTabScreenState extends State<BottomTabScreen> {
  int _currentIndex = 0;
  late final HomeTab _homeTab;
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _homeTab = HomeTab(showWelcome: widget.showWelcome);  // 👈 only once on login

    _screens = [
      _homeTab,
      MedicineTab(),
      ProfileTab(),
      MenuTab(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication),label: 'Medicine',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],

      ),
    );
  }
}



// /// Home Tab 

// class HomeTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('🏠 Home')),
//       body: Center(
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         'Welcome',
//         style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: Colors.teal,
//         ),
//       ),
//       SizedBox(height: 16),
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 24.0),
//         child: Text(
//           'Your one-stop solution for managing elderly care with compassion. Stay connected, organized, and supportive for your loved ones—all in one app.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

//     );
//   }
// }




/// Home Tab

class HomeTab extends StatefulWidget {

  final bool showWelcome;

  const HomeTab({Key? key, this.showWelcome = false}) : super(key: key);


  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  bool _showWelcomeOverlay = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _uniqueCode = '';

  @override
  void initState() {
    super.initState();
    loadUniqueCode();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.showWelcome) {
      setState(() {
        _showWelcomeOverlay = true;
      });

      _controller.forward();

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse().then((_) {
            setState(() {
              _showWelcomeOverlay = false;
            });
          });
        }
      });
    }
  }


  void loadUniqueCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('uniqueCode') ?? 'Not found';
    setState(() {
      _uniqueCode = code;
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏘 Home'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content of the Home tab
          Center(
              child: Text(
                'Your Unique Code: $_uniqueCode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ),

          // Welcome overlay
          if (_showWelcomeOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to ElderNest!',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        CircularProgressIndicator(color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  }




/// Medicine Tab


class MedicineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👨🏾‍⚕️ Medicine'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_liquid, size: 80, color: Colors.teal),
            SizedBox(height: 24),
            Text(
              'Medicine Management',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Keep track of your prescriptions, doses, and medicine reminders to stay on top of your health needs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add/view medicines page
              },
              icon: Icon(Icons.add_alarm),
              label: Text("Set Reminder"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




/// Profile Tab

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}



class _ProfileTabState extends State<ProfileTab> {
  String name = '';
  String email = '';
  String uniqueCode = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'NA';
      email = prefs.getString('email') ?? 'NA';
      uniqueCode = prefs.getString('uniqueCode') ?? 'NA';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👤 Profile'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              name ?? '',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              email ?? '',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            Divider(thickness: 1.2),
            SizedBox(height: 10),
            Text(
              'View and edit your profile.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📝 Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Menu',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                // Navigate to login screen and remove previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // login route
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}




