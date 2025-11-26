import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:marsa_app/components/card.dart';
import 'package:marsa_app/utils/config.dart';
import 'package:marsa_app/components/apartment_card.dart';

class HomeSecreen extends StatefulWidget {
  const HomeSecreen({super.key});

  @override
  State<HomeSecreen> createState() => _HomeSecreenState();
}

class _HomeSecreenState extends State<HomeSecreen> {
  bool _isBuySelected = true; // للتبديل بين شراء وإيجار
  @override
  Widget build(BuildContext context) {
    Config.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            leading: Image.asset('assets/marsa/Logo.png'),
            expandedHeight: 200,
            floating: false,
            // للتثبيت الاب بار عند السحب
            // pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background:
              // Image.asset(
              //   'assets/background/1.jpg',
              //   fit: BoxFit.cover,
              // ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/background/1.jpg',
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
                  height: 90,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withAlpha(0)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      boxShadow: [
                    BoxShadow(
                    color: Colors.white,
                    blurRadius: 30,
                    offset: const Offset(0, 25),
                  ),
                    ],

                    ),
                  ),
                ),
                  ],
                ),
              ),
              title: Text(
                'مَرسَى',
                style: TextStyle(
                  color: Config.secandryColor,
                  fontFamily: "tajawal",
                  // color: Colors.white,
                  fontWeight: FontWeight.bold,

                ),
              ),
            ),
          ),

          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 110,
            toolbarHeight: 110,
            // للتثبيت الاب بار عند السحب
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // أزرار التبديل (شراء / إيجار)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isBuySelected = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: _isBuySelected
                                        ? Config.gradientColor
                                        : Config.noGradientColor,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isBuySelected
                                            ? Config.primaryColor.withOpacity(0.5)
                                            : Colors.transparent,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "شراء",
                                    style: TextStyle(
                                      color: _isBuySelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: "Tajawal",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isBuySelected = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: !_isBuySelected
                                        ? Config.gradientColor
                                        : Config.noGradientColor,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: !_isBuySelected
                                            ? Config.primaryColor.withOpacity(0.5)
                                            : Colors.transparent,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "إيجار",
                                    style: TextStyle(
                                      color: !_isBuySelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: "Tajawal"
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 110,
            toolbarHeight: 110,
            // للتثبيت الاب بار عند السحب
            // pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          // قمنا بإزالة const من هنا
                          // 1. محاذاة النص لليمين
                          textAlign: TextAlign.right,
                          // 2. اتجاه النص من اليمين لليسار
                          textDirection: TextDirection.rtl,

                          decoration: InputDecoration(
                            hintText: "...ابحث عن موقع، مدينة",
                            // لضمان أن الـ hint يظهر في اليمين أيضاً
                            hintTextDirection: TextDirection.rtl,
                            border: InputBorder.none,

                            // ملاحظة: إذا أردت الأيقونة في الجهة اليسرى (نهاية النص العربي)
                            // استخدم suffixIcon بدلاً من icon
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // وظيفة البحث
                              },
                            ),
                            // أو أبقها icon كما هي إذا أردتها خارج الحقل
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ApartmentCardWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ApartmentCardWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ApartmentCardWidget(),
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
