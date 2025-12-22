import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/main_layout_controller.dart';
import 'package:marsa_app/controllers/glassContainer.dart';
// import 'package:marsa_app/controllers/config.dart';
// import 'package:marsa_app/views/homeScreen.dart';
// import 'package:marsa_app/views/loginScreen.dart';
// import 'package:marsa_app/views/RegistrationScreen.dart';
// import 'package:marsa_app/views/profile%D9%8DScreen.dart';
// import 'glassContainer.dart';
// import 'package:marsa_app/views/terms.dart';
// import 'package:marsa_app/views/privacy.dart';

class MainLayout extends StatelessWidget {
  // const MainLayout({super.key});
  // int currentPage = 0;
  // final PageController _page = PageController();
  // static final navigatorKey = GlobalKey<NavigatorState>();

  final MainLayoutController controller = Get.put(MainLayoutController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.currentPageIndex.value]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 30,
              offset: Offset(0, 25),
            ),
          ],
        ),
        child: ClassContainer(
          width: double.infinity,
          height: 81,
          child: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.currentPageIndex.value,
              onTap: (page) => {controller.changePage(page)},
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_outlined),
                  label: 'Favorite',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.person_2_outlined),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Scaffold(
    //   body: Stack(
    //     children: [
    //       PageView(
    //         controller: _page,
    //         onPageChanged: ((value) => {
    //           setState(() {
    //             currentPage = value;
    //           }),
    //         }),
    //         children: <Widget>[
    //           HomeScreen(),
    //           LoginScreen(),
    //           PrivacyPage(),
    //           ProfilePage(),
    //         ],
    //       ),
    //       Positioned(
    //         bottom: 0,
    //         right: 0,
    //         left: 0,
    //         child: Container(
    //           decoration: const BoxDecoration(
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Colors.black12,
    //                 blurRadius: 30,
    //                 offset: Offset(0, 25),
    //               ),
    //             ],
    //           ),
    //           child: ClassContainer(
    //             width: double.infinity,
    //             height: 81,
    //             child: BottomNavigationBar(
    //               currentIndex: currentPage,
    //               onTap: (page) => {
    //                 setState(() {
    //                   currentPage = page;

    //                   _page.animateToPage(
    //                     page,
    //                     duration: const Duration(milliseconds: 100),
    //                     curve: Curves.fastOutSlowIn,
    //                   );
    //                 }),
    //               },
    //               items: const <BottomNavigationBarItem>[
    //                 BottomNavigationBarItem(
    //                   icon: Icon(Icons.home_outlined),
    //                   label: 'Home',
    //                 ),

    //                 BottomNavigationBarItem(
    //                   icon: Icon(Icons.search),
    //                   label: 'Search',
    //                 ),

    //                 BottomNavigationBarItem(
    //                   icon: Icon(Icons.favorite_border_outlined),
    //                   label: 'Favorite',
    //                 ),

    //                 BottomNavigationBarItem(
    //                   icon: Icon(Icons.person_2_outlined),
    //                   label: 'Profile',
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
