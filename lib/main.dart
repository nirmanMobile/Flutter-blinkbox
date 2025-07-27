import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(BoxGameApp());

class BoxGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class BoxData {
  Color color;
  int value;
  bool selected;

  BoxData({required this.color, required this.value, this.selected = false});
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<BoxData> boxes = [];
  List<Widget> launchedBoxes = [];
  int score = 0;
  double bonus = 0;

  @override
  void initState() {
    super.initState();
    generateBoxes();
  }

  void generateBoxes() {
    final rand = Random();
    boxes = List.generate(36, (index) {
      int val = rand.nextInt(4) + 1;
      return BoxData(
        color: Colors.greenAccent.withOpacity(0.8),
        value: val,
      );
    });
  }

  void handleTap(int index) {
    BoxData tappedBox = boxes[index];
    animateLaunch(tappedBox);
    setState(() {
      score += tappedBox.value;
      bonus = min(100, bonus + tappedBox.value * 1.0);
    });
  }

  void animateLaunch(BoxData box) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    final animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, -0.6),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    final launchedBox = AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FractionalTranslation(
          translation: animation.value,
          child: child,
        );
      },
      child: BoxWidget(box: box),
    );

    setState(() {
      launchedBoxes.add(launchedBox);
    });

    controller.forward().then((_) {
      setState(() {
        launchedBoxes.remove(launchedBox);
      });
    });
  }

  Widget buildBox(BoxData data, int index) {
    return GestureDetector(
      onTap: () => handleTap(index),
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${data.value}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildPricePath() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PricePathPainter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101B2D),
      body: SafeArea(
        child: Stack(
          children: [
            buildPricePath(),
            ...launchedBoxes,
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Score: $score', style: TextStyle(color: Colors.greenAccent, fontSize: 18)),
                      Text('Balance: \$9496', style: TextStyle(color: Colors.white70, fontSize: 18)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: LinearProgressIndicator(
                    value: bonus / 100,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white10,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1,
                    ),
                    itemCount: boxes.length,
                    itemBuilder: (context, index) {
                      return buildBox(boxes[index], index);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BoxWidget extends StatelessWidget {
  final BoxData box;
  const BoxWidget({required this.box});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: box.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${box.value}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class PricePathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    for (int i = 1; i < 10; i++) {
      double x = size.width * i / 10;
      double y = size.height * (0.5 + 0.1 * sin(i.toDouble()));
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
