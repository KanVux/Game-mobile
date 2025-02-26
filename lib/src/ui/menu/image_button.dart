import 'package:flutter/material.dart';

class ImageButton extends StatefulWidget {
  final String imagePath;
  final String pressedImagePath;
  final String text;
  final VoidCallback onPressed;

  const ImageButton({
    required this.imagePath,
    required this.pressedImagePath,
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Stack(
        alignment: Alignment.center, // Ensures text stays in the middle
        children: [
          // Button Image
          Image.asset(
            _isPressed ? widget.pressedImagePath : widget.imagePath,
            width: 220, // Adjust width as needed
          ),

          // Button Text - Positioned slightly higher
          Positioned(
            top: 10, // Adjust this value to move text higher
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'MedievalSharp', // Use the downloaded font
                fontSize: 22, // Adjust size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black.withOpacity(0.7),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
