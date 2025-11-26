import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marsa_app/utils/config.dart';

class ApartmentCard extends StatefulWidget {
  const ApartmentCard({super.key, required this.route});
final String route;

  @override
  State<ApartmentCard> createState() => _ApartmentCardState();
}

class _ApartmentCardState extends State<ApartmentCard> {
  //  for favarite button
  bool isFav = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // redirect to doctor details
        Navigator.of(context).pushNamed(widget.route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: const DecorationImage(
            image: AssetImage(
              'assets/apartmentsImages/1.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // تدرج خفيف أسفل الكارت
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // علامة "مميز"
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  gradient: Config.spacialGradientColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "مميز",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Favorite Button
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isFav = !isFav;
                    });
                  },
                  icon: FaIcon(
                    isFav ? Icons.favorite_outlined : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
            // زر الإضافة الدائري
            Positioned(
              bottom: -5, // لجعله يتدلى قليلاً أو محاذاة للحافة
              left: 0,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                 gradient: Config.gradientColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25), // يطابق حافة الكارت
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
