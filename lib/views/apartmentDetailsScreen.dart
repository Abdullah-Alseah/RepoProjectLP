import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/config.dart';

class Apartmentdetailsscreen extends StatefulWidget {
  Apartmentdetailsscreen({super.key});

  @override
  State<Apartmentdetailsscreen> createState() => _ApartmentdetailsscreenState();
}

class _ApartmentdetailsscreenState extends State<Apartmentdetailsscreen> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(context),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. العنوان والموقع
                    _buildTitleSection(),
                    const SizedBox(height: 12),

                    // 3. المواصفات السريعة (غرف، حمام، مساحة)
                    _buildQuickSpecs(),
                    const SizedBox(height: 20),

                    // 4. بطاقة السعر (الإيجار والسعر الإجمالي)
                    _buildPriceCard(),
                    const SizedBox(height: 25),

                    // 5. الوصف
                    _buildSectionTitle("الوصف"),
                    const SizedBox(height: 10),
                    _buildDescription(),
                    const SizedBox(height: 25),

                    // 6. المميزات (Grid)
                    _buildSectionTitle("المميزات"),
                    const SizedBox(height: 15),
                    _buildFeaturesGrid(),
                    const SizedBox(height: 25),
                    // 8. الوكيل العقاري
                    _buildSectionTitle("الوكيل العقاري"),
                    const SizedBox(height: 15),
                    _buildAgentCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070',
              ), // صورة افتراضية مشابهة
              fit: BoxFit.cover,
            ),
          ),
        ),
        // أزرار التحكم العلوية
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                _buildCircleButton(Icons.arrow_forward, () => Get.back()),
              ],
            ),
          ),
        ),
        // مؤشر الصفحات (1/4)
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "1 / 4",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "شقة فاخرة في وسط المدينة",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: Config.mainFont,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              "الرياض، حي العليا، شارع التحلية",
              style: TextStyle(
                fontFamily: Config.mainFont,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSpecs() {
    return Row(
      children: [
        _buildSpecBadge(Icons.square_foot, "180 م²"),
        const SizedBox(width: 10),
        _buildSpecBadge(Icons.bathtub_outlined, "2 حمام"),
        const SizedBox(width: 10),
        _buildSpecBadge(Icons.bed_outlined, "3 غرف"),
      ],
    );
  }

  Widget _buildSpecBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Config.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Config.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: Config.mainFont,
              color: Config.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Config.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Config.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "الإيجار الشهري",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                "5,500 ل.س",
                style: TextStyle(
                  fontFamily: Config.mainFont,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 2),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Config.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Config.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "الإيجار الشهري",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                "5,500 ريال",
                style: TextStyle(
                  fontFamily: Config.mainFont,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 2),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Config.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Config.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "الإيجار الشهري",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                "5,500 ريال",
                style: TextStyle(
                  fontFamily: Config.mainFont,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      "شقة فاخرة تقع في قلب حي العليا الراقي بالرياض، تتميز بتصميم عصري وإطلالة رائعة على المدينة. الشقة مجهزة بالكامل بأحدث التقنيات والتشطيبات الفاخرة. تحتوي على 3 غرف نوم واسعة، صالة كبيرة، مطبخ مجهز بالكامل، وشرفتين. الموقع مثالي بالقرب من جميع الخدمات والمرافق الحيوية.",
      style: TextStyle(
        fontFamily: Config.mainFont,
        color: Colors.black54,
        height: 1.6,
        fontSize: 14,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {"icon": Icons.fitness_center, "label": "صالة رياضية"},
      {"icon": Icons.pool, "label": "مسبح"},
      {"icon": Icons.security, "label": "أمن وحراسة"},
      {"icon": Icons.local_parking, "label": "موقف سيارة"},
      {"icon": Icons.kitchen, "label": "مطبخ مجهز"},
      {"icon": Icons.ac_unit, "label": "تكييف مركزي"},
      {"icon": Icons.wifi, "label": "إنترنت"},
      {"icon": Icons.grass, "label": "حديقة"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                features[index]['icon'] as IconData,
                color: Config.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              features[index]['label'] as String,
              style: TextStyle(
                fontFamily: Config.mainFont,
                fontSize: 10,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgentCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Config.primaryColor,
                child: Text("أح", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "أحمد العتيبي",
                      style: TextStyle(
                        fontFamily: Config.mainFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "وكيل عقاري معتمد",
                      style: TextStyle(
                        fontFamily: Config.mainFont,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "4.8",
                    style: TextStyle(
                      fontFamily: Config.mainFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    " (127 تقييم)",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(
                    "محادثة",
                    style: TextStyle(
                      fontFamily: Config.mainFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Config.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(
                    "اتصال",
                    style: TextStyle(
                      fontFamily: Config.mainFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- أدوات مساعدة ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: Config.mainFont,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black45, size: 20),
      ),
    );
  }
}
