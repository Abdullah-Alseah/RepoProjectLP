import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marsa_app/utils/config.dart';

class ApartmentCardWidget extends StatefulWidget {
  const ApartmentCardWidget({super.key});

  @override
  State<ApartmentCardWidget> createState() => _ApartmentCardWidgetState();
}

class _ApartmentCardWidgetState extends State<ApartmentCardWidget> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    // يجب استخدام Directionality لتطبيق اتجاه RTL
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Container(
          width: double.infinity, // عرض تقريبي للبطاقة

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. قسم الصورة والتراكبات (Stack)
              _buildImageAndOverlays(),

              // 2. قسم التفاصيل الرئيسية والسعر
              _buildDetailsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. بناء قسم الصورة والأزرار العائمة ---
  Widget _buildImageAndOverlays() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          // الصورة نفسها (يجب أن يكون المسار معرفاً في pubspec.yaml)
          // تم استخدام Container بدلاً من Image.asset لتجنب الحاجة لملف asset حقيقي في هذا المثال
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            // child:
            // لو كان لديك الصورة الحقيقية استخدم:
            child: Image.asset(
              'assets/apartmentsImages/1.jpg',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover
            ),
          ),

          // زر المفضلة (Heart Icon) - يمين أعلى
          Positioned(
            top: 15,
            left: 15,
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


          // شارة "مميز" - يسار أعلى
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                gradient: Config.spacialGradientColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'مميز',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. بناء قسم التفاصيل الرئيسية والسعر ---
  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const Text(
            'شقة فاخرة في وسط المدينة',
            style: TextStyle(
              fontSize: 22,
              fontFamily: "Tajawal",
              fontWeight: FontWeight.w900,
              color: Config.primaryColor,
            ),
          ),
          const SizedBox(height: 5),

          // الموقع
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
              const SizedBox(width: 5),
              Text(
                'الرياض، حي العليا',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Tajawal",
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // الخصائص (غرف النوم والحمامات والمساحة)
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 15),

          _buildSpecificationsRow(),
          const SizedBox(height: 20),

          // السعر وزر الإجراء
          _buildPriceAndActionButton(),
        ],
      ),
    );
  }

  // --- صف مواصفات العقار (غرف، حمام، مساحة) ---
  Widget _buildSpecificationsRow() {
    // دالة مساعدة لتصميم كل خاصية
    Widget specItem(IconData icon, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Config.primaryColor, size: 20),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Config.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10,)
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        specItem(Icons.king_bed_outlined, '3'),
        specItem(Icons.bathtub_outlined, '2'),
        specItem(Icons.square_outlined, '180 م²'),
        // إضافة مساحة فارغة لتوزيع العناصر
        const Spacer(),
      ],
    );
  }

  // --- صف السعر وزر الإجراء ---
  Widget _buildPriceAndActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // السعر
        const Text(
          '1,250,000 ريال',
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Tajawal",
            fontWeight: FontWeight.w900,
            color: Config.primaryColor,
          ),
        ),

        // زر الإجراء (السهم الأخضر)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Config.primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                //    Press To Change
              });
            },
            icon: FaIcon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// مثال الاستخدام في تطبيقك
/*
void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: ApartmentCardWidget(),
    ),
  ));
}
*/