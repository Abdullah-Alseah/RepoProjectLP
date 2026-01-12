import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/sendMail.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    Configuration.init(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              automaticallyImplyActions: false,
              backgroundColor: Configuration.primaryColor,
              actions: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
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
                          gradient: Configuration.gradientColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: Configuration.heightSize * 0.1,
                      right: Configuration.widthSize * 0.12,
                      child: CircleAvatar(
                        radius: 70,
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
                    Positioned(
                      bottom: Configuration.heightSize * 0.15,
                      left: Configuration.widthSize * 0.15,
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
                    fontFamily: Configuration.mainFont,
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

                  Configuration.spaceMedium,

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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Configuration.primaryColor.withOpacity(0.3),
                            blurRadius: 3.5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'أنواع البيانات المجمعة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: Configuration.mainFont,
                            ),
                          ),

                          Configuration.spaceMedium,

                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200, // أقصى عرض لكل عنصر
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                ),
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
                  Configuration.spaceBig,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: Configuration.gradientColor,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Configuration.primaryColor.withOpacity(0.3),
                            blurRadius: 3.5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'ميزات الأمان لدينا',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'تشفير SSL متقدم',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.white12,
                                  radius: 20,
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'حماية البيانات متعددة الطبقات',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.white12,
                                  radius: 20,
                                  child: Icon(
                                    Icons.security_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'عدم مشاركة البيانات مع أطراف ثالثة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.white12,
                                  radius: 20,
                                  child: Icon(
                                    Icons.visibility_off_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Configuration.spaceSmall,
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Configuration.primaryColor.withOpacity(0.3),
                            blurRadius: 3.5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundColor: Configuration.primaryColor
                                .withAlpha(50),
                            radius: 30,
                            child: Icon(
                              Icons.mail_outline_outlined,
                              color: Configuration.primaryColor,
                            ),
                          ),

                          Text(
                            "أسئلة حول الخصوصية؟",
                            style: TextStyle(
                              color: Configuration.primaryColor,
                              fontFamily: Configuration.mainFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "تواصل مع فريق الخصوصية لدينا",
                            style: TextStyle(
                              color: Configuration.primaryColor,
                              fontFamily: Configuration.mainFont,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                openMail();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: Configuration.gradientColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "تواصل معنا",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Configuration.spaceMedium,
                  Text(
                    "© 2025 مَرسَى. جميع الحقوق محفوظة",
                    style: TextStyle(
                      fontSize: 15,
                      // fontWeight: FontWeight.bold,
                      color: Configuration.primaryColor,
                      fontFamily: Configuration.mainFont,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
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
                color: Configuration.primaryColor.withOpacity(0.3),
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
                        color: Configuration.secandryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(icon, color: Configuration.primaryColor),
                    ),
                  Configuration.spaceSmall,
                  Text(
                    mainTitle ?? "",
                    style: TextStyle(
                      fontFamily: Configuration.mainFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Configuration.spaceMedium,
              Text(
                subTitle ?? "",
                style: TextStyle(
                  fontFamily: Configuration.mainFont,
                  fontSize: 16,
                ),
              ),
              Configuration.spaceSmall,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // استخدام نسبة ثابتة ولكن بحجم مرن
        return AspectRatio(
          aspectRatio: 1.1, // نفس النسبة الأصلية
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            padding: EdgeInsets.all(
              constraints.maxWidth * 0.05, // padding نسبي
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // الأيقونة في الأعلى
                Container(
                  width: constraints.maxWidth * 0.2, // حجم نسبي للأيقونة
                  height: constraints.maxWidth * 0.2,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    // size: constraints.maxWidth * 0.08, // حجم أيقونة نسبي
                  ),
                ),

                SizedBox(height: constraints.maxHeight * 0.04),

                // العنوان
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: Configuration.mainFont,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: constraints.maxHeight * 0.03),

                // العناصر (النقاط)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: constraints.maxHeight * 0.02,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: constraints.maxHeight * 0.03,
                                left: constraints.maxHeight * 0.02,
                                right: constraints.maxWidth * 0.02,
                              ),
                              child: Container(
                                width: constraints.maxWidth * 0.02,
                                height: constraints.maxWidth * 0.02,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                items[index],
                                style: TextStyle(
                                  height: 1.4,
                                  fontFamily: Configuration.mainFont,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
