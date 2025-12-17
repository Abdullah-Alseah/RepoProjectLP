import 'package:flutter/material.dart';
import 'package:get/get.dart';
// تأكد من أن هذه المسارات صحيحة في مشروعك
import 'package:marsa_app/utils/config.dart';
import 'package:marsa_app/utils/openMail.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    Config.init(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            automaticallyImplyActions: false,
            backgroundColor: Config.primaryColor,
            leading: Container(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white.withOpacity(
                  0.2,
                ), // تم تعديل Alpha لأفضل ممارسة
                child: IconButton(
                  padding: EdgeInsets.zero, // تحسين تموضع الأيقونة
                  onPressed: () {
                    // لا حاجة لـ setState هنا
                    Get.toNamed("/Register");
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            expandedHeight: 500,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 500,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: Config.gradientColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 30,
                            offset: Offset(0, 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 60,
                    right: 80,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 130,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 100,
                    left: 125,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ],
              ),
              title: Text(
                'سياسة الخصوصية',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: Config.mainFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const ContentContainer(
                  icon: Icons.security_outlined,
                  mainTitle: "التزامنا بخصوصيتك",
                  subTitle:
                      "نحن في عقاري نلتزم بحماية خصوصيتك وأمان معلوماتك الشخصية. توضح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك.",
                ),

                Config.spaceMedium,

                // الخط الفاصل
                Container(
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Config.primaryColor.withOpacity(0.3),
                          blurRadius: 3.5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // أنواع البيانات المجمعة
                        const Text(
                          'أنواع البيانات المجمعة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: Config.mainFont,
                          ),
                        ),

                        Config.spaceMedium,

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: const [
                            DataTypeGridItem(
                              title: 'المعلومات الشخصية',
                              items: ['الاسم', 'الهاتف', 'تاريخ الميلاد'],
                              icon: Icons.person_outline,
                              color: Color(0xFF4CAF50),
                            ),

                            DataTypeGridItem(
                              title: 'معلومات الجهاز',
                              items: ['نوع الجهاز', 'نظام التشغيل'],
                              icon: Icons.phone_iphone,
                              color: Color(0xFF2196F3),
                            ),

                            DataTypeGridItem(
                              title: 'معلومات الموقع',
                              items: ['الموقع الجغرافي', 'التقريري'],
                              icon: Icons.location_on_outlined,
                              color: Color(0xFFFF9800),
                            ),

                            DataTypeGridItem(
                              title: 'سجل الاستخدام',
                              items: ['الصفحات المشاهدة', 'التفاعلات'],
                              icon: Icons.history,
                              color: Color(0xFF9C27B0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const ContentContainer(
                  mainTitle: "1. المعلومات التي نجمعها",
                  subTitle:
                      "نقوم بجمع المعلومات التي تقدمها لنا مباشرة عند التسجيل في التطبيق، مثل الاسم والبريد الإلكتروني ورقم الهاتف وتاريخ الميلاد والصور الشخصية. كما نجمع معلومات حول استخدامك للتطبيق تلقائياً.",
                ),
                const ContentContainer(
                  mainTitle: "2. كيفية استخدام المعلومات",
                  subTitle:
                      "نستخدم المعلومات التي نجمعها لتوفير وتحسين خدماتنا، والتواصل معك، وتخصيص تجربتك، وضمان أمان التطبيق، وإرسال إشعارات حول العقارات الجديدة والعروض الخاصة.",
                ),
                const ContentContainer(
                  mainTitle: "3. مشاركة المعلومات",
                  subTitle:
                      "نستخدم المعلومات التي نجمعها لتوفير وتحسين خدماتنا، والتواصل معك، وتخصيص تجربتك، وضمان أمان التطبيق، وإرسال إشعارات حول العقارات الجديدة والعروض الخاصة.",
                ),
                const ContentContainer(
                  mainTitle: "4. أمان المعلومات",
                  subTitle:
                      "نتخذ تدابير أمنية معقولة لحماية معلوماتك من الوصول غير المصرح به أو التغيير أو الإفصاح أو التدمير. نستخدم تشفير SSL وتقنيات أمان متقدمة لحماية بياناتك.",
                ),
                const ContentContainer(
                  mainTitle: "5. ملفات تعريف الارتباط",
                  subTitle:
                      "نستخدم ملفات تعريف الارتباط (Cookies) وتقنيات مشابهة لتحسين تجربتك وتحليل استخدام التطبيق. يمكنك التحكم في ملفات تعريف الارتباط من خلال إعدادات المتصفح الخاص بك.",
                ),
                const ContentContainer(
                  mainTitle: "6. حقوقك",
                  subTitle:
                      "لديك الحق في الوصول إلى معلوماتك الشخصية وتصحيحها أو حذفها. يمكنك أيضاً الاعتراض على معالجة معلوماتك أو طلب تقييد المعالجة. للقيام بذلك، يرجى الاتصال بنا.",
                ),
                const ContentContainer(
                  mainTitle: "7. الاحتفاظ بالبيانات",
                  subTitle:
                      "نحتفظ بمعلوماتك الشخصية طالما كان حسابك نشطاً أو حسب الحاجة لتقديم الخدمات لك. قد نحتفظ ببعض المعلومات للامتثال للالتزامات القانونية أو حل النزاعات.",
                ),
                const ContentContainer(
                  mainTitle: "8. خصوصية الأطفال",
                  subTitle:
                      "تطبيقنا غير موجه للأطفال دون سن 18 عاماً. لا نجمع عن قصد معلومات شخصية من الأطفال. إذا علمنا أننا جمعنا معلومات من طفل، سنقوم بحذفها فوراً.",
                ),
                const ContentContainer(
                  mainTitle: "9. التغييرات على السياسة",
                  subTitle:
                      "قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنخطرك بأي تغييرات جوهرية عن طريق نشر السياسة الجديدة على التطبيق وإرسال إشعار لك.",
                ),
                const ContentContainer(
                  mainTitle: "10. الاتصال بنا",
                  subTitle:
                      "إذا كان لديك أي أسئلة أو مخاوف بشأن سياسة الخصوصية هذه أو ممارساتنا، يرجى الاتصال بنا عبر البريد الإلكتروني: privacy@marsa.com أو الهاتف: 0000 000 90 963+",
                ),
                Config.spaceBig,
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: Config.gradientColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Config.primaryColor.withOpacity(0.3),
                          blurRadius: 3.5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white12,
                          radius: 30,
                          child: Icon(
                            Icons.mail_outline_outlined,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          "أسئلة حول الخصوصية؟",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: Config.mainFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "تواصل مع فريق الخصوصية لدينا",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: Config.mainFont,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle form submission
                              openMail();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "تواصل معنا",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Config.primaryColor,
                                fontFamily: Config.mainFont,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Config.spaceMedium,
                Text(
                  "© 2025 مَرسَى. جميع الحقوق محفوظة",
                  style: TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.bold,
                    color: Config.primaryColor,
                    fontFamily: Config.mainFont,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContentContainer extends StatelessWidget {
  final String? mainTitle;
  final String? subTitle;
  final IconData? icon;

  const ContentContainer({super.key, this.icon, this.mainTitle, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Config.primaryColor.withOpacity(0.3),
                blurRadius: 1.5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (icon != null)
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Config.secandryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(icon, color: Config.primaryColor),
                    ),
                  Config.spaceSmall,
                  Text(
                    mainTitle ?? "",
                    style: TextStyle(
                      fontFamily: Config.mainFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Config.spaceMedium,
              Text(
                subTitle ?? "",
                style: TextStyle(fontFamily: Config.mainFont, fontSize: 16),
              ),
              Config.spaceSmall,
            ],
          ),
        ),
      ),
    );
  }
}

class DataTypeGridItem extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const DataTypeGridItem({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأيقونة في الأعلى
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(height: 12),

          // العنوان
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: Config.mainFont,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          // العناصر (النقاط)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, right: 6),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: Config.mainFont,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
