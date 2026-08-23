import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:labourattendence/app_language.dart';
import 'package:labourattendence/language_provider.dart';
import 'package:labourattendence/login_screen.dart';
import 'package:hive/hive.dart';
import 'package:labourattendence/pin_setup_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool isAppLock = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    isAppLock = Hive.box('labours').get(
      "appLock",
      defaultValue: false,
    );
  }


  Future<void> authenticateUser(bool value) async {
    if (value) {
      bool? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
        ),
      );

      if (result == true) {
        setState(() {
          isAppLock = true;
        });
      }

    } else {

      await Hive.box('labours').put("appLock", false);
      await Hive.box('labours').delete("appPin");

      setState(() {
        isAppLock = false;
      });
    }
  }

  Widget tile(
      IconData icon,
      String title,
      String subtitle,
      {bool showArrow = false}
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget menuTile(
      IconData icon,
      String title, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }

  void openMobileSheet(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode]!;

    var box = Hive.box('labours');

    final mobileController = TextEditingController(
      text: box.get("mobile", defaultValue: ""),
    );

    bool isChanged = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update Mobile Number",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          isChanged = true;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isChanged
                            ? () async {
                          await box.put(
                            "mobile",
                            mobileController.text,
                          );
                          Navigator.pop(context);
                        }
                            : null,
                        child: Text(
                          lang["save"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openLanguageSheet(BuildContext context) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) {

        return SizedBox(
          height: 200,
          child: Column(
            children: [

              const SizedBox(height: 20),

              const Text(
                "Choose Language",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("English"),
                onTap: () {
                  Provider.of<LanguageProvider>(
                    context,
                    listen: false,
                  ).changeLanguage("en");

                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("मराठी"),
                onTap: () {
                  Provider.of<LanguageProvider>(
                    context,
                    listen: false,
                  ).changeLanguage("mr");

                  Navigator.pop(context);
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.values[
    Provider.of<LanguageProvider>(context)
        .locale
        .languageCode]!;
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          lang["settings"]!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              openLanguageSheet(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              child: const Row(
                children: [
                  Text(
                    "अ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "A",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                lang["profile"]!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: Hive.box('labours').listenable(),
                      builder: (context, box, _) {
                        return Column(
                          children: [
                            tile(
                              Icons.person_outline,
                              lang["name"]!,
                              box.get("name", defaultValue: "No Name"),
                            ),

                            GestureDetector(
                              onTap: () {
                                openMobileSheet(context);
                              },
                              child: tile(
                                Icons.call_outlined,
                                lang["mobile"]!,
                                box?.get("mobile", defaultValue: "No Mobile"),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    Container(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 28),
                           const SizedBox(width: 20),
                           Expanded(
                            child: Text(
                              lang["appLock"]!,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Switch(
                            value: isAppLock,
                            onChanged: (value) {
                              authenticateUser(value);
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

               Text(
                lang["general"]!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    menuTile(
                      Icons.menu_book_outlined,
                      lang["terms"]!,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              title: Text(
                                lang["terms"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Text(
                                  lang["termsContent"]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    lang["done"]!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    menuTile(
                      Icons.notifications_none,
                      lang["logout"]!,
                      onTap: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              title:  Text(
                                lang["logout"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                lang["messagelogout"]!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text(
                                    lang["Cancel"]!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(lang["logout"]!),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          var sessionBox = Hive.box('session');
                          await sessionBox.clear();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                                (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
