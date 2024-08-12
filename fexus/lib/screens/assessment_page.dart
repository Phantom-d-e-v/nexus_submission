import 'package:fexus/models/user.dart';
import 'package:fexus/screens/RecommendationsPage.dart';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:fexus/widgets/custom_app_bar.dart';
import 'package:fexus/widgets/custom_drawer.dart';
import 'package:fexus/widgets/custom_submit_button.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class AssessmentPage extends StatefulWidget {
  final AuthenticationService authService;

  const AssessmentPage({super.key, required this.authService});

  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {};
  bool isSubmitting = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];
    const String url =
        'http://127.0.0.1:8000/api/assessment/get-assessment-questions/';

    try {
      final response = await widget.authService.makeAuthenticatedRequest(
        url: url,
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: '',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        setState(() {
          questions = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to load questions'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading questions: $e'),
      ));
    }
  }

  Future<void> _submitAnswers() async {
    setState(() {
      isSubmitting = true;
    });

    UserPreferences userPrefs = UserPreferences(interests: [], strengths: []);
    Map<String, dynamic> tokens = await userPrefs.loadTokens();
    String token = tokens['access'];

    List<Map<String, dynamic>> questionAnswers = [];
    for (int i = 0; i < questions.length; i++) {
      questionAnswers.add({
        'question': {
          'question_text': questions[i]['question_text'],
          'question_type': questions[i]['question_type'],
          'options': questions[i]['options'],
        },
        'answer': answers[i],
      });
    }

    const String url =
        'http://127.0.0.1:8000/api/assessment/submit-assessment/';
    final String body = json.encode({'answers': questionAnswers});
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

      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Answers submitted successfully'),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RecommendationsPage(authService: widget.authService)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to submit answers'),
        ));
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting answers: $e'),
      ));
    }
  }

  Widget _buildQuestion(BuildContext context) {
    var question = questions[currentQuestionIndex];

    return SizedBox(
      width: 370,
      height: 650,
      child: Stack(
        clipBehavior: Clip.none, // Allows overflow outside the Stack bounds
        children: [
          Positioned.fill(
            child: Image.asset(
              '../../assets/assessmentquestion.png', // Your image asset path
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              bottom: 30.0,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  vertical: 40.0, horizontal: 20.0), // Added horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionContent(question, currentQuestionIndex),
                  const SizedBox(height: 40), // Extra space for the arrows
                ],
              ),
            ),
          ),
          // Previous arrow button
          Positioned(
            left: -23.5, // Half of 47 (image width)
            top: (650 - 46) / 2, // Vertical center considering the image height
            child: GestureDetector(
              onTap: currentQuestionIndex > 0
                  ? () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    }
                  : null,
              child: Image.asset(
                '../../assets/prev_arrow.png', // Replace with your previous arrow image path
                width: 47,
                height: 46,
              ),
            ),
          ),
          // Next arrow button
          Positioned(
            right: -23.5, // Half of 47 (image width)
            top: (650 - 46) / 2, // Vertical center considering the image height
            child: GestureDetector(
              onTap: currentQuestionIndex < questions.length - 1
                  ? () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                  : null,
              child: Image.asset(
                '../../assets/next_arrow.png', // Replace with your next arrow image path
                width: 47,
                height: 46,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(question, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: Text(
              question['question_text'],
              textAlign: TextAlign.left,
              style: const TextStyle(color: Color(0xFF6060E7), fontSize: 18),
              softWrap: true, // Allows the text to wrap onto the next line
            ),
          ),
          const SizedBox(
              height: 20), // Adds space between the question and answer part
          if (question['question_type'] == 'multiple_choice') ...[
            ...List<Widget>.from(question['options'].map((option) {
              return Container(
                width: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9E0), // Background color for each option
                  borderRadius: BorderRadius.circular(25), // Rounded corners
                ),
                margin: const EdgeInsets.symmetric(
                    vertical: 4.0), // Optional: Add some margin for spacing
                child: RadioListTile(
                  title: Text(option,
                      style: const TextStyle(color: Colors.black, fontSize: 16)),
                  value: option,
                  groupValue: answers[index],
                  onChanged: (value) {
                    setState(() {
                      answers[index] = value;
                    });
                  },
                  activeColor: const Color(0xFF6060E7),
                  tileColor: Colors
                      .transparent, // Tile color is overridden by Container background
                  contentPadding:
                      const EdgeInsets.all(15.0), // Optional: Adjust padding
                ),
              );
            })),
          ] else if (question['question_type'] == 'short_answer') ...[
            SizedBox(
              width: 300,
              height: 200, // Set the height of the TextField
              child: TextField(
                onChanged: (value) {
                  answers[index] = value;
                },
                decoration: InputDecoration(
                  hintText: "Your answer",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  fillColor: const Color(0xFFD9D9E0), // Background color
                  filled: true, // Ensures the fill color is applied
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0), // Adjust padding as needed
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide.none, // No border line
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                maxLines: null, // Allows multiple lines
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Assessment',
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
        child: questions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  children: [
                    _buildQuestion(context),
                    const SizedBox(
                        height:
                            20), // Add spacing between the question and button
                    CustomSubmitButton(
                      onPressed: _submitAnswers,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
