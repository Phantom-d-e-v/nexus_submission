import 'package:fexus/models/user.dart';
import 'package:fexus/screens/CareerDashboardPage.dart';
import 'package:fexus/screens/SelectCareer/components/career_list.dart';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:fexus/widgets/custom_app_bar.dart';
import 'package:fexus/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';

class SelectCareerPage extends StatefulWidget {
  final AuthenticationService authService;

  const SelectCareerPage({super.key, required this.authService});

  @override
  _SelectCareerPageState createState() => _SelectCareerPageState();
}

class _SelectCareerPageState extends State<SelectCareerPage> {
  final TextEditingController _careerController = TextEditingController();
  Career? _selectedCareer;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _careerController.dispose();
    super.dispose();
  }

  void _onCareerSelected(Career selectedCareer) {
    setState(() {
      _selectedCareer = selectedCareer;
    });
  }

  void _showAddCareerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController careerNameController = TextEditingController();

        return AlertDialog(
          title: const Text('Add a New Career'),
          content: Column(
            children: [
              TextField(
                controller: careerNameController,
                decoration: const InputDecoration(hintText: 'Career Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (careerNameController.text.isNotEmpty) {
                  _saveSelectedCareer(careerNameController.text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSelectedCareer(String careerName) async {
    setState(() {
      isLoading = true;
    });

    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];

    const String url = 'http://127.0.0.1:8000/api/career/select-career/';
    final String body = json.encode({
      'career_name': careerName,
    });
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: body,
        method: 'POST',
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CareerDashboardPage(
                    authService: widget.authService,
                  )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save selected career'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving selected career: $e'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToCareerDashboard() {
    if (_selectedCareer != null) {
      _saveSelectedCareer(_selectedCareer!.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a career')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Select Career',
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const CustomDrawer(),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9FF),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF6060E7),
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: TypeAheadField<Career>(
                  builder: (BuildContext context,
                      TextEditingController controller, FocusNode focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        labelText: 'Search for a career',
                        border: InputBorder.none,
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) {
                    return allCareers
                        .where((career) => career.name
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, Career career) {
                    return ListTile(
                      title: Text(career.name),
                    );
                  },
                  onSelected: (Career selectedCareer) {
                    _careerController.text = selectedCareer.name;
                    _onCareerSelected(selectedCareer);
                  },
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF796AFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: _showAddCareerDialog,
                child: const Text(
                  'Add a New Career',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF796AFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: _navigateToCareerDashboard,
                child: const Text(
                  'Go to Career Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
