import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value; // Giá trị từ 0 đến 100
  final double width;
  final double height;
  final int segments;

  const ProgressBar({
    Key? key,
    required this.value,
    this.width = 300.0,
    this.height = 30.0,
    this.segments = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính toán số segment cần được lấp đầy dựa trên giá trị
    final filledSegments = (value / 100 * segments).floor();
    final segmentWidth =
        (width / segments) - 2; // Tính toán chiều rộng mỗi đoạn (trừ đi margin)

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Thêm đường viền đỏ như trong hình ảnh (tùy chọn)
        border: Border.all(color: Colors.red.withOpacity(0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(segments, (index) {
          // Tính toán phần trăm điền đầy cho segment này
          double fillPercentage = 100;

          if (index == filledSegments) {
            // Với segment trong trạng thái chuyển tiếp, tính toán phần điền đầy một phần
            fillPercentage = ((value / 100) * segments - filledSegments) * 100;
          } else if (index > filledSegments) {
            fillPercentage = 0;
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: segmentWidth,
            height: height,
            child: Transform(
              transform: Matrix4.skewX(
                  -0.2), // Hiệu ứng nghiêng (tương đương với skewX trong CSS)
              child: CustomPaint(
                painter: ProgressSegmentPainter(
                  fillPercentage: fillPercentage,
                ),
                size: Size(segmentWidth, height),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ProgressSegmentPainter extends CustomPainter {
  final double fillPercentage;

  ProgressSegmentPainter({
    required this.fillPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Vẽ phần nền (màu đen)
    final blackPaint = Paint()
      ..color = const Color.fromARGB(31, 209, 209, 209)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, blackPaint);

    // Vẽ phần điền đầy (màu xanh lá)
    if (fillPercentage > 0) {
      final greenPaint = Paint()
        ..color = Colors.green.shade500
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * fillPercentage / 100, size.height),
        greenPaint,
      );

      // Vẽ đường ngăn cách nếu segment được điền đầy một phần
      if (fillPercentage > 0 && fillPercentage < 100) {
        final dividePaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(size.width * fillPercentage / 100, 0),
          Offset(size.width * fillPercentage / 100, size.height),
          dividePaint,
        );
      }
    }

    // Vẽ viền đen
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, borderPaint);

    // Vẽ hiệu ứng bóng đổ ở dưới
    final shadowPaint = Paint()
      ..color = Colors.black12.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 2, size.width, 2),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressSegmentPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage;
  }
}
