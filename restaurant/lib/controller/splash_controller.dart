import 'dart:async';
import 'dart:developer';

import 'package:restaurant/app/auth_screen/login_screen.dart';
import 'package:restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant/app/on_boarding_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/notification_service.dart';
import 'package:restaurant/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  redirectScreen() async {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreen());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
          if (value != null) {
            UserModel userModel = value;
            log(userModel.toJson().toString());
            if (userModel.role == Constant.userRoleVendor) {
              if (userModel.active == true) {
                userModel.fcmToken = await NotificationService.getToken();
                await FireStoreUtils.updateUser(userModel);
                Get.offAll(const DashBoardScreen());
              } else {
                await FirebaseAuth.instance.signOut();
                Get.offAll(const LoginScreen());
              }
            } else {
              await FirebaseAuth.instance.signOut();
              Get.offAll(const LoginScreen());
            }
          }
        });
      } else {
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      }
    }
  }
}
