import 'package:fexus/screens/CareerDashboardPage.dart';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:fexus/widgets/custom_app_bar.dart';
import 'package:fexus/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fexus/models/user.dart';

class RecommendationsPage extends StatefulWidget {
  final AuthenticationService authService;

  const RecommendationsPage({super.key, required this.authService});

  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  String userStrengths = "";
  List<String> careerTitles = [];
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      isLoading = true;
    });

    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];

    const String url =
        'http://127.0.0.1:8000/api/assessment/get-career-recommendations/';
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
        final responseBody = json.decode(response.body);
        final recommendation = responseBody['recommendation'];

        // Split the recommendation into User Strengths and Recommended Careers sections
        final splitRecommendation = recommendation.split('##');
        userStrengths = splitRecommendation[1]
            .replaceAll('User Strengths', '')
            .replaceAll('- ', '')
            .replaceAll('**', '') // Remove ** from user strengths
            .trim();
        final recommendedCareers = splitRecommendation[2]
            .replaceAll('Recommended Careers', '')
            .replaceAll('\n', '')
            .trim();

        // Extract career titles
        careerTitles = _extractCareers(recommendedCareers);

        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to load recommendations'),
        ));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading recommendations: $e'),
      ));
    }
  }

  List<String> _extractCareers(String content) {
    final careerRegex = RegExp(r'\*\*(.*?)\*\*'); // Match text between **
    final matches = careerRegex.allMatches(content);

    return matches.map((match) {
      String? careerTitle = match.group(1);
      if (careerTitle != null && careerTitle.endsWith(':')) {
        careerTitle = careerTitle.substring(
            0, careerTitle.length - 1); // Remove trailing colon
      }
      return careerTitle ?? '';
    }).toList();
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving selected career: $e'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onCareerSelected(String career) {
    _saveSelectedCareer(career);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Career Recommendations',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              child: _buildScrollableCard(
                                title: 'User Strengths',
                                content: userStrengths,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Center(
                            child: SizedBox(
                              child: _buildScrollableCard(
                                title: 'Recommended Careers',
                                content: careerTitles.join('\n'),
                                onCareerTap: _onCareerSelected,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScrollableCard({
    required String title,
    required String content,
    void Function(String)? onCareerTap,
  }) {
    return Card(
      margin: const EdgeInsets.all(30.0),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 336,
        height: 254,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "../../assets/recommendations_card.png"), // Correct path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 30, bottom: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6060E7),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content.split('\n').map((line) {
                        return ListTile(
                          title: Text(
                            line,
                            style: const TextStyle(color: Color(0xFF6060E7)),
                          ),
                          onTap:
                              onCareerTap != null && careerTitles.contains(line)
                                  ? () => onCareerTap(line)
                                  : null,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
