import 'package:customer/app/chat_screens/chat_screen.dart';
import 'package:customer/app/order_list_screen/live_tracking_screen.dart';
import 'package:customer/app/rate_us_screen/rate_product_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/order_details_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OrderDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Order Details".tr,
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ${Constant.orderId(orderId: controller.orderModel.value.id.toString())}".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 18,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RoundedButtonFill(
                                title: controller.orderModel.value.status.toString().tr,
                                color: Constant.statusColor(status: controller.orderModel.value.status.toString()),
                                width: 32,
                                height: 4.5,
                                radius: 10,
                                textColor: Constant.statusText(status: controller.orderModel.value.status.toString()),
                                onPress: () async {},
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          controller.orderModel.value.takeAway == true
                              ? Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${controller.orderModel.value.vendor!.title}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.semiBold,
                                                  fontSize: 16,
                                                  color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                ),
                                              ),
                                              Text(
                                                "${controller.orderModel.value.vendor!.location}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.medium,
                                                  fontSize: 14,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.orderModel.value.status == Constant.orderPlaced ||
                                                controller.orderModel.value.status == Constant.orderRejected ||
                                                controller.orderModel.value.status == Constant.orderCompleted
                                            ? const SizedBox()
                                            : InkWell(
                                                onTap: () {
                                                  Constant.makePhoneCall(controller.orderModel.value.vendor!.phonenumber.toString());
                                                },
                                                child: Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(120),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        controller.orderModel.value.status == Constant.orderPlaced ||
                                                controller.orderModel.value.status == Constant.orderRejected ||
                                                controller.orderModel.value.status == Constant.orderCompleted
                                            ? const SizedBox()
                                            : InkWell(
                                                onTap: () async {
                                                  ShowToastDialog.showLoader("Please wait".tr);

                                                  UserModel? customer = await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                  UserModel? restaurantUser = await FireStoreUtils.getUserProfile(controller.orderModel.value.vendor!.author.toString());
                                                  VendorModel? vendorModel = await FireStoreUtils.getVendorById(restaurantUser!.vendorID.toString());
                                                  ShowToastDialog.closeLoader();

                                                  Get.to(const ChatScreen(), arguments: {
                                                    "customerName": '${customer!.fullName()}',
                                                    "restaurantName": vendorModel!.title,
                                                    "orderId": controller.orderModel.value.id,
                                                    "restaurantId": restaurantUser.id,
                                                    "customerId": customer.id,
                                                    "customerProfileImage": customer.profilePictureURL,
                                                    "restaurantProfileImage": vendorModel.photo,
                                                    "token": restaurantUser.fcmToken,
                                                    "chatType": "restaurant",
                                                  });
                                                },
                                                child: Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(120),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      children: [
                                        Timeline.tileBuilder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics: const NeverScrollableScrollPhysics(),
                                          theme: TimelineThemeData(
                                            nodePosition: 0,
                                            // indicatorPosition: 0,
                                          ),
                                          builder: TimelineTileBuilder.connected(
                                            contentsAlign: ContentsAlign.basic,
                                            indicatorBuilder: (context, index) {
                                              return SvgPicture.asset("assets/icons/ic_location.svg");
                                            },
                                            connectorBuilder: (context, index, connectorType) {
                                              return const DashedLineConnector(
                                                color: AppThemeData.grey300,
                                                gap: 3,
                                              );
                                            },
                                            contentsBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: index == 0
                                                    ? Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "${controller.orderModel.value.vendor!.title}",
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.semiBold,
                                                                    fontSize: 16,
                                                                    color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${controller.orderModel.value.vendor!.location}",
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                        ),
                                                        controller.orderModel.value.status == Constant.orderPlaced ||
                                                            controller.orderModel.value.status == Constant.orderRejected ||
                                                            controller.orderModel.value.status == Constant.orderCompleted
                                                            ? const SizedBox()
                                                            : InkWell(
                                                          onTap: () {
                                                            Constant.makePhoneCall(controller.orderModel.value.vendor!.phonenumber.toString());
                                                          },
                                                          child: Container(
                                                            width: 42,
                                                            height: 42,
                                                            decoration: ShapeDecoration(
                                                              shape: RoundedRectangleBorder(
                                                                side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                borderRadius: BorderRadius.circular(120),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        controller.orderModel.value.status == Constant.orderPlaced ||
                                                            controller.orderModel.value.status == Constant.orderRejected ||
                                                            controller.orderModel.value.status == Constant.orderCompleted
                                                            ? const SizedBox()
                                                            : InkWell(
                                                          onTap: () async {
                                                            ShowToastDialog.showLoader("Please wait".tr);

                                                            UserModel? customer = await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                            UserModel? restaurantUser = await FireStoreUtils.getUserProfile(controller.orderModel.value.vendor!.author.toString());
                                                            VendorModel? vendorModel = await FireStoreUtils.getVendorById(restaurantUser!.vendorID.toString());
                                                            ShowToastDialog.closeLoader();

                                                            Get.to(const ChatScreen(), arguments: {
                                                              "customerName": '${customer!.fullName()}',
                                                              "restaurantName": vendorModel!.title,
                                                              "orderId": controller.orderModel.value.id,
                                                              "restaurantId": restaurantUser.id,
                                                              "customerId": customer.id,
                                                              "customerProfileImage": customer.profilePictureURL,
                                                              "restaurantProfileImage": vendorModel.photo,
                                                              "token": restaurantUser.fcmToken,
                                                              "chatType": "restaurant",
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 42,
                                                            height: 42,
                                                            decoration: ShapeDecoration(
                                                              shape: RoundedRectangleBorder(
                                                                side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                borderRadius: BorderRadius.circular(120),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                    : Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${controller.orderModel.value.address!.addressAs}",
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.semiBold,
                                                              fontSize: 16,
                                                              color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                            ),
                                                          ),
                                                          Text(
                                                            controller.orderModel.value.address!.getFullAddress(),
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.medium,
                                                              fontSize: 14,
                                                              color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              );
                                            },
                                            itemCount: 2,
                                          ),
                                        ),
                                        controller.orderModel.value.status == Constant.orderRejected
                                            ? const SizedBox()
                                            : Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                    child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                  ),
                                                  controller.orderModel.value.status == Constant.orderCompleted
                                                      ? Row(
                                                          children: [
                                                            SvgPicture.asset("assets/icons/ic_check_small.svg"),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              controller.orderModel.value.driver!.fullName(),
                                                              textAlign: TextAlign.right,
                                                              style: TextStyle(
                                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                fontFamily: AppThemeData.semiBold,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Order Delivered.".tr,
                                                              textAlign: TextAlign.right,
                                                              style: TextStyle(
                                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                fontFamily: AppThemeData.regular,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : controller.orderModel.value.status == Constant.orderAccepted || controller.orderModel.value.status == Constant.driverPending
                                                          ? Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SvgPicture.asset("assets/icons/ic_timer.svg"),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    "Your Order has been Preparing and assign to the driver".tr,
                                                                    textAlign: TextAlign.start,
                                                                    style: TextStyle(
                                                                      color: themeChange.getThem() ? AppThemeData.warning400 : AppThemeData.warning400,
                                                                      fontFamily: AppThemeData.semiBold,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : controller.orderModel.value.driver != null
                                                              ? Row(
                                                                  children: [
                                                                    ClipOval(
                                                                      child: NetworkImageWidget(
                                                                        imageUrl: controller.orderModel.value.author!.profilePictureURL.toString(),
                                                                        fit: BoxFit.cover,
                                                                        height: Responsive.height(5, context),
                                                                        width: Responsive.width(10, context),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            controller.orderModel.value.driver!.fullName().toString(),
                                                                            textAlign: TextAlign.start,
                                                                            style: TextStyle(
                                                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                              fontFamily: AppThemeData.semiBold,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            controller.orderModel.value.driver!.email.toString(),
                                                                            textAlign: TextAlign.start,
                                                                            style: TextStyle(
                                                                              color: themeChange.getThem() ? AppThemeData.success400 : AppThemeData.success400,
                                                                              fontFamily: AppThemeData.regular,
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        Constant.makePhoneCall(controller.orderModel.value.vendor!.phonenumber.toString());
                                                                      },
                                                                      child: Container(
                                                                        width: 42,
                                                                        height: 42,
                                                                        decoration: ShapeDecoration(
                                                                          shape: RoundedRectangleBorder(
                                                                            side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                            borderRadius: BorderRadius.circular(120),
                                                                          ),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () async {
                                                                        ShowToastDialog.showLoader("Please wait".tr);

                                                                        UserModel? customer = await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                                        UserModel? restaurantUser =
                                                                            await FireStoreUtils.getUserProfile(controller.orderModel.value.driverID.toString());

                                                                        ShowToastDialog.closeLoader();

                                                                        Get.to(const ChatScreen(), arguments: {
                                                                          "customerName": '${customer!.fullName()}',
                                                                          "restaurantName": restaurantUser!.fullName(),
                                                                          "orderId": controller.orderModel.value.id,
                                                                          "restaurantId": restaurantUser.id,
                                                                          "customerId": customer.id,
                                                                          "customerProfileImage": customer.profilePictureURL,
                                                                          "restaurantProfileImage": restaurantUser.profilePictureURL,
                                                                          "token": restaurantUser.fcmToken,
                                                                          "chatType": "Driver",
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        width: 42,
                                                                        height: 42,
                                                                        decoration: ShapeDecoration(
                                                                          shape: RoundedRectangleBorder(
                                                                            side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                            borderRadius: BorderRadius.circular(120),
                                                                          ),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              : const SizedBox(),
                                                ],
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            "Your Order".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: controller.orderModel.value.products!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  CartProductModel cartProductModel = controller.orderModel.value.products![index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(14)),
                                            child: Stack(
                                              children: [
                                                NetworkImageWidget(
                                                  imageUrl: cartProductModel.photo.toString(),
                                                  height: Responsive.height(8, context),
                                                  width: Responsive.width(16, context),
                                                  fit: BoxFit.cover,
                                                ),
                                                Container(
                                                  height: Responsive.height(8, context),
                                                  width: Responsive.width(16, context),
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
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "${cartProductModel.name}",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.regular,
                                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "x ${cartProductModel.quantity}",
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                double.parse(cartProductModel.discountPrice == null || cartProductModel.discountPrice!.isEmpty
                                                            ? "0.0"
                                                            : cartProductModel.discountPrice.toString()) <=
                                                        0
                                                    ? Text(
                                                        Constant.amountShow(amount: cartProductModel.price),
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
                                                            Constant.amountShow(amount: cartProductModel.discountPrice.toString()),
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
                                                            Constant.amountShow(amount: cartProductModel.price),
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
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: RoundedButtonFill(
                                                    title: "Rate us".tr,
                                                    height: 3.8,
                                                    width: 20,
                                                    color: themeChange.getThem() ? AppThemeData.warning300 : AppThemeData.warning300,
                                                    textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                    onPress: () async {
                                                      Get.to(const RateProductScreen(), arguments: {"orderModel": controller.orderModel.value, "productId": cartProductModel.id});
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      cartProductModel.variantInfo == null || cartProductModel.variantInfo!.variantOptions!.isEmpty
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Variants",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.semiBold,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Wrap(
                                                    spacing: 6.0,
                                                    runSpacing: 6.0,
                                                    children: List.generate(
                                                      cartProductModel.variantInfo!.variantOptions!.length,
                                                      (i) {
                                                        return Container(
                                                          decoration: ShapeDecoration(
                                                            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                                            child: Text(
                                                              "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                fontFamily: AppThemeData.medium,
                                                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      cartProductModel.extras == null || cartProductModel.extras!.isEmpty
                                          ? const SizedBox()
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Addons",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.semiBold,
                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      Constant.amountShow(
                                                          amount: (double.parse(cartProductModel.extrasPrice.toString()) * double.parse(cartProductModel.quantity.toString()))
                                                              .toString()),
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.semiBold,
                                                        color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Wrap(
                                                  spacing: 6.0,
                                                  runSpacing: 6.0,
                                                  children: List.generate(
                                                    cartProductModel.extras!.length,
                                                    (i) {
                                                      return Container(
                                                        decoration: ShapeDecoration(
                                                          color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                                          child: Text(
                                                            cartProductModel.extras![i].toString(),
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.medium,
                                                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                ),
                                              ],
                                            ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            "Bill Details".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Item totals".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: controller.subTotal.value.toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.orderModel.value.takeAway == true
                                      ? const SizedBox()
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Delivery Fee".tr,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.regular,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                  amount: controller.orderModel.value.deliveryCharge == null || controller.orderModel.value.deliveryCharge!.isEmpty
                                                      ? "0.0"
                                                      : controller.orderModel.value.deliveryCharge.toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Coupon Discount".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "- (${Constant.amountShow(amount: controller.orderModel.value.discount.toString())})",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  controller.orderModel.value.specialDiscount != null && controller.orderModel.value.specialDiscount!['special_discount'] != null
                                      ? Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Special Discount".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.regular,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "- (${Constant.amountShow(amount: controller.specialDiscountAmount.value.toString())})",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.orderModel.value.takeAway == true
                                      ? const SizedBox()
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Delivery Tips".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.regular,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.orderModel.value.tipAmount.toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    itemCount: controller.orderModel.value.taxSetting!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      TaxModel taxModel = controller.orderModel.value.taxSetting![index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.regular,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                  amount: Constant.calculateTax(
                                                          amount: (controller.subTotal.value -
                                                                  double.parse(controller.orderModel.value.discount.toString()) -
                                                                  controller.specialDiscountAmount.value)
                                                              .toString(),
                                                          taxModel: taxModel)
                                                      .toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "To Pay".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: controller.totalAmount.value.toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            "Order Details".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Delivery type".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.orderModel.value.takeAway == true
                                            ? "TakeAway".tr
                                            : controller.orderModel.value.scheduleTime == null
                                                ? "Standard".tr
                                                : "Schedule".tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          color: controller.orderModel.value.scheduleTime != null
                                              ? AppThemeData.primary300
                                              : themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Payment Method".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.orderModel.value.paymentMethod.toString(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Date and Time".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.timestampToDateTime(controller.orderModel.value.createdAt!),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Phone Number".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        controller.orderModel.value.author!.phoneNumber.toString(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          controller.orderModel.value.notes == null || controller.orderModel.value.notes!.isEmpty
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Remarks".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                        child: Text(
                                          controller.orderModel.value.notes.toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: controller.orderModel.value.status == Constant.orderShipped ||
                    controller.orderModel.value.status == Constant.orderInTransit ||
                    controller.orderModel.value.status == Constant.orderCompleted
                ? Container(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: controller.orderModel.value.status == Constant.orderShipped || controller.orderModel.value.status == Constant.orderInTransit
                          ? RoundedButtonFill(
                              title: "Track Order".tr,
                              height: 5.5,
                              color: AppThemeData.warning300,
                              textColor: AppThemeData.grey900,
                              onPress: () async {
                                Get.to(const LiveTrackingScreen(), arguments: {"orderModel": controller.orderModel.value});
                              },
                            )
                          : RoundedButtonFill(
                              title: "Reorder".tr,
                              height: 5.5,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                for (var element in controller.orderModel.value.products!) {
                                  controller.addToCart(cartProductModel: element);
                                  ShowToastDialog.showToast("Item Added In a cart");
                                }
                              },
                            ),
                    ),
                  )
                : const SizedBox(),
          );
        });
  }
}
