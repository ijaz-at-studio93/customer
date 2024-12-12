import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/app_conctant.dart';

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
                "Welcome to Scuts, your one-stop destination for effortless salon booking and personalized grooming experiences!",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "We understand that choosing the right salon or stylist can be overwhelming. That’s why we created Scuts – a platform designed to connect you with trusted salons and expert stylists in your area. Whether you’re looking for a quick haircut, a relaxing spa day, or specialized hair and skin treatments, Scuts makes it simple to find and book the services you need.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Our app offers:",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "-Stylist Profiles: Get to know your stylist before booking.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "-Personalized Insights: Receive tips and blogs tailored to your hair and skin needs.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "-Transparent Reviews: Read ratings and feedback from real customers.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "-Easy Scheduling: Book appointments with just a few taps.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "At Scuts, we’re on a mission to empower unorganized salons by enhancing their visibility and helping them deliver better customer experiences. Together, let’s make salon visits convenient, enjoyable, and stress-free.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Discover your next favorite stylist with Scuts!",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 10),
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
