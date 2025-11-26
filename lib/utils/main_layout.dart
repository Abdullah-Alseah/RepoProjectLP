import 'package:flutter/material.dart';
import 'package:marsa_app/screens/homeScreen.dart';
import 'package:marsa_app/utils/config.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _page = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _page,
        onPageChanged: ((value) => {
          setState(() {
            currentPage = value;
          }),
        }),
        children: const <Widget>[HomeSecreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle:const TextStyle(
          color: Config.primaryColor,
          fontFamily: 'Tajawal', // استبدل Cairo باسم الخط الذي تستخدمه
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.black12,
          fontFamily: "Tajawal",
          fontSize: 12,
        ),

        unselectedItemColor: Colors.black12,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: Config.primaryColor,

        currentIndex: currentPage,
        onTap: (page) => {
          setState(() {
            currentPage = page;
            _page.animateToPage(
              page,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }),
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined,),
          label: 'حسابي',
        ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined,),
            label: 'المفضلة',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined,),
            label: 'الرئيسية',
          ),

        ],
      ),
    );
  }
}
