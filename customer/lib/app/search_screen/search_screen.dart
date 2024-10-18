import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/search_controller.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/restaurant_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SearchScreenController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Search Food & Restaurant".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFieldWidget(
                    hintText: 'Search the dish, restaurant, food, meals'.tr,
                    prefix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SvgPicture.asset("assets/icons/ic_search.svg"),
                    ),
                    controller: null,
                    onchange: (value) {
                      controller.onSearchTextChanged(value);
                    },
                  ),
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.vendorSearchList.isEmpty
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Restaurants".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(),
                                    ),
                                  ],
                                ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.vendorSearchList.length,
                            itemBuilder: (context, index) {
                              VendorModel vendorModel = controller.vendorSearchList[index];
                              return InkWell(
                                onTap: () {
                                  Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
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
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
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
                          controller.productSearchList.isEmpty
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Foods".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(),
                                    ),
                                  ],
                                ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.productSearchList.length,
                            itemBuilder: (context, index) {
                              ProductModel productModel = controller.productSearchList[index];
                              String price = "0.0";
                              String disPrice = "0.0";
                              List<String> selectedVariants = [];
                              List<String> selectedIndexVariants = [];
                              List<String> selectedIndexArray = [];
                              if (productModel.itemAttribute != null) {
                                if (productModel.itemAttribute!.attributes!.isNotEmpty) {
                                  for (var element in productModel.itemAttribute!.attributes!) {
                                    if (element.attributeOptions!.isNotEmpty) {
                                      selectedVariants
                                          .add(productModel.itemAttribute!.attributes![productModel.itemAttribute!.attributes!.indexOf(element)].attributeOptions![0].toString());
                                      selectedIndexVariants.add(
                                          '${productModel.itemAttribute!.attributes!.indexOf(element)} _${productModel.itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                                      selectedIndexArray.add('${productModel.itemAttribute!.attributes!.indexOf(element)}_0');
                                    }
                                  }
                                }
                                if (productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty) {
                                  price = Constant.productCommissionPrice(
                                      productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantPrice ?? '0');
                                  disPrice = Constant.productCommissionPrice('0');
                                }
                              } else {
                                price = Constant.productCommissionPrice(productModel.price.toString());
                                disPrice = "0";
                              }
                              return InkWell(
                                onTap: () async {
                                  await FireStoreUtils.getVendorById(productModel.vendorID.toString()).then(
                                    (value) {
                                      if (value != null) {
                                        Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": value});
                                      }
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
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
                                                productModel.nonveg == true ? SvgPicture.asset("assets/icons/ic_nonveg.svg") : SvgPicture.asset("assets/icons/ic_veg.svg"),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  productModel.nonveg == true ? "Non Veg.".tr : "Pure veg.".tr,
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
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
