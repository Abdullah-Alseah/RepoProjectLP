import 'package:flutter/material.dart';
import 'package:marsa_app/screens/homeScreen.dart';
import 'package:marsa_app/screens/loginScreen.dart';
import 'package:marsa_app/screens/RegistrationScreen.dart';
import 'glassContainer.dart';
import 'package:marsa_app/screens/terms.dart';
import 'package:marsa_app/screens/privacy.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _page = PageController();
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _page,
            onPageChanged: ((value) => {
              setState(() {
                currentPage = value;
              }),
            }),
            children: <Widget>[
              HomeSecreen(),
              LoginScreen(),
              PrivacyPage(),
              RegistrationPage(),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
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
                height: 70,
                child: BottomNavigationBar(
                  currentIndex: currentPage,
                  onTap: (page) => {
                    setState(() {
                      currentPage = page;
                      _page.animateToPage(
                        page,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                      );
                    }),
                  },
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
        ],
      ),
    );
  }
}
