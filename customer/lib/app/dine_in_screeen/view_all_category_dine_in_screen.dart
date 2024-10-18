import 'package:customer/app/home_screen/category_restaurant_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/view_all_category_controller.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ViewAllCategoryDineInScreen extends StatelessWidget {
  const ViewAllCategoryDineInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ViewAllCategoryController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Categories".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontFamily: AppThemeData.medium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 3.5 / 6, crossAxisSpacing: 6),
                      itemCount: controller.vendorCategoryModel.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        VendorCategoryModel vendorCategoryModel = controller.vendorCategoryModel[index];
                        return InkWell(
                          onTap: () {
                            Get.to(const CategoryRestaurantScreen(), arguments: {"vendorCategoryModel": vendorCategoryModel, "dineIn": true});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: ClipOval(
                                      child: NetworkImageWidget(
                                        imageUrl: vendorCategoryModel.photo.toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Text(
                                      '${vendorCategoryModel.title}',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                        fontFamily: AppThemeData.medium,
                                      ),
                                    ),
                                  )
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
