import 'dart:convert';
import 'dart:io';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:fexus/widgets/custom_app_bar.dart';
import 'package:fexus/widgets/custom_drawer.dart';
import 'package:fexus/models/user.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;
import 'package:html/parser.dart' show parse;

class CareerDashboardPage extends StatefulWidget {
  final AuthenticationService authService;

  const CareerDashboardPage({super.key, required this.authService});

  @override
  _CareerDashboardPageState createState() => _CareerDashboardPageState();
}

class _CareerDashboardPageState extends State<CareerDashboardPage> {
  String? careerName;
  String? description;
  List<String> skillsRequired = [];
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> courses = [];
  List<Map<String, String>> jobPortals = [];

  @override
  void initState() {
    super.initState();
    _fetchSelectedCareer();
  }

  Future<void> _fetchSelectedCareer() async {
    setState(() {
      isLoading = true;
    });

    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];

    const String url = 'http://127.0.0.1:8000/api/career/fetch-career/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: '',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        setState(() {
          final Map<String, dynamic> data =
              json.decode(response.body) as Map<String, dynamic>;

          careerName = data['career_name'] as String?;
          description = data['description'] as String?;

          skillsRequired =
              List<String>.from(data['skills_required'] as List<dynamic>);

          courses = List<Map<String, String>>.from(
            (data['courses'] as List<dynamic>).map((item) {
              final course = item as Map<String, dynamic>;
              return {
                'title': course['title'] as String? ?? '',
                'description': course['description'] as String? ?? '',
                'link': course['link'] as String? ?? ''
              };
            }),
          );

          jobPortals = List<Map<String, String>>.from(
            (data['job_portals'] as List<dynamic>).map((item) {
              final portal = item as Map<String, dynamic>;
              return {
                'title': portal['title'] as String? ?? '',
                'description': portal['description'] as String? ?? '',
                'link': portal['link'] as String? ?? ''
              };
            }),
          );

          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to load selected career'),
        ));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading selected career: $e'),
      ));
    }
  }

  Future<void> _fetchCourseRecommendations() async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];
    const String url =
        'http://127.0.0.1:8000/api/career/get-course-recommendations/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: '',
        method: 'POST',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showRecommendationsDialog(data, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to fetch course recommendations'),
        ));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching course recommendations: $e'),
      ));
    }
  }

  Future<void> _fetchJobPortalRecommendations() async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];
    const String url =
        'http://127.0.0.1:8000/api/career/get-job-portal-recommendations/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: '',
        method: 'POST',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showRecommendationsDialog(data, false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to fetch job portal recommendations'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching job portal recommendations: $e'),
      ));
    }
  }

  Future<void> _showRecommendationsDialog(
      String recommendations, bool isCourse) async {
    String processedText =
        recommendations.replaceAll(RegExp(r'[{}"##\*\*]'), '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4F587D), // Setting the background color
          titleTextStyle:
              const TextStyle(color: Colors.white), // Ensuring title text is white
          contentTextStyle:
              const TextStyle(color: Colors.white), // Ensuring content text is white
          title:
              Text(isCourse ? 'Recommended Course' : 'Recommended Job Portal'),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(16), // Adding padding inside the content
            child: Text(processedText),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                disabledForegroundColor:
                    Colors.grey.withOpacity(0.38), // Unfocused button color
              ),
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCourse(Map<String, String> course) async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];
    const String url = 'http://127.0.0.1:8000/api/career/add-course/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'career_name': careerName,
      'course': course,
    });

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: body,
        method: 'POST',
      );

      if (response.statusCode == 200) {
        _fetchSelectedCareer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add course'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding course: $e'),
      ));
    }
  }

  Future<void> _addJobPortal(Map<String, String> jobPortal) async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];
    const String url = 'http://127.0.0.1:8000/api/career/add-job-portal/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'career_name': careerName,
      'job_portal': jobPortal,
    });

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: body,
        method: 'POST',
      );

      if (response.statusCode == 200) {
        _fetchSelectedCareer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add job portal'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding job portal: $e'),
      ));
    }
  }

  Future<void> _showAddItemDialog(bool isCourse) async {
    String? name;
    String? description;
    String? link;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCourse ? 'Add New Course' : 'Add New Job Portal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
                onChanged: (value) {
                  description = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Link'),
                onChanged: (value) {
                  link = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (name != null &&
                    name!.isNotEmpty &&
                    link != null &&
                    link!.isNotEmpty) {
                  if (isCourse) {
                    _addCourse({
                      'title': name!,
                      'description': description ?? '',
                      'link': link!
                    });
                  } else {
                    _addJobPortal({
                      'title': name!,
                      'description': description ?? '',
                      'link': link!
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Name and Link are required'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Dashboard',
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F587D),
              Color(0xFF232A47),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCareerCard(),
                        _buildSkillsRequiredCard(),
                        _buildCoursesSectionCard(),
                        _buildCVCheckerSectionCard(),
                        _buildJobPortalsSectionCard(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareerCard() {
    return Card(
      margin: const EdgeInsets.all(30.0),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        height: 285,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../../assets/dashboard_card.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career: $careerName',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Description: $description',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsRequiredCard() {
    List<String> processedSkills = skillsRequired
        .map((skill) => skill.replaceAll(RegExp(r'[{}"##\*\*]'), ''))
        .toList();

    return Card(
      margin: const EdgeInsets.all(30.0),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        height: 285,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../../assets/dashboard_card.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skills Required:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...processedSkills
                    .map((skill) => Text(skill))
                    , // Display processed skills
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSectionCard() {
    return Card(
      margin: const EdgeInsets.all(30.0),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        height: 285,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../../assets/dashboard_card.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Courses:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddItemDialog(true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          onPressed: _fetchCourseRecommendations,
                        ),
                      ],
                    ),
                  ],
                ),
                courses.isEmpty
                    ? const Text('No courses added.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final title = course['title'] ?? 'Unnamed Course';
                          final description = course['description'] ?? '';
                          final link = course['link'] ?? '';

                          return ListTile(
                            title: Text(title),
                            subtitle: Text(description),
                            onTap:
                                link.isNotEmpty ? () => _launchURL(link) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeCourse(index),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCVCheckerSectionCard() {
    return Card(
      margin: const EdgeInsets.all(30.0),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        height: 285,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../../assets/dashboard_card.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('CV Checker and Enhancer'),
              ElevatedButton(
                onPressed: () async {
                  final cvText = await _pickAndUploadCV();
                  if (cvText != null) {
                    final suggestions =
                        await _getCVEnhancementSuggestions(cvText);
                  }
                },
                child: const Text('Upload CV'),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'CV suggestions will appear here...',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickAndUploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String cvText;

      if (path.extension(file.path).toLowerCase() == '.pdf') {
        cvText = await _convertPdfToText(file);
      } else {
        throw Exception('Unsupported file type');
      }

      await _getCVEnhancementSuggestions(cvText);
    } else {
      return null;
    }
    return null;
  }

  Future<void> _getCVEnhancementSuggestions(String cvText) async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];

    const String url = 'http://127.0.0.1:8000/api/career/enhance-cv/';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'cv_text': cvText,
    };

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: headers,
        body: json.encode(body),
        method: 'POST',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String suggestions = data['suggestions'];

        _showSuggestions(suggestions);
      } else {
        throw Exception('Failed to get suggestions');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching CV enhancement suggestions: $e'),
      ));
    }
  }

  Future<String> _convertPdfToText(File file) async {
    final document = html.DocumentFragment.html(
        '<embed src="${file.path}" type="application/pdf" />');

    final parsedDocument = parse(document.innerHtml);

    final text = parsedDocument.body!.text;

    return text;
  }

  void _showSuggestions(String suggestions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4F587D), // Setting the background color
          titleTextStyle:
              const TextStyle(color: Colors.white), // Ensuring title text is white
          contentTextStyle:
              const TextStyle(color: Colors.white), // Ensuring content text is white
          title: const Text('CV Enhancement Suggestions'),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(16), // Adding padding inside the content
            child: Text(suggestions),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                disabledForegroundColor:
                    Colors.grey.withOpacity(0.38), // Unfocused button color
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobPortalsSectionCard() {
    return Card(
      margin: const EdgeInsets.all(30.0),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 360,
        height: 285,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../../assets/dashboard_card.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Job Portals and Links:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddItemDialog(false),
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          onPressed: _fetchJobPortalRecommendations,
                        ),
                      ],
                    ),
                  ],
                ),
                jobPortals.isEmpty
                    ? const Text('No job portals added.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: jobPortals.length,
                        itemBuilder: (context, index) {
                          final portal = jobPortals[index];
                          final title = portal['title'] ?? 'Unnamed Portal';
                          final description = portal['description'] ?? '';
                          final link = portal['link'] ?? '';

                          return ListTile(
                            title: Text(title),
                            subtitle: Text(description),
                            onTap:
                                link.isNotEmpty ? () => _launchURL(link) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeJobPortal(index),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void _removeCourse(int index) {
    setState(() {
      courses.removeAt(index);
    });
  }

  void _removeJobPortal(int index) {
    setState(() {
      jobPortals.removeAt(index);
    });
  }
}
