import 'package:fexus/models/user.dart';
import 'package:fexus/screens/assessment_page.dart';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:fexus/widgets/custom_app_bar.dart';
import 'package:fexus/widgets/custom_drawer.dart';
import 'package:fexus/widgets/custom_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// Add this import
import 'dart:convert'; // Add this import for JSON encoding
import 'components/lists.dart';

class UserPreferencesPage extends StatefulWidget {
  final AuthenticationService authService;

  const UserPreferencesPage({super.key, required this.authService});

  @override
  _UserPreferencesPageState createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  final List<Skill> _selectedSkills = [];
  final List<Interest> _selectedInterests = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _skillController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _addSkill(String skillName) {
    setState(() {
      Skill newSkill = Skill(name: skillName);
      if (!_selectedSkills.contains(newSkill)) {
        _selectedSkills.add(newSkill);
        allSkills.add(newSkill);
      }
    });
  }

  void _addInterest(String interestName) {
    setState(() {
      Interest newInterest = Interest(name: interestName);
      if (!_selectedInterests.contains(newInterest)) {
        _selectedInterests.add(newInterest);
        allInterests.add(newInterest);
      }
    });
  }

  void _showAddDialog(bool isSkill) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text(isSkill ? 'Add Skill' : 'Add Interest'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: isSkill ? 'Enter a skill' : 'Enter an interest',
            ),
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
                if (controller.text.isNotEmpty) {
                  if (isSkill) {
                    _addSkill(controller.text);
                  } else {
                    _addInterest(controller.text);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _serializePreferences() {
    var prefs = <String, dynamic>{
      'skills': _selectedSkills.map((skill) => skill.name).toList(),
      'interests': _selectedInterests.map((interest) => interest.name).toList(),
    };
    return jsonEncode(prefs);
  }

  Future<void> _submitPreferences() async {
    const String url =
        'http://127.0.0.1:8000/api/assessment/submit-preferences/';
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String idToken = tokens['access'];

    // Prepare the headers and body for the request
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
    String body =
        _serializePreferences(); // Assuming this method returns a JSON string

    try {
      // Use the makeAuthenticatedRequest method to send the request
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
              builder: (context) =>
                  AssessmentPage(authService: widget.authService)),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Preferences submitted successfully')));
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit preferences')));
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting preferences: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'User Prefrences',
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
        child: Center(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    '../../../assets/userprefrences.png'), // Add your image asset path
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  Container(
                    width: 310,
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
                    child: TypeAheadField<Skill>(
                      builder: (BuildContext context,
                          TextEditingController controller,
                          FocusNode focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            labelText: 'Search for a skill',
                            border: InputBorder.none,
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        return allSkills
                            .where((skill) => skill.name
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, Skill skill) {
                        return ListTile(
                          title: Text(skill.name),
                        );
                      },
                      onSelected: (Skill selectedSkill) {
                        setState(() {
                          if (!_selectedSkills.contains(selectedSkill)) {
                            _selectedSkills.add(selectedSkill);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selected Skills:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddDialog(true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedSkills.map((skill) {
                      return Chip(
                        label: Text(skill.name),
                        backgroundColor:
                            const Color(0xFFF1EEEE), // Set the background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Make the corners rounded
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 310,
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
                    child: TypeAheadField<Interest>(
                      builder: (BuildContext context,
                          TextEditingController controller,
                          FocusNode focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            labelText: 'Search for an interest',
                            border: InputBorder.none,
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        return allInterests
                            .where((interest) => interest.name
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, Interest interest) {
                        return ListTile(
                          title: Text(interest.name),
                        );
                      },
                      onSelected: (Interest selectedInterest) {
                        setState(() {
                          if (!_selectedInterests.contains(selectedInterest)) {
                            _selectedInterests.add(selectedInterest);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selected Interests:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddDialog(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedInterests.map((interest) {
                      return Chip(
                        label: Text(interest.name),
                        backgroundColor:
                            const Color(0xFFF1EEEE), // Set the background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Make the corners rounded
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 50),
                  CustomSubmitButton(
                    onPressed: _submitPreferences,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
