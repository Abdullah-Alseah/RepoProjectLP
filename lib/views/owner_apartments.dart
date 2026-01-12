import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/views/components/owner_apartment_card.dart';

class OwnerApartmentsPage extends StatefulWidget {
  const OwnerApartmentsPage({super.key});

  @override
  State<OwnerApartmentsPage> createState() => _OwnerApartmentsPageState();
}

class _OwnerApartmentsPageState extends State<OwnerApartmentsPage> {
  final ApartmentStore _apartmentStore = Get.find<ApartmentStore>();
  bool _isInitialized = false;
  bool _isRefreshing = false;
  bool _isFirstLoad = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOwnerApartments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerApartments() async {
    try {
      await _apartmentStore.fetchOwnerApartments(refresh: true);
      _isInitialized = true;
      _isFirstLoad = false;
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ خطأ في تحميل شقات المالك: $e');
      _isFirstLoad = false;
    }
  }

  Future<void> _refreshApartments() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _apartmentStore.fetchOwnerApartments(refresh: true);
    } catch (e) {
      print('❌ خطأ في تحديث الشقق: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshApartments,
          color: Configuration.primaryColor,
          backgroundColor: Colors.white,
          displacement: 40,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Configuration.primaryColor,
                expandedHeight: 250,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Configuration.primaryColor,
                          Configuration.secandryColor,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: const Icon(
                          Icons.apartment_outlined,
                          color: Colors.white,
                          size: 90,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'شققي',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: Configuration.mainFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              _buildContent(),
              SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      // إذا كان التحميل الأولي ولم يتم التهيئة بعد
      if (_isFirstLoad && _apartmentStore.isLoading) {
        return SliverFillRemaining(child: _buildLottieLoading());
      }

      // إذا كان هناك تحديث (Refresh) وليس التحميل الأولي
      if (_isRefreshing && _apartmentStore.isLoading) {
        if (_apartmentStore.apartments.isNotEmpty) {
          // عرض القائمة مع لودر في الأعلى
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                // الصف الأول: عرض Lottie فوق القائمة
                return Column(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      height: 200,
                      child: Center(child: _buildLottieLoading()),
                    ),
                    _buildApartmentItem(0),
                  ],
                );
              }
              return _buildApartmentItem(index);
            }, childCount: _apartmentStore.apartments.length),
          );
        } else {
          // إذا كانت القائمة فارغة وعملية تحديث، عرض Lottie فقط
          return SliverFillRemaining(child: _buildLottieLoading());
        }
      }

      if (_apartmentStore.error) {
        return SliverFillRemaining(child: _buildLottieError());
      }
      // إذا تم التحميل ولكن القائمة فارغة
      if (_isInitialized && _apartmentStore.apartments.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState());
      }

      // إذا كان هناك شقات ولم يكن هناك تحميل
      if (_apartmentStore.apartments.isNotEmpty) {
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildApartmentItem(index);
          }, childCount: _apartmentStore.apartments.length),
        );
      }

      // حالة افتراضية
      return SliverFillRemaining(child: _buildLottieLoading());
    });
  }

  Widget _buildApartmentItem(int index) {
    final apartment = _apartmentStore.apartments[index];
    return OwnerApartmentCardWidget(
      apartment: apartment,
      index: index,
      onUpdate: () async {
        setState(() {
          _isRefreshing = true;
        });
        await _refreshApartments();
      },
      onDelete: () async {
        setState(() {
          _isRefreshing = true;
        });
        await _refreshApartments();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'لا توجد شقق مضافة',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontFamily: Configuration.mainFont,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'يمكنك إضافة شقة جديدة بالضغط على زر الإضافة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontFamily: Configuration.mainFont,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/addApartment');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Configuration.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'إضافة شقة جديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLottieLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/icons/Sandy Loading.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل الشقق...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontFamily: Configuration.mainFont,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLottieError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/icons/TomatoError.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'حدث خطأ أثناء جلب الشقق. الرجاء المحاولة مرة أخرى   .!',
            style: TextStyle(
              fontSize: 16,
              color: Configuration.primaryColor,
              fontFamily: Configuration.mainFont,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _refreshApartments();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Configuration.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            icon: const Icon(Icons.refresh_outlined, color: Colors.white),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: Configuration.mainFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
