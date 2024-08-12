import 'package:fexus/screens/SelectCareer/SelectCareerPage.dart';
import 'package:fexus/screens/shared/AuthService.dart';
import 'package:fexus/widgets/custom_app_bar.dart';
import 'package:fexus/widgets/custom_button.dart';
import 'package:fexus/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'UserPrefrencesPage/UserPrefrencesPage.dart';

class MainMenuPage extends StatelessWidget {
  final AuthenticationService authService;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MainMenuPage(
      {super.key, required this.authService}); // Pass authService to the constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: '',
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
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomButton(
                      text: 'Find Your Career',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserPreferencesPage(authService: authService),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Know Your Career',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectCareerPage(authService: authService),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    '../../assets/menupage.png', // Replace with your image asset path
                    fit: BoxFit
                        .contain, // Ensure the image covers the entire area
                    // Make the image full width
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
