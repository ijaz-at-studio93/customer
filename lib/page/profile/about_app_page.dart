import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/app_conctant.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  String version = "";
  @override
  void initState() {
    super.initState();
    getVersionApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          "About",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "SALON is your one-stop shop for premium salon services in the comfort of your home. We bring the salon experience to you, allowing you to schedule appointments for various beauty treatments at your convenience.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "1. Convenience & Choice",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "With our user-friendly app, you can browse a wide range of services, select a skilled professional, and book an appointment in just a few taps. Whether you need a haircut, a relaxing massage, or a fresh mani-pedi, SALON has you covered.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "2. Quality You Can Trust",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "We partner with only the most experienced and qualified beauty professionals. Our commitment to high standards ensures you receive a professional and consistent service every time.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "3. Your Time, Your Comfort",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "Skip the salon wait times and traffic hassles! SALON allows you to relax and enjoy your treatments in the comfort of your home, on your schedule.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "4. Our Vision",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "We are passionate about making self-care accessible and convenient for everyone. We strive to empower beauty professionals and elevate the in-home salon experience.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Vision $version",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*------------  Get  Version  ---------------*/
  void getVersionApp() async {
    String data = await getVersion();
    setState(() {
      version = data;
    });
  }
}
