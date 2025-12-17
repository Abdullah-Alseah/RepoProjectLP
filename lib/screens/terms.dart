import 'package:flutter/material.dart';
import 'package:get/get.dart';
// تأكد من أن هذه المسارات صحيحة في مشروعك
import 'package:marsa_app/utils/config.dart';
import 'package:marsa_app/utils/openMail.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
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
                        Icons.document_scanner,
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
                'الشروط والأحكام',
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
                  icon: Icons.info_outlined,
                  mainTitle: "مقدمة",
                  subTitle:
                      "مرحباً بك في تطبيق عقاري. هذه الشروط والأحكام تحكم استخدامك للتطبيق والخدمات المقدمة. يرجى قراءتها بعناية قبل استخدام التطبيق",
                ),
                const ContentContainer(
                  mainTitle: "1. القبول والموافقة",
                  subTitle:
                      "باستخدامك لتطبيق عقاري، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.",
                ),
                const ContentContainer(
                  mainTitle: "2. استخدام التطبيق",
                  subTitle:
                      "يُسمح لك باستخدام التطبيق للأغراض الشخصية والقانونية فقط. يُحظر استخدام التطبيق لأي أغراض غير قانونية أو احتيالية أو ضارة.",
                ),
                const ContentContainer(
                  mainTitle: "4. المحتوى والإعلانات",
                  subTitle:
                      "جميع العقارات المعروضة في التطبيق يتم توفيرها من قبل وكلاء معتمدين. نحن لا نضمن دقة أو اكتمال المعلومات المقدمة ولا نتحمل المسؤولية عن أي أخطاء أو سهو.",
                ),
                const ContentContainer(
                  mainTitle: "5. الملكية الفكرية",
                  subTitle:
                      "جميع حقوق الملكية الفكرية في التطبيق، بما في ذلك التصميم والمحتوى والشعارات، مملوكة لنا أو لمرخصينا. يُحظر نسخ أو توزيع أو تعديل أي جزء من التطبيق دون إذن كتابي مسبق.",
                ),
                const ContentContainer(
                  mainTitle: "6. المسؤولية",
                  subTitle:
                      "نحن لا نتحمل المسؤولية عن أي أضرار مباشرة أو غير مباشرة أو عرضية أو تبعية ناتجة عن استخدامك للتطبيق أو عدم القدرة على استخدامه.",
                ),
                const ContentContainer(
                  mainTitle: "7. التعديلات",
                  subTitle:
                      "نحتفظ بالحق في تعديل هذه الشروط والأحكام في أي وقت. سيتم إخطارك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني.",
                ),
                const ContentContainer(
                  mainTitle: "8. إنهاء الحساب",
                  subTitle:
                      "نحتفظ بالحق في تعليق أو إنهاء حسابك في أي وقت إذا انتهكت هذه الشروط أو إذا كان استخدامك للتطبيق يضر بمصالحنا أو مصالح المستخدمين الآخرين.",
                ),
                const ContentContainer(
                  mainTitle: "9. القانون الحاكم",
                  subTitle:
                      "تخضع هذه الشروط والأحكام لقوانين المملكة العربية السعودية. أي نزاع ينشأ عن هذه الشروط سيتم حله في المحاكم المختصة في المملكة.",
                ),
                const ContentContainer(
                  mainTitle: "10. الاتصال",
                  subTitle:
                      "إذا كان لديك أي أسئلة حول هذه الشروط والأحكام، يرجى الاتصال بنا عبر البريد الإلكتروني: info@marsa.com أو الهاتف: 0000 000 09 963+",
                ),

                // Config.spaceBig,
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
                            Icons.headset_mic_outlined,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          "هل لديك أسئلة؟",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: Config.mainFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "فريق الدعم لمساعدتك على مدار الساعة",
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
                        color: Config.secandryColor.withOpacity(
                          0.3,
                        ), // استخدام opacity بدلاً من alpha للقراءة الأسهل
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
