import 'package:customer/app/dine_in_screeen/dine_in_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/restaurant_list_controller.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/restaurant_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DineInRestaurantListScreen extends StatelessWidget {
  const DineInRestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RestaurantListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                controller.title.value,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.vendorSearchList.length,
                      itemBuilder: (context, index) {
                        VendorModel vendorModel = controller.vendorSearchList[index];
                        return InkWell(
                          onTap: () {
                            Get.to(const DineInDetailsScreen(), arguments: {"vendorModel": vendorModel});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16),topRight:  Radius.circular(16)),
                                        child: Stack(
                                          children: [
                                            RestaurantImageView(
                                              vendorModel: vendorModel,
                                            ),
                                            Container(
                                              height: Responsive.height(20, context),
                                              width: Responsive.width(100, context),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: const Alignment(-0.00, -1.00),
                                                  end: const Alignment(0, 1),
                                                  colors: [Colors.black.withOpacity(0), const Color(0xFF111827)],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              top: 10,
                                              child: InkWell(
                                                onTap: () async {
                                                  if (controller.favouriteList.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty) {
                                                    FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                                    controller.favouriteList.removeWhere((item) => item.restaurantId == vendorModel.id);
                                                    await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                                                  } else {
                                                    FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                                    controller.favouriteList.add(favouriteModel);
                                                    await FireStoreUtils.setFavouriteRestaurant(favouriteModel);
                                                  }
                                                },
                                                child: Obx(
                                                      () => controller.favouriteList.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty
                                                      ? SvgPicture.asset(
                                                    "assets/icons/ic_like_fill.svg",
                                                  )
                                                      : SvgPicture.asset(
                                                    "assets/icons/ic_like.svg",
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Transform.translate(
                                         offset: Offset(Responsive.width(-3, context), Responsive.height(17.5, context)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: ShapeDecoration(
                                                color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_star.svg",
                                                      colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount!.toStringAsFixed(0), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                        fontFamily: AppThemeData.semiBold,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              decoration: ShapeDecoration(
                                                color: themeChange.getThem() ? AppThemeData.secondary600 : AppThemeData.secondary50,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_map_distance.svg",
                                                      colorFilter: const ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "${Constant.getDistance(
                                                        lat1: vendorModel.latitude.toString(),
                                                        lng1: vendorModel.longitude.toString(),
                                                        lat2: Constant.selectedLocation.location!.latitude.toString(),
                                                        lng2: Constant.selectedLocation.location!.longitude.toString(),
                                                      )} ${Constant.distanceType}",
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                                        fontFamily: AppThemeData.semiBold,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vendorModel.title.toString(),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          ),
                                        ),
                                        Text(
                                          vendorModel.location.toString(),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: AppThemeData.medium,
                                            fontWeight: FontWeight.w500,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey400,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          );
        });
  }
}
