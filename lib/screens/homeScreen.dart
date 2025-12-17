import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:marsa_app/components/apartment_card.dart';
import 'package:marsa_app/controllers/auth_controller.dart';
import 'package:marsa_app/utils/config.dart';

class HomeSecreen extends StatefulWidget {
  const HomeSecreen({super.key});

  @override
  State<HomeSecreen> createState() => _HomeSecreenState();
}

class _HomeSecreenState extends State<HomeSecreen> {
  final AuthController authController = Get.put(AuthController());
  bool get _logged => authController.isLoggedIn.value;

  @override
  Widget build(BuildContext context) {
    Config.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            actions: [
              Container(
                padding: EdgeInsetsGeometry.all(10),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Config.primaryColor.withAlpha(80),
                  child: AuthController().isLoggedIn.value
                      ? IconButton(
                          onPressed: () {
                            print(AuthController().isLoggedIn.value);
                          },
                          icon: Icon(Icons.abc, color: Colors.white),
                        )
                      : IconButton(
                          onPressed: () {
                            print(AuthController().isLoggedIn.value);
                            Get.toNamed("/login");
                          },
                          icon: Icon(Icons.headphones, color: Colors.white),
                        ),
                ),
              ),
            ],
            expandedHeight: 300,
            floating: false,
            // للتثبيت الاب بار عند السحب
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                height: 300,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/background/1.jpg'),
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
                      height: 120,
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
                  fontFamily: Config.mainFont,
                  // color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverAppBar(
            automaticallyImplyLeading: false,
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
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          textAlign: TextAlign.right,

                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontFamily: Config.mainFont),
                          decoration: InputDecoration(
                            hintText: "...ابحث عن موقع، مدينة",
                            hintTextDirection: TextDirection.rtl,
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, color: Colors.grey),
                              onPressed: () {
                                // وظيفة البحث
                              },
                            ),
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
