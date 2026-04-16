import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../project_specific/text_theme.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          "FAQ",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. What features does Scuts offer to customers?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "Scuts provides:",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              Text(
                ". Nearby salon discovery with ratings and distance.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              Text(
                ". - Detailed stylist profiles to choose your preferred professional.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              Text(
                ". - A service catalog for each salon.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              Text(
                ". - Appointment booking with specific stylists.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              Text(
                ". - Personalized blogs and insights based on your hair and skin type.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "2. What is Stylist Profile and How it helps?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "Stylist profile shows all the previous work and ratings of that stylist which helps in choosing him/her for your service",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "3. What are personalized insights?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "Personalized insights are tailored recommendations and blogs provided by Scuts based on your hair and skin type. These could include tips for hair care, skin routines, or solutions to specific issues like hair fall or acne.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "4. How do I check salon ratings?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                " Salon ratings are displayed on the app alongside the distance from your location, helping you choose the best option nearby.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "5. Is Scuts free for customers?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "Yes, Scuts is free to use for customers.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "6. Can I choose my stylist?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "Absolutely! Scuts provides detailed stylist profiles, allowing you to select the stylist that best suits your needs.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "7. Can I customise service products?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "Yes, you can.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "8. How average stylist rating of salon is calculated?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                " Average stylist rating of salon is average of ratings of all stylists working in salon.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "9. Do We Save the pictures of the service without the consent?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                " No, the images are deleted right away from our database when we dont have the consent.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "10. why do we collect service images?",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Text(
                "This helps in evaluating the service of the stylist without any manipulation, solely not depending only on ratings.",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor.withOpacity(0.5)),
              ),
              const SizedBox(height: 10),
              Text(
                "Contact us at",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _openMailBox();
                    },
                    child: Text(
                      "talktous@scuts.in",
                      style: AppTextTheme.medium
                          .copyWith(color: ColorConstant.primaryColor),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        _openDialer();
                      },
                      child: Text(
                        "+91 88970 90838",
                        style: AppTextTheme.medium
                            .copyWith(color: ColorConstant.primaryColor),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openMailBox() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'talktous@scuts.in', // Replace with recipient email
      query:
          'subject=Hello&body=How are you?', // Optional: Replace with subject and body
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _openDialer() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '88970 90838', // Replace with the phone number you want to dial
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }
}
