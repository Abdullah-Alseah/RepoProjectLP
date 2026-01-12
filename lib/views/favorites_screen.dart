import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/main_layout_controller.dart';
import 'package:marsa_app/models/apartment_model.dart';
import 'package:marsa_app/stores/favorite_store.dart';
import 'package:marsa_app/views/components/apartment_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteStore _favoriteStore = Get.put(FavoriteStore());
  final MainLayoutController controller = Get.put(MainLayoutController());
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Apartment> _displayedFavorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    
  }

  Future<void> _loadFavorites() async {
    try {
      await _favoriteStore.getFavorites();

      // تحديث القائمة المعروضة
      _displayedFavorites = List.from(_favoriteStore.favorites);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ خطأ في تحميل المفضلة: $e');
    }
  }

  void _removeFavoriteWithAnimation(int apartmentId, int index) {
    final removedApartment = _displayedFavorites[index];

    _displayedFavorites.removeAt(index);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedApartment, animation),
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _favoriteStore.removeFromFavorite(apartmentId);
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildRemovedItem(Apartment apartment, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: ApartmentCardWidget(
          apartment: apartment,
          onFavoriteChanged: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyActions: false,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'المفضلة',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: Configuration.mainFont,
            ),
          ),
          centerTitle: true,
        ),
        body: _displayedFavorites.isEmpty
            ? _buildEmptyView()
            : RefreshIndicator(
                onRefresh: _loadFavorites,
                color: Configuration.primaryColor,
                child: AnimatedList(
                  key: _listKey,
                  initialItemCount: _displayedFavorites.length,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: (context, index, animation) {
                    final apartment = _displayedFavorites[index];

                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(-0.5, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: animation,
                        child: ApartmentCardWidget(
                          apartment: apartment,
                          onFavoriteChanged: () {
                            if (!_favoriteStore.isFavorite(apartment.id)) {
                              _removeFavoriteWithAnimation(apartment.id, index);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text(
              'لا توجد شقق مفضلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'قم بإضافة شقق إلى المفضلة للعثور عليها بسهولة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.goToPage(0);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Configuration.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'تصفح الشقق',
                style: TextStyle(fontFamily: Configuration.mainFont),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
