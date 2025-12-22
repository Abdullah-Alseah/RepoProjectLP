import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/config.dart';

class ApartmentCardWidget extends StatefulWidget {
  const ApartmentCardWidget({super.key});

  @override
  State<ApartmentCardWidget> createState() => _ApartmentCardWidgetState();
}

class _ApartmentCardWidgetState extends State<ApartmentCardWidget> {
  bool isFav = false;
  final String _price = "1,250,000 ريال";

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: InkWell(
            onTap: () {
              Get.toNamed('/apartmentDetails');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [_buildImageAndOverlays(), _buildDetailsSection()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAndOverlays() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Image.asset(
              'assets/apartmentsImages/1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),

          Positioned(
            top: 15,
            left: 15,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFav = !isFav;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: Config.spacialGradientColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'مميز',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'شقة فاخرة في وسط المدينة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'الرياض، حي العليا',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _specItem(Icons.king_bed_outlined, '3'),
              const SizedBox(width: 15),
              _specItem(Icons.bathtub_outlined, '2'),
              const SizedBox(width: 15),
              _specItem(Icons.square_foot, '180 م²'),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Config.primaryColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              Container(
                // padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Config.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    Get.toNamed('/bookingApartment');
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Config.primaryColor, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
