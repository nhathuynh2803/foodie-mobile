import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/favourite_controller.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/restaurant_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: FavouriteController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Your Favourites, All in One Place".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SvgPicture.asset("assets/images/ic_favourite.svg")
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Constant.userModel == null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset("assets/images/login.gif",height: 120,),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        "Please Log In to Continue".tr,
                                        style:
                                            TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "You’re not logged in. Please sign in to access your account and explore all features.".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      RoundedButtonFill(
                                        title: "Log in".tr,
                                        width: 55,
                                        height: 5.5,
                                        color: AppThemeData.primary300,
                                        textColor: AppThemeData.grey50,
                                        onPress: () async {
                                          Get.offAll(const LoginScreen());
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(120),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.favouriteRestaurant.value = true;
                                                  },
                                                  child: Container(
                                                    decoration: controller.favouriteRestaurant.value == false
                                                        ? null
                                                        : ShapeDecoration(
                                                            color: AppThemeData.grey900,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(120),
                                                            ),
                                                          ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                      child: Text(
                                                        "Favourite Restaurants".tr,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.semiBold,
                                                          color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.favouriteRestaurant.value = false;
                                                  },
                                                  child: Container(
                                                    decoration: controller.favouriteRestaurant.value == true
                                                        ? null
                                                        : ShapeDecoration(
                                                            color: AppThemeData.grey900,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(120),
                                                            ),
                                                          ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                      child: Text(
                                                        "Favourite Foods".tr,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.semiBold,
                                                          color: controller.favouriteRestaurant.value == true
                                                              ? themeChange.getThem()
                                                                  ? AppThemeData.grey400
                                                                  : AppThemeData.grey500
                                                              : themeChange.getThem()
                                                                  ? AppThemeData.primary300
                                                                  : AppThemeData.primary300,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18),
                                        child: controller.favouriteRestaurant.value
                                            ? controller.favouriteVendorList.isEmpty
                                                ? Constant.showEmptyView(message: "Favourite Restaurants not found.")
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: controller.favouriteVendorList.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      VendorModel vendorModel = controller.favouriteVendorList[index];
                                                      return InkWell(
                                                        onTap: () {
                                                          if (vendorModel.zoneId == Constant.selectedZone!.id) {
                                                            ShowToastDialog.closeLoader();
                                                            Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
                                                          } else {
                                                            ShowToastDialog.closeLoader();
                                                            ShowToastDialog.showToast("Sorry, The Zone is not available in your area. change the other location first.");
                                                          }
                                                          // Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
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
                                                                                  FavouriteModel favouriteModel =
                                                                                      FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                                                                  controller.favouriteList.removeWhere((item) => item.restaurantId == vendorModel.id);
                                                                                  controller.favouriteVendorList.removeAt(index);
                                                                                  await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                                                                                } else {
                                                                                  FavouriteModel favouriteModel =
                                                                                      FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
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
                                                                              color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
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
                                                  )
                                            : controller.favouriteFoodList.isEmpty
                                                ? Constant.showEmptyView(message: "Favourite Foods not found.")
                                                : ListView.builder(
                                                    itemCount: controller.favouriteFoodList.length,
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (context, index) {
                                                      ProductModel productModel = controller.favouriteFoodList[index];
                                                      String price = "0.0";
                                                      String disPrice = "0.0";
                                                      List<String> selectedVariants = [];
                                                      List<String> selectedIndexVariants = [];
                                                      List<String> selectedIndexArray = [];
                                                      if (productModel.itemAttribute != null) {
                                                        if (productModel.itemAttribute!.attributes!.isNotEmpty) {
                                                          for (var element in productModel.itemAttribute!.attributes!) {
                                                            if (element.attributeOptions!.isNotEmpty) {
                                                              selectedVariants.add(productModel
                                                                  .itemAttribute!.attributes![productModel.itemAttribute!.attributes!.indexOf(element)].attributeOptions![0]
                                                                  .toString());
                                                              selectedIndexVariants.add(
                                                                  '${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                                                              selectedIndexArray.add('${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                                                            }
                                                          }
                                                        }
                                                        if (productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty) {
                                                          price = Constant.productCommissionPrice(productModel.itemAttribute!.variants!
                                                                  .where((element) => element.variantSku == selectedVariants.join('-'))
                                                                  .first
                                                                  .variantPrice ??
                                                              '0');
                                                          disPrice = '0';
                                                        }
                                                      } else {
                                                        price = Constant.productCommissionPrice(productModel.price.toString());
                                                        disPrice = double.parse(productModel.disPrice.toString()) <= 0 ? "0" : Constant.productCommissionPrice(productModel.disPrice.toString());
                                                      }
                                                      return InkWell(
                                                        onTap: () async {
                                                          await FireStoreUtils.getVendorById(productModel.vendorID.toString()).then(
                                                            (value) {
                                                              if (value != null) {
                                                                if (value.zoneId == Constant.selectedZone!.id) {
                                                                  ShowToastDialog.closeLoader();
                                                                  Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": value});
                                                                } else {
                                                                  ShowToastDialog.closeLoader();
                                                                  ShowToastDialog.showToast("Sorry, The Zone is not available in your area. change the other location first.");
                                                                }

                                                                // Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": value});
                                                              }
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          child: Container(
                                                            decoration: ShapeDecoration(
                                                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 14),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            productModel.nonveg == true
                                                                                ? SvgPicture.asset("assets/icons/ic_nonveg.svg")
                                                                                : SvgPicture.asset("assets/icons/ic_veg.svg"),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text(
                                                                              productModel.nonveg == true ? "Non Veg." : "Pure veg.",
                                                                              style: TextStyle(
                                                                                color: productModel.nonveg == true ? AppThemeData.danger300 : AppThemeData.success400,
                                                                                fontFamily: AppThemeData.semiBold,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text(
                                                                          productModel.name.toString(),
                                                                          style: TextStyle(
                                                                            fontSize: 18,
                                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                            fontFamily: AppThemeData.semiBold,
                                                                            fontWeight: FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        double.parse(disPrice) <= 0
                                                                            ? Text(
                                                                                Constant.amountShow(amount: price),
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                                  fontFamily: AppThemeData.semiBold,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              )
                                                                            : Row(
                                                                                children: [
                                                                                  Text(
                                                                                    Constant.amountShow(amount: disPrice),
                                                                                    style: TextStyle(
                                                                                      fontSize: 16,
                                                                                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                                      fontFamily: AppThemeData.semiBold,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    Constant.amountShow(amount: price),
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      decoration: TextDecoration.lineThrough,
                                                                                      decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                                      color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                                      fontFamily: AppThemeData.semiBold,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                        Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              "assets/icons/ic_star.svg",
                                                                              colorFilter: const ColorFilter.mode(AppThemeData.warning300, BlendMode.srcIn),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text(
                                                                              "${Constant.calculateReview(reviewCount: productModel.reviewsCount!.toStringAsFixed(0), reviewSum: productModel.reviewsSum.toString())} (${productModel.reviewsCount!.toStringAsFixed(0)})",
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                                fontFamily: AppThemeData.regular,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          "${productModel.description}",
                                                                          maxLines: 2,
                                                                          style: TextStyle(
                                                                            overflow: TextOverflow.ellipsis,
                                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                            fontFamily: AppThemeData.regular,
                                                                            fontWeight: FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 6,),
                                                                  ClipRRect(
                                                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                                                    child: Stack(
                                                                      children: [
                                                                        NetworkImageWidget(
                                                                          imageUrl: productModel.photo.toString(),
                                                                          fit: BoxFit.cover,
                                                                          height: Responsive.height(16, context),
                                                                          width: Responsive.width(34, context),
                                                                        ),
                                                                        Container(
                                                                          height: Responsive.height(16, context),
                                                                          width: Responsive.width(34, context),
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
                                                                              if (controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty) {
                                                                                FavouriteItemModel favouriteModel = FavouriteItemModel(
                                                                                    productId: productModel.id, storeId: productModel.vendorID, userId: FireStoreUtils.getCurrentUid());
                                                                                controller.favouriteItemList.removeWhere((item) => item.productId == productModel.id);
                                                                                controller.favouriteFoodList.removeAt(index);
                                                                                await FireStoreUtils.removeFavouriteItem(favouriteModel);
                                                                              } else {
                                                                                FavouriteItemModel favouriteModel = FavouriteItemModel(
                                                                                    productId: productModel.id, storeId: productModel.vendorID, userId: FireStoreUtils.getCurrentUid());
                                                                                controller.favouriteItemList.add(favouriteModel);

                                                                                await FireStoreUtils.setFavouriteItem(favouriteModel);
                                                                              }
                                                                            },
                                                                            child: Obx(
                                                                              () => controller.favouriteItemList.where((p0) => p0.productId == productModel.id).isNotEmpty
                                                                                  ? SvgPicture.asset(
                                                                                      "assets/icons/ic_like_fill.svg",
                                                                                    )
                                                                                  : SvgPicture.asset(
                                                                                      "assets/icons/ic_like.svg",
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
          );
        });
  }
}
