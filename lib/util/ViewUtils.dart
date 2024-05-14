import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pagination_view/pagination_view.dart';

class ViewUtils {
  static Widget pagingAPIErrorWidget({
    GlobalKey<PaginationViewState>? pagingKey,
  }) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(
            'Something Went Wrong',
            style: Get.textTheme.titleSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
