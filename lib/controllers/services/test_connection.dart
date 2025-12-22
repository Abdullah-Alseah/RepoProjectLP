// test_connection.dart
import 'package:dio/dio.dart';

Future<void> testAllConnections() async {
  final Dio dio = Dio();

  // قائمة بالعناوين الممكنة
  final List<String> urls = [
    'http://localhost:8000',
    'http://127.0.0.1:8000',
    'http://10.0.2.2:8000', // للمحاكي Android
    'http://192.168.1.15:8000', // عنوان جهازك
  ];

  print('🔍 اختبار الاتصال بالخادم...');

  for (var url in urls) {
    try {
      print('🔄 جرب الاتصال بـ: $url');

      Response response = await dio.get(
        '$url/api',
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );

      print('✅ نجح الاتصال بـ: $url');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.data}');

      // اختبار API التسجيل
      print('\n🔍 اختبار API التسجيل...');
      try {
        Response apiResponse = await dio.post(
          '$url/api/auth/register',
          data: {
            'first_name': 'test',
            'last_name': 'test',
            'phone': '0999999999',
            'password': 'Test1234@',
            'password_confirmation': 'Test1234@',
            'date_of_birth': '2000-01-01',
            'role': 'tenant',
          },
          options: Options(
            contentType: 'application/json',
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        print('✅ API التسجيل يعمل: ${apiResponse.statusCode}');
        return;
      } on DioException catch (e) {
        print('⚠️ API التسجيل لديه مشكلة: ${e.response?.statusCode}');
        print('📋 Error: ${e.response?.data}');
      }
    } on DioException catch (e) {
      print('❌ فشل الاتصال بـ: $url');
      print('   Error: ${e.message}');
      print('   Type: ${e.type}');

      if (e.response != null) {
        print('   Status: ${e.response!.statusCode}');
      }
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
    }
    print('---');
  }

  print('\n⚠️ لم أتمكن من الاتصال بأي عنوان!');
  print('✅ تأكد من:');
  print('   1. Laravel شغال: php artisan serve --host=0.0.0.0 --port=8000');
  print('   2. جدار الحماية يسمح بالبورت 8000');
  print('   3. الكمبيوتر والهاتف على نفس الشبكة');
  print('   4. IP الكمبيوتر صحيح: 192.168.1.15');
}
