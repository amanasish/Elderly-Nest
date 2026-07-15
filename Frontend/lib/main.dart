import 'package:flutter/material.dart'; // package that adds buttons functions
import 'login.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'config.dart';
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(ElderlyCareApp());
}

/// Home Page

class ElderlyCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'ElderNest App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[850],
          ),
          themeMode: currentMode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => BottomTabScreen(),
            '/register': (context) => RegisterScreen(),
            '/menu': (context) => MenuTab(), 
          },
        );
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
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Intercept/prevent popping
        }
        return false; // Intercept/prevent popping (stay on Home)
      },
      child: Scaffold(
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
/// Home Tab

class HomeTab extends StatefulWidget {
  final bool showWelcome;
  const HomeTab({Key? key, this.showWelcome = false}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  bool _showWelcomeOverlay = false;
  late AnimationController _welcomeController;
  late Animation<double> _welcomeScaleAnimation;

  late AnimationController _contentController;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;
  late Animation<double> _fadeAnimation;

  String _uniqueCode = '';

  @override
  void initState() {
    super.initState();
    loadUniqueCode();

    _welcomeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _welcomeScaleAnimation = CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOutBack,
    );

    _contentController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation1 = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _slideAnimation2 = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _contentController.forward();

    if (widget.showWelcome) {
      setState(() {
        _showWelcomeOverlay = true;
      });
      _welcomeController.forward();
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _welcomeController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showWelcomeOverlay = false;
              });
            }
          });
        }
      });
    }
  }

  void loadUniqueCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('uniqueCode') ?? 'Not found';
    if (mounted) {
      setState(() {
        _uniqueCode = code;
      });
    }
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('🏘 Home', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) {
              return IconButton(
                icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
                onPressed: () {
                  themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey.shade900, Colors.black],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.teal.shade50, Colors.white],
                    ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation1,
                      child: Card(
                        elevation: 4,
                        shadowColor: isDark ? Colors.black54 : Colors.teal.withOpacity(0.2),
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(Icons.volunteer_activism, size: 60, color: Colors.teal),
                              SizedBox(height: 12),
                              Text(
                                "Welcome to ElderNest",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.tealAccent : Colors.teal.shade800),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Connecting caretakers and elders with care and compassion.",
                                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation2,
                      child: Card(
                        elevation: 4,
                        shadowColor: isDark ? Colors.black54 : Colors.teal.withOpacity(0.2),
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Share Your Unique Code",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.tealAccent : Colors.teal.shade700),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Give this code to your caregiver or elder to link accounts.",
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade700 : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _uniqueCode,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: isDark ? Colors.white : Colors.black87),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.copy, color: isDark ? Colors.tealAccent : Colors.teal),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _uniqueCode));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Code copied to clipboard!')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showWelcomeOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: ScaleTransition(
                    scale: _welcomeScaleAnimation,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 60, color: Colors.teal),
                          SizedBox(height: 16),
                          Text(
                            'Welcome to ElderNest!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          CircularProgressIndicator(color: Colors.teal),
                        ],
                      ),
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

class MedicineTab extends StatefulWidget {
  @override
  _MedicineTabState createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;

  List<dynamic> reminders = [];
  bool isLoadingReminders = false;
  String userId = '';

  @override
  void initState() {
    super.initState();
    loadUserIdAndReminders();
  }

  Future<void> loadUserIdAndReminders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
    if (userId.isNotEmpty) {
      fetchReminders();
    }
  }

  Future<void> fetchReminders() async {
    setState(() => isLoadingReminders = true);
    final url = Uri.parse('${Config.baseUrl}/getReminders/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 1) {
          setState(() {
            reminders = res['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching reminders: $e");
    } finally {
      setState(() => isLoadingReminders = false);
    }
  }

  Future<void> addReminder(String medicineName, String time, String frequency) async {
    final url = Uri.parse('${Config.baseUrl}/addReminder');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'medicineName': medicineName,
          'time': time,
          'frequency': frequency
        }),
      );
      final res = jsonDecode(response.body);
      if (response.statusCode == 200 && res['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder added!')));
        fetchReminders();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding reminder.')));
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final url = Uri.parse('${Config.baseUrl}/deleteReminder');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'reminderId': reminderId}),
      );
      final res = jsonDecode(response.body);
      if (response.statusCode == 200 && res['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reminder deleted!')));
        fetchReminders();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting reminder.')));
    }
  }

  Future<void> searchMedicine() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
      searchResults = [];
    });

    final url = Uri.parse('https://rxnav.nlm.nih.gov/REST/drugs.json?name=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final drugGroup = data['drugGroup'];
        if (drugGroup != null && drugGroup['conceptGroup'] != null) {
          final List<dynamic> concepts = [];
          for (var group in drugGroup['conceptGroup']) {
            if (group['conceptProperties'] != null) {
              concepts.addAll(group['conceptProperties']);
            }
          }
          setState(() {
            searchResults = concepts;
          });
        }
      }
      if (searchResults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No drugs found with that name.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching drug information.')),
      );
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  void _showAddReminderDialog(String defaultName) {
    String selectedFrequency = 'Daily';
    TimeOfDay selectedTime = TimeOfDay.now();
    TextEditingController nameCtrl = TextEditingController(text: defaultName);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Add Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Medicine Name'),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time: ${selectedTime.format(context)}'),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(context: context, initialTime: selectedTime);
                        if (time != null) {
                          setStateDialog(() => selectedTime = time);
                        }
                      },
                      child: Text('Pick Time'),
                    )
                  ],
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  items: ['Daily', 'Weekly', 'As Needed'].map((freq) {
                    return DropdownMenuItem(value: freq, child: Text(freq));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedFrequency = val);
                  },
                  decoration: InputDecoration(labelText: 'Frequency'),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    addReminder(nameCtrl.text, selectedTime.format(context), selectedFrequency);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              )
            ],
          );
        });
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('👨🏾‍⚕️ Medicine', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.alarm), text: 'Reminders'),
              Tab(icon: Icon(Icons.search), text: 'Search Drugs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Reminders
            isLoadingReminders
                ? Center(child: CircularProgressIndicator())
                : reminders.isEmpty
                    ? Center(
                        child: Text("No reminders found. Search drugs to add one!"),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final rem = reminders[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(Icons.medication, color: Colors.teal, size: 36),
                              title: Text(rem['medicineName'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${rem['time']} • ${rem['frequency']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteReminder(rem['_id']),
                              ),
                            ),
                          );
                        },
                      ),
            // Tab 2: Search
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Enter drug name (e.g., Aspirin)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: searchMedicine,
                        child: Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (isSearching)
                    CircularProgressIndicator()
                  else
                    Expanded(
                      child: searchResults.isEmpty
                          ? Center(
                              child: Text(
                                "Search for a universal drug to see details",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final drug = searchResults[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  elevation: 2,
                                  shadowColor: Colors.teal.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.medication, color: Colors.teal, size: 24),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                drug['name'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal.shade900,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add_alarm, color: Colors.teal),
                                              onPressed: () => _showAddReminderDialog(drug['name'] ?? ''),
                                              tooltip: 'Add Reminder',
                                            )
                                          ],
                                        ),
                                        if (drug['synonym'] != null && drug['synonym'].toString().isNotEmpty) ...[
                                          SizedBox(height: 8),
                                          Text("SYNONYM", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                          Text(drug['synonym'], style: TextStyle(fontSize: 13, fontFamily: 'Courier')),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                ],
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
  String userId = '';
  bool isLoading = false;
  List<dynamic> linkedAccounts = [];

  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'NA';
      email = prefs.getString('email') ?? 'NA';
      uniqueCode = prefs.getString('uniqueCode') ?? 'NA';
      userId = prefs.getString('userId') ?? 'NA';
    });
    
    if (userId != 'NA' && userId.isNotEmpty) {
      fetchProfileData();
    }
  }

  Future<void> fetchProfileData() async {
    final url = Uri.parse('${Config.baseUrl}/userProfile/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 1 && res['data'] != null) {
          setState(() {
            linkedAccounts = res['data']['linkedUsers'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> unlinkUser(String elderId) async {
    final url = Uri.parse('${Config.baseUrl}/unlinkUser');
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'elderId': elderId,
        }),
      );
      final res = jsonDecode(response.body);
      if (response.statusCode == 200 && res['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account unlinked successfully!')),
        );
        fetchProfileData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to unlink account.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> linkUser() async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid unique code.')),
      );
      return;
    }

    if (code == uniqueCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot link with your own code.')),
      );
      return;
    }

    if (userId == 'NA' || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log out and log back in to activate linking.')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('${Config.baseUrl}/linkUser');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'uniqueCode': code,
        }),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 && res['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Accounts linked successfully!')),
        );
        codeController.clear();
        fetchProfileData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to link account.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to connect to server.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👤 Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shadowColor: Colors.teal.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal.shade50,
                        child: Icon(Icons.person, size: 60, color: Colors.teal),
                      ),
                      SizedBox(height: 20),
                      Text(
                        name,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'My Code: $uniqueCode',
                          style: TextStyle(fontSize: 13, color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 4,
                shadowColor: Colors.teal.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Link Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Enter the Unique Code of the Elder you want to link with.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: codeController,
                        decoration: InputDecoration(
                          labelText: "Elder's Unique Code",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: linkUser,
                              icon: Icon(Icons.add),
                              label: Text('Link Elder'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (linkedAccounts.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Linked Accounts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
                SizedBox(height: 12),
                ...linkedAccounts.map((account) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade50,
                        child: Icon(Icons.person, color: Colors.teal),
                      ),
                      title: Text(account['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${account['email'] ?? ''}\nCode: ${account['uniqueCode']}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.link_off, color: Colors.red),
                        onPressed: () => unlinkUser(account['_id']),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
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
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text('Logout', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              children: [
                Text(
                  "© 2026 Aman Asish Gupta",
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Made with ❤️ Eldernest",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




