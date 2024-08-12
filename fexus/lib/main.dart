import 'dart:convert';
import 'package:fexus/models/user.dart';
import 'package:fexus/screens/CareerDashboardPage.dart';
import 'package:fexus/screens/MenuPage.dart';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  late AuthenticationService _authService; // Add AuthService instance

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkStaySignedIn();
  }

  Future<void> _checkStaySignedIn() async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    bool staySignedIn = await userPrefs.loadStaySignedIn();
    if (staySignedIn) {
      Map<String, dynamic> tokens = await userPrefs.loadTokens();
      if (tokens.isNotEmpty) {
        _authService = AuthenticationService(
          accessToken: tokens['access'],
          refreshToken: tokens['refresh'],
        );
        await _fetchSelectedCareer();
      }
    }
  }

  Future<void> _fetchSelectedCareer() async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];

    const String url = 'http://127.0.0.1:8000/api/career/fetch-career/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: '', // No body for GET requests
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Store the fetched career information
        await userPrefs.saveSelectedCareer(data['career_name']);
        // Navigate to the dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CareerDashboardPage(authService: _authService)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainMenuPage(authService: _authService)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading selected career: $e'),
      ));
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _newUsernameController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/api/users/login/');
      var response = await http.post(url, body: {
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      if (response.statusCode == 200) {
        String responseBody = response.body;
        Map<String, dynamic> tokens = jsonDecode(responseBody);

        UserPreferences userPrefs =
            UserPreferences(interests: [], strengths: []);
        await userPrefs.saveTokens(tokens['refresh'], tokens['access']);
        await userPrefs.saveStaySignedIn(_staySignedIn);

        _authService = AuthenticationService(
          accessToken: tokens['access'],
          refreshToken: tokens['refresh'],
        );
        await _fetchSelectedCareer();
      } else {
        throw Exception('Failed to log in');
      }
    } catch (error) {
      print("Login Error: $error");
    }
  }

  Future<void> _register() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/api/users/register/');
      var response = await http.post(url, body: {
        'username': _newUsernameController.text,
        'password': _newPasswordController.text,
        'email': _emailController.text,
      });

      if (response.statusCode == 201) {
        print(response.body); // Log the response for now
        // In a real app, you'd handle successful registration (e.g., show a success message)
      } else {
        throw Exception('Registration failed');
      }
    } catch (error) {
      print(error);
    }
  }

  bool _staySignedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFCD558A), // Start color
                Color(0xFF4B5479), // End color
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Transparent background
            elevation: 0, // No shadow
            leading: Padding(
              padding: const EdgeInsets.all(8.0), // Padding around the logo
              child: Image.asset(
                '../assets/appbar_logo.png', // Logo path
                height: 40, // Logo height
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Login'),
                Tab(text: 'Register'),
              ],
              labelColor: Colors.white, // Label color
              unselectedLabelColor: Colors.grey, // Unselected label color
              isScrollable: true, // Keep scrollable
              tabAlignment: TabAlignment.center,
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F587D), // Start color
              Color(0xFF232A47), // End color
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF796AFC)),
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF979AED),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF796AFC)),
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF979AED),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  Row(
                    children: [
                      SizedBox(
                        width: 24, // Fixed width for checkbox
                        height: 24, // Fixed height for checkbox

                        child: Checkbox(
                          value: _staySignedIn,
                          onChanged: (bool? value) {
                            setState(() {
                              _staySignedIn = value ?? false;
                            });
                          },
                          activeColor: Colors.white, // Checkbox tick mark color
                        ),
                      ),
                      const SizedBox(width: 8), // Space between checkbox and text
                      const Expanded(
                        child: Text('Stay signed in',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  SizedBox(
                      width: double.infinity, // Full width
                      height: 56, // Fixed height

                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(
                              0xFF796AFC), // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(100), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24), // Adjust the padding as needed
                        ),
                        child: const Text(
                          'Login', // or 'Register' for the other button
                          style: TextStyle(
                            fontSize: 18, // Font size
                          ),
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _newUsernameController,
                    decoration: InputDecoration(
                      labelText: 'New Username',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF796AFC)),
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF979AED),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF796AFC)),
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF979AED),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF796AFC)),
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF979AED),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  SizedBox(
                      width: double.infinity, // Full width
                      height: 56, // Fixed height

                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(
                              0xFF796AFC), // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(100), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24), // Adjust the padding as needed
                        ),
                        child: const Text(
                          'Login', // or 'Register' for the other button
                          style: TextStyle(
                            fontSize: 18, // Font size
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
