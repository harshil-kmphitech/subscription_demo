import 'package:subscription_demo/helpers/all.dart';

Utils utils = Utils();

class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://hexanetwork.in:3035/api/';
  static const int timeoutDuration = 10000;
  static const bool enableLogging = true;
}

class EndPoints {
  EndPoints._();

  // API's endpoints
  static const authLogin = "auth/login";

  static const String refreshToken = "refreshToken";

  // In-App Purchase
  static const inapppurchaseAndroidPlanPurchase = "inapppurchase/androidPlanPurchase";
  static const inapppurchaseAndroidPlanRestore = "inapppurchase/androidPlanRestore";
  static const inapppurchaseApplePlanPurchase = "inapppurchase/applePlanPurchase";
  static const inapppurchaseApplePlanRestore = "inapppurchase/applePlanRestore";
  static const inapppurchaseCheckUserPlan = "inapppurchase/checkUserPlan";
}

class KeyName {
  KeyName._();

  static const token = "token";
}
