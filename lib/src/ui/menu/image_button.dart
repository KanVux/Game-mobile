import 'package:flutter/material.dart';

class ImageButton extends StatefulWidget {
  final String imagePath;
  final String pressedImagePath;
  final String? text;
  final VoidCallback onPressed;
  final double width; // 🔥 Make width configurable

  const ImageButton({
    required this.imagePath,
    required this.pressedImagePath,
    this.text,
    required this.onPressed,
    this.width = 200, // Default width if not provided
    super.key,
  });

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
            width: widget.width, // 🔥 Use configurable width
          ),

          // Button Text - Positioned slightly higher
          // Positioned(
          //   top: widget.width * 0.06, // 🔥 Adjust text position dynamically
          //   child: Text(
          //     widget.text,
          //     style: TextStyle(
          //       fontFamily: 'MedievalSharp',
          //       fontSize: widget.width * 0.1, // 🔥 Scale font based on width
          //       fontWeight: FontWeight.bold,
          //       color: Colors.white,
          //       shadows: [
          //         Shadow(
          //           blurRadius: 5,
          //           color: Colors.black.withOpacity(0.7),
          //           offset: Offset(2, 2),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          if (widget.text != null)
            Positioned(
              top: widget.width * 0.06,
              child: Text(
                widget.text!,
                style: TextStyle(
                  fontFamily: 'MedievalSharp',
                  fontSize: widget.width * 0.1,
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
