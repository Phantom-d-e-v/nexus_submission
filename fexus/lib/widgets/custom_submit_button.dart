import 'package:flutter/material.dart';

class CustomSubmitButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const CustomSubmitButton({
    super.key,
    required this.onPressed,
    this.buttonText = 'Submit',
  });

  @override
  _CustomSubmitButtonState createState() => _CustomSubmitButtonState();
}

class _CustomSubmitButtonState extends State<CustomSubmitButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF796AFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      child: Text(
        widget.buttonText,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}
