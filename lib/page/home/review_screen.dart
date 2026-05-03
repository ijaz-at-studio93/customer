import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_customer/model/booking_history_list_model.dart';

import '../../constant/api_constant.dart';
import '../../constant/variable_constant.dart';
import '../../controller/home_controller.dart';
import '../../model/salon_details_artiest.dart';
import '../../util/SharedPrefs.dart';
import '../../util/NoItemsWidget.dart';
import '../../util/snackbar_util.dart';

class ReviewItem {
  String id;
  String type;
  String name;
  String? profileImage;
  int rating;
  String review;
  List<String> images;

  ReviewItem({
    required this.id,
    required this.type,
    required this.name,
    this.profileImage,
    this.rating = 0,
    this.review = "",
    this.images = const [],
  });
}

class ReviewScreen extends StatefulWidget {
  final String appointmentId;
  final String salonId;

  const ReviewScreen({super.key, required this.appointmentId, required this.salonId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewItem> reviewItems = [];
  final _homeController = Get.find<HomeController>();
  Set<String> selectedChips = {};
  bool _submitted = false;

  String salonName = "";
  int salonRating = 0;
  String salonReview = "";
  // 🔥 ONLY ADD THIS VARIABLE (top of _ReviewScreenState)
  String serviceId = "";

  // @override
  // void initState() {
  //   super.initState();
  //   //_homeController.doGetSalonArtiestListData(salonId: widget.salonId);
  //
  //   _initData();
  // }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }


  Future<void> _initData() async {
    final bookings = _homeController.getBookingHistoryListModel;

    if (bookings.data == null || bookings.data!.isEmpty) return;

    final booking = bookings.data!.firstWhere(
          (b) => b.appointmentId == widget.appointmentId,
      orElse: () => bookings.data!.first,
    );
    //print("STYLIST IDS FROM BOOKING: ${booking.appointment?.stylistIds}");

    salonName = booking.salon?.displayName ?? "";

    /// 🔥 CALL API SAFELY (NO LOOP, NO BLOCK)
    // await _homeController.doGetSalonArtiestListData(
    //   salonId: widget.salonId,
    // );

    loadReviewItems(booking);
  }

  Future<void> loadReviewItems(HistoryList? booking) async {
    List<ReviewItem> temp = [];

    salonName = booking?.salon?.displayName ?? "";

    final items = booking?.items ?? [];

    final serviceItem = items.where((e) => e.service != null).isNotEmpty
        ? items.firstWhere((e) => e.service != null)
        : null;

    serviceId = serviceItem?.service?.id ?? "a62d29f5-3fc1-4f20-8151-8e5af3a52765";

    /// ✅ USE selectedStylists directly
    final stylists = booking?.appointment?.selectedStylists ?? [];

    for (final stylist in stylists) {
      if (stylist.id != null) {
        temp.add(
          ReviewItem(
            id: stylist.id ?? "",
            type: "artist",
            name: stylist.name ?? "",
          ),
        );
      }
    }

    setState(() {
      reviewItems = temp;
    });
  }

  Future<bool> submitAllReviews() async {
    try {
      _homeController.isSubmittingReview.value = true;

      final chipReview = selectedChips.join(", ");

      /// 🔥 SALON REVIEW (ONLY ONCE)
      await _homeController.doAddServiceReview(
        appointmentId: widget.appointmentId,
        rate: salonRating.toDouble(),
        salonServiceId: serviceId, // ✅ correct mapping
        review: salonReview.isNotEmpty ? salonReview : chipReview,
      );

      /// 🔥 STYLIST REVIEWS (ONLY ARTIST API)
      for (final item in reviewItems) {
        await _homeController.doAddArtistReview(
          appointmentId: widget.appointmentId,
          rate: item.rating.toDouble(),
          salonArtistId: item.id,
          review: item.review.isNotEmpty ? item.review : '',
        );
      }

      await _homeController.doCheckPendingReview();
      _homeController.hasPendingReview.value = false;

      return true;

    } catch (e) {
      SnackbarUtil.show("Error", e.toString());
      return false;
    } finally {
      _homeController.isSubmittingReview.value = false;
    }
  }

  Widget chip(String text) {
    final isSelected = selectedChips.contains(text);

    return GestureDetector(
      onTap: () async {
        setState(() {
          if (isSelected) {
            selectedChips.remove(text);
          } else {
            selectedChips.add(text);
          }
        });

        /// 🔥 AUTO SUBMIT TRIGGER
        //onRatingUpdated();
      },
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8565D0)
                : Colors.grey.shade300,
          ),
          color: isSelected
              ? const Color(0xFF8565D0).withOpacity(0.1)
              : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: "Outfit",
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF8565D0)
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildSalonStars() {
    return Row(
      children: List.generate(5, (index) {
        int starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              salonRating = starIndex;
            });
            //onRatingUpdated();
          },
          child: Icon(
            Icons.star,
            size: 32.5,
            color: starIndex <= salonRating
                ? const Color(0xFFFFD20C)
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget buildStars(ReviewItem item) {
    return Row(
      children: List.generate(5, (index) {
        int starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              item.rating = starIndex;
            });
            //onRatingUpdated();
          },
          child: Icon(
            Icons.star,
            size: 32.5,
            color: starIndex <= item.rating
                ? const Color(0xFFFFD20C)
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget outlineButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 110,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF8565D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 14),
          ],
        ),
      ),
    );
  }

  void openReviewInput({ReviewItem? item, bool isSalon = false}) {
    List<String> selectedImages =
    isSalon ? [] : List.from(item?.images ?? []);
    bool isUploading = false;
    String? uploadedImageUrl;
    TextEditingController controller = TextEditingController(
      text: isSalon ? salonReview : item?.review ?? "",
    );

    String? imagePath; // optional image

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// TEXT FIELD
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: "Type Here",
                          hintStyle: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ACTION ROW (Submit + Upload)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          /// SUBMIT BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8565D0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isSalon) {
                                  salonReview = controller.text;
                                } else {
                                  item!.review = controller.text;
                                  item.images = List.from(selectedImages); // ✅ STORE IMAGES
                                }
                              });

                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          /// IMAGE UPLOAD
                          GestureDetector(
                            onTap: () async {
                              final pickedFiles = await ImagePicker().pickMultiImage(
                                imageQuality: 70,
                              );

                              if (pickedFiles.isNotEmpty) {
                                setStateDialog(() {
                                  selectedImages.addAll(pickedFiles.map((e) => e.path));
                                });
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt,
                                    color: Color(0xFF8565D0)),
                                const SizedBox(width: 6),
                                Text(
                                  "Drop Image",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(height: 10),

                      /// 🔥 IMAGE PREVIEW (ADD HERE)
                      if (selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(selectedImages.length, (index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(selectedImages[index]),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setStateDialog(() {
                                          selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildStylistImage(ReviewItem item) {
    // final artists = _homeController.getSalonDetailsArtiestData.data ?? [];
    // print(artists[0].profileImage);
    // print('helllooooooooo');
    //
    // final artist = artists.firstWhere(
    //       (e) => e.name == item.name,
    //   orElse: () => SalonArtiestListModel(),
    // );

    final imageUrl = item.profileImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
        "${APIConstants.image}${imageUrl}",
        width: 25,
        height: 30,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      )
          : _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.person, size: 16, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.72,
      width: Get.width,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          return
            Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    Center(
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                                  colors: [
                                    Color(0xFF8565D0),
                                    Color(0xFFCD73B4),
                                  ],
                                ).createShader(bounds),
                            child: const Text(
                              "We Need Your Help!",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "How Was Your Experience ?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xCC8565D0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Share Your opinion!",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Salon : ",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: changeTheme(
                                        SharedPrefs.readStringValue(PrefConstants.gender)),
                                  ),
                                ),
                                TextSpan(
                                  text: salonName,
                                  style: const TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        buildSalonStars(),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          chip("Good Ambience"),
                          const SizedBox(width: 8),
                          chip("Quality Products"),
                          const SizedBox(width: 8),
                          chip("Parking"),
                          const SizedBox(width: 8),
                          chip("Hygienic"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    outlineButton("Write A Review", () {
                      openReviewInput(isSalon: true);
                    }),

                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// FIRST ROW (WITH LABEL)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// LEFT: STYLIST LABEL
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                "Stylist :",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: changeTheme(
                                      SharedPrefs.readStringValue(PrefConstants.gender)),
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            /// RIGHT SIDE
                            Expanded(
                              child: Column(
                                children: reviewItems.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  ReviewItem item = entry.value;

                                  // return Padding(
                                  //   padding: const EdgeInsets.only(top: 1),
                                  //   child: Row(
                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                  //     children: [
                                  //       /// 🔥 MINUS BUTTON (ONLY FOR INDEX > 0)
                                  //       if (index > 0)
                                  //         GestureDetector(
                                  //           onTap: () {
                                  //             setState(() {
                                  //               reviewItems.removeAt(index);
                                  //             });
                                  //           },
                                  //           child: Container(
                                  //             width: 22,
                                  //             height: 22,
                                  //             decoration: const BoxDecoration(
                                  //               color: Colors.red,
                                  //               shape: BoxShape.circle,
                                  //             ),
                                  //             child: const Icon(
                                  //               Icons.remove,
                                  //               size: 14,
                                  //               color: Colors.white,
                                  //             ),
                                  //           ),
                                  //         )
                                  //       else
                                  //         const SizedBox(width: 22), // keep alignment same
                                  //
                                  //       const SizedBox(width: 4),
                                  //
                                  //       /// PROFILE CARD
                                  //       Container(
                                  //         width: 136,
                                  //         height: 37,
                                  //         padding: const EdgeInsets.symmetric(
                                  //             horizontal: 2, vertical: 4),
                                  //         decoration: BoxDecoration(
                                  //           color: Colors.white,
                                  //           borderRadius: BorderRadius.circular(10),
                                  //           border:
                                  //           Border.all(color: const Color(0xFF8565D0)),
                                  //         ),
                                  //         child: Row(
                                  //           //crossAxisAlignment: CrossAxisAlignment.start,
                                  //           children: [
                                  //
                                  //             /// 🔥 LEFT - IMAGE
                                  //             buildStylistImage(item),
                                  //
                                  //             const SizedBox(width: 6),
                                  //
                                  //             /// 🔥 CENTER - NAME (EXPANDED)
                                  //             Expanded(
                                  //               child: Text(
                                  //                 item.name,
                                  //                 maxLines: 1,
                                  //                 overflow: TextOverflow.ellipsis, // ✅ ...
                                  //                 textAlign: TextAlign.center,     // ✅ center align
                                  //                 style: const TextStyle(
                                  //                   fontFamily: "Outfit",
                                  //                   fontSize: 16,
                                  //                   fontWeight: FontWeight.w700,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //
                                  //             const SizedBox(width: 6),
                                  //
                                  //             /// 🔥 RIGHT - EDIT BUTTON
                                  //             GestureDetector(
                                  //                 onTap: () {
                                  //                   openStylistSelector(item: item);
                                  //                 },
                                  //               child: Container(
                                  //                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  //                 decoration: BoxDecoration(
                                  //                   color: Colors.green,
                                  //                   borderRadius: BorderRadius.circular(10),
                                  //                 ),
                                  //                 child: const Text(
                                  //                   "Edit",
                                  //                   style: TextStyle(
                                  //                     fontSize: 10,
                                  //                     color: Colors.white,
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //
                                  //       const SizedBox(width:2.5),
                                  //
                                  //       /// STARS + BUTTON
                                  //   Padding(
                                  //     padding: EdgeInsets.only(top: 1),
                                  //       child: Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.center,
                                  //         children: [
                                  //
                                  //           /// STARS
                                  //           buildStars(item),
                                  //
                                  //           const SizedBox(height: 6),
                                  //
                                  //           /// BUTTON
                                  //           // outlineButton("Write A Review", () {
                                  //           //   openReviewInput(item: item);
                                  //           // }),
                                  //           Align(
                                  //             alignment: Alignment.centerRight,
                                  //             child: outlineButton("Write A Review", () {
                                  //               openReviewInput(item: item);
                                  //             }),
                                  //           ),
                                  //         ],
                                  //       )),
                                  //     ],
                                  //   ),
                                  // );
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [

                                        /// 🔥 ROW 1 → PROFILE + STARS
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            /// PROFILE CARD
                                            Container(
                                              width: 136,
                                              height: 37,
                                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0xFF8565D0)),
                                              ),
                                              child: Row(
                                                children: [

                                                  buildStylistImage(item),
                                                  const SizedBox(width: 6),

                                                  Expanded(
                                                    child: Text(
                                                      item.name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily: "Outfit",
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 6),

                                                  GestureDetector(
                                                    onTap: () {
                                                      openStylistSelector(item: item);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: const Text(
                                                        "Edit",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 5),

                                            /// STARS
                                            buildStars(item),
                                          ],
                                        ),

                                        //const SizedBox(height: 6),

                                        /// 🔥 ROW 2 → REMOVE (LEFT) + REVIEW (RIGHT)
                                        Row(
                                          children: [

                                            /// REMOVE BUTTON (only for index > 0)
                                            if (index > 0)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    reviewItems.removeAt(index);
                                                  });
                                                },
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.remove_circle, color: Colors.red, size: 16),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              const SizedBox(), // empty for first row

                                            const Spacer(),

                                            /// WRITE REVIEW (RIGHT)
                                            outlineButton("Write A Review", () {
                                              openReviewInput(item: item);
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Positioned(
              //   bottom: 0.5,
              //   left: 20,
              //   right: 20,
              //   child: Center(
              //     child: GestureDetector(
              //       onTap: () async {
              //
              //         if (salonRating == 0) {
              //           SnackbarUtil.show("Error", "Please rate the salon");
              //           return;
              //         }
              //
              //         if (reviewItems.any((item) => item.rating == 0)) {
              //           SnackbarUtil.show("Error", "Please rate all stylists");
              //           return;
              //         }
              //
              //         if (_submitted) return;
              //
              //         _submitted = true;
              //
              //         bool uploadSuccess = true;
              //
              //         /// 🔥 STEP 1: UPLOAD ALL IMAGES FIRST
              //         for (final item in reviewItems) {
              //           if (item.images.isNotEmpty) {
              //             try {
              //               await _homeController.doUploadImage(
              //                 appointmentId: widget.appointmentId,
              //                 multiplePath: item.images,
              //                 multiplePathVideo: [],
              //                 callback: () {
              //                   print("Uploaded images for ${item.name}");
              //                 },
              //               );
              //             } catch (e) {
              //               uploadSuccess = false;
              //               break;
              //             }
              //           }
              //         }
              //
              //         if (!uploadSuccess) {
              //           SnackbarUtil.show("Error", "Image upload failed");
              //           return;
              //         }
              //
              //         /// 🔥 STEP 2: SUBMIT REVIEWS
              //         final success = await submitAllReviews();
              //
              //         if (success) {
              //
              //           /// 🔥 CLOSE BOTTOM SHEET
              //           Navigator.pop(context);
              //
              //           /// 🔥 GO BACK TO HOME (SAFE)
              //           Get.until((route) => route.isFirst);
              //
              //           /// OR (better if you have named route)
              //           // Get.offAllNamed(Routes.HOME);
              //
              //         } else {
              //           _submitted = false; // allow retry
              //         }
              //       },
              //       child: Container(
              //         width: 100,
              //         height: 34,
              //         alignment: Alignment.center,
              //         decoration: BoxDecoration(
              //           color: const Color(0xFF8565D0),
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         child: const Text(
              //           "Submit",
              //           style: TextStyle(
              //             fontFamily: "Outfit",
              //             fontSize: 16,
              //             fontWeight: FontWeight.w700,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              Positioned(
                bottom: 5,
                left: 20,
                right: 20,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// 🔥 ADD BUTTON (FIRST)
                      if (reviewItems.length < 3)
                        GestureDetector(
                          onTap: () {
                            openStylistSelector(); // reuse function
                          },
                          child: Container(
                            width: 90,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Add Stylist",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),


                      if (reviewItems.length < 3)
                        const SizedBox(height: 10),
                      const SizedBox(height: 5),

                      /// 🔥 SUBMIT BUTTON (SECOND)
                      GestureDetector(
                        onTap: () async {

                          print("---- REVIEW DEBUG ----");
                          print("TOTAL STYLISTS: ${reviewItems.length}");

                          for (var item in reviewItems) {
                            print("ID: ${item.id}, Name: ${item.name}, Rating: ${item.rating}");
                          }

                          print("----------------------");

                          if (salonRating == 0) {
                            _showValidationError("Please rate the salon to continue");
                            return;
                          }

                          if (reviewItems.any((item) => item.rating == 0)) {
                            _showValidationError("Please rate all the stylists to continue");
                            return;
                          }

                          if (_submitted) return;

                          _submitted = true;

                          bool uploadSuccess = true;

                          /// 🔥 STEP 1: UPLOAD ALL IMAGES FIRST
                          for (final item in reviewItems) {
                            if (item.images.isNotEmpty) {
                              try {
                                await _homeController.doUploadImage(
                                  appointmentId: widget.appointmentId,
                                  multiplePath: item.images,
                                  multiplePathVideo: [],
                                  callback: () {
                                    print("Uploaded images for ${item.name}");
                                  },
                                );
                              } catch (e) {
                                uploadSuccess = false;
                                break;
                              }
                            }
                          }

                          if (!uploadSuccess) {
                            SnackbarUtil.show("Error", "Image upload failed");
                            return;
                          }

                          /// 🔥 STEP 2: SUBMIT REVIEWS
                          final success = await submitAllReviews();

                          if (success) {

                            /// 🔥 CLOSE BOTTOM SHEET
                            Navigator.pop(context);

                            /// 🔥 GO BACK TO HOME (SAFE)
                            //Get.until((route) => route.isFirst);

                            /// OR (better if you have named route)
                            // Get.offAllNamed(Routes.HOME);

                          } else {
                            _submitted = false; // allow retry
                          }
                        },

                        child: Container(
                          width: 200,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8565D0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_homeController.isSubmittingReview.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
  void _showValidationError(String message) {
    // Add haptic feedback for a physical cue
    HapticFeedback.vibrate();

    SnackbarUtil.show(
      "Attention",
      "",
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500, // Medium
          color: Colors.white,
        ),
      ),
      snackPosition: SnackPosition.TOP, // Top is often more visible than bottom
      backgroundColor: Colors.redAccent.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack, // Subtle "pop" effect
    );
  }
  void openStylistSelector({ReviewItem? item}) {
    final artists = _homeController.getSalonDetailsArtiestData.data ?? [];

    /// ❌ FILTER LOGIC
    final filteredArtists = artists.where((artist) {
      if (item != null) {
        /// EDIT → exclude current item
        return artist.id != item.id;
      } else {
        /// ADD → exclude already selected
        return !reviewItems.any((i) => i.id == artist.id);
      }
    }).toList();

    String? selectedId = item?.id;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Center(
                child: Text(
                  "Select Stylist",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredArtists.length,
                  itemBuilder: (context, index) {
                    final artist = filteredArtists[index];

                    return RadioListTile<String>(
                      value: artist.id ?? "",
                      groupValue: selectedId,
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedId = val;
                        });
                      },
                      title: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: (artist.profileImage != null &&
                                artist.profileImage!.isNotEmpty)
                                ? Image.network(
                              "${APIConstants.image}${artist.profileImage}",
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 30,
                              height: 30,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            artist.name ?? "",
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender),
                    ),
                  ),
                  onPressed: () {
                    if (selectedId != null) {
                      final selectedArtist = artists.firstWhere(
                            (e) => e.id == selectedId,
                      );

                      setState(() {
                        if (item != null) {
                          /// 🔥 EDIT
                          item.id = selectedArtist.id ?? "";
                          item.name = selectedArtist.name ?? "";
                        } else {
                          /// 🔥 ADD
                          reviewItems.add(
                            ReviewItem(
                              id: selectedArtist.id ?? "",
                              type: "artist",
                              name: selectedArtist.name ?? "",
                            ),
                          );
                        }
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}