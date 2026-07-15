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
    return Scaffold(
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF6F51FF).withOpacity(0.2),
                        child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF6F51FF)),
                      ),
                      SizedBox(height: 16),
                      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3B3B4F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF6F51FF)),
                            SizedBox(width: 8),
                            Text("Code: $uniqueCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Link Another Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: linkCodeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Unique Code',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.link_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF6F51FF)))
                          : ElevatedButton.icon(
                              onPressed: linkUser,
                              icon: Icon(Icons.add_rounded, color: Colors.white),
                              label: Text('Link Elder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6F51FF),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ...linkedAccounts.map((account) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2B2B36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF6F51FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person_rounded, color: Color(0xFF6F51FF)),
                      ),
                      title: Text(account['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${account['email'] ?? ''}
Code: ${account['uniqueCode']}', style: TextStyle(color: Colors.grey.shade400, height: 1.4)),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.link_off_rounded, color: Colors.redAccent.withOpacity(0.8)),
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
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF6F51FF).withOpacity(0.2),
                        child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF6F51FF)),
                      ),
                      SizedBox(height: 16),
                      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3B3B4F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF6F51FF)),
                            SizedBox(width: 8),
                            Text("Code: $uniqueCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Link Another Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: linkCodeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Unique Code',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.link_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF6F51FF)))
                          : ElevatedButton.icon(
                              onPressed: linkUser,
                              icon: Icon(Icons.add_rounded, color: Colors.white),
                              label: Text('Link Elder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6F51FF),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ...linkedAccounts.map((account) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2B2B36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF6F51FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person_rounded, color: Color(0xFF6F51FF)),
                      ),
                      title: Text(account['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${account['email'] ?? ''}
Code: ${account['uniqueCode']}', style: TextStyle(color: Colors.grey.shade400, height: 1.4)),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.link_off_rounded, color: Colors.redAccent.withOpacity(0.8)),
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
    return Scaffold(
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF6F51FF).withOpacity(0.2),
                        child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF6F51FF)),
                      ),
                      SizedBox(height: 16),
                      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3B3B4F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF6F51FF)),
                            SizedBox(width: 8),
                            Text("Code: $uniqueCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Link Another Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: linkCodeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Unique Code',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.link_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF6F51FF)))
                          : ElevatedButton.icon(
                              onPressed: linkUser,
                              icon: Icon(Icons.add_rounded, color: Colors.white),
                              label: Text('Link Elder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6F51FF),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ...linkedAccounts.map((account) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2B2B36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF6F51FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person_rounded, color: Color(0xFF6F51FF)),
                      ),
                      title: Text(account['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${account['email'] ?? ''}
Code: ${account['uniqueCode']}', style: TextStyle(color: Colors.grey.shade400, height: 1.4)),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.link_off_rounded, color: Colors.redAccent.withOpacity(0.8)),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reminder added!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF6F51FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reminder deleted!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ));
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
          SnackBar(content: Text('No drugs found with that name.', style: TextStyle(color: Colors.white))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching drug information.', style: TextStyle(color: Colors.white))),
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
            backgroundColor: Color(0xFF2B2B36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Medicine Name',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    fillColor: Color(0xFF1C1C23),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1C23),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time: ${selectedTime.format(context)}', style: TextStyle(color: Colors.white, fontSize: 16)),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: selectedTime);
                          if (time != null) {
                            setStateDialog(() => selectedTime = time);
                          }
                        },
                        child: Text('Pick', style: TextStyle(color: Color(0xFF6F51FF), fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  dropdownColor: Color(0xFF2B2B36),
                  style: TextStyle(color: Colors.white),
                  items: ['Daily', 'Weekly', 'As Needed'].map((freq) {
                    return DropdownMenuItem(value: freq, child: Text(freq));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedFrequency = val);
                  },
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    fillColor: Color(0xFF1C1C23),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6F51FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    addReminder(nameCtrl.text, selectedTime.format(context), selectedFrequency);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save', style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF6F51FF).withOpacity(0.2),
                        child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF6F51FF)),
                      ),
                      SizedBox(height: 16),
                      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3B3B4F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF6F51FF)),
                            SizedBox(width: 8),
                            Text("Code: $uniqueCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Link Another Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: linkCodeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Unique Code',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.link_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF6F51FF)))
                          : ElevatedButton.icon(
                              onPressed: linkUser,
                              icon: Icon(Icons.add_rounded, color: Colors.white),
                              label: Text('Link Elder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6F51FF),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ...linkedAccounts.map((account) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2B2B36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF6F51FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person_rounded, color: Color(0xFF6F51FF)),
                      ),
                      title: Text(account['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${account['email'] ?? ''}
Code: ${account['uniqueCode']}', style: TextStyle(color: Colors.grey.shade400, height: 1.4)),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.link_off_rounded, color: Colors.redAccent.withOpacity(0.8)),
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
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF6F51FF).withOpacity(0.2),
                        child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF6F51FF)),
                      ),
                      SizedBox(height: 16),
                      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3B3B4F)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF6F51FF)),
                            SizedBox(width: 8),
                            Text("Code: $uniqueCode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Link Another Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: linkCodeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Unique Code',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.link_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF6F51FF)))
                          : ElevatedButton.icon(
                              onPressed: linkUser,
                              icon: Icon(Icons.add_rounded, color: Colors.white),
                              label: Text('Link Elder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6F51FF),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ...linkedAccounts.map((account) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2B2B36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF6F51FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person_rounded, color: Color(0xFF6F51FF)),
                      ),
                      title: Text(account['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${account['email'] ?? ''}
Code: ${account['uniqueCode']}', style: TextStyle(color: Colors.grey.shade400, height: 1.4)),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: Icon(Icons.link_off_rounded, color: Colors.redAccent.withOpacity(0.8)),
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
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFF2B2B36),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 10))
                    ]
                  ),
                  child: Icon(Icons.settings_rounded, size: 64, color: Color(0xFF6F51FF)),
                ),
                SizedBox(height: 32),
                Text(
                  'Settings & Options',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 48),
                ElevatedButton.icon(
                  icon: Icon(Icons.logout_rounded, color: Colors.white),
                  label: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.9),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              children: [
                Text(
                  "© 2026 Aman Asish Gupta",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                SizedBox(height: 6),
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
