import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import 'package:subscription_demo/helpers/all.dart';
import 'package:subscription_demo/models/authModel/auth_model.dart';
import 'package:subscription_demo/services/auth/auth_service.dart';
import 'package:subscription_demo/services/subscription/subscription_service.dart';

class SubscriptionController extends GetxController {
  AuthModel user = AuthModel.fromJson({});
  RxInt tempCount = 0.obs; // This variable is to just update the screen
  int apiRepeatCount = 0; // This variable is used to count and stop the api call

  RxList<SubscriptionModel> subscriptionList = [
    SubscriptionModel(
      id: Platform.isAndroid ? "monthly_plan" : "com.app.soakstream.monthlyplan",
      amount: '',
      title: 'Monthly Plan',
      description: '/month',
      isSelected: true.obs,
      isPurchased: false.obs,
    ),
    SubscriptionModel(
      id: Platform.isAndroid ? "yearly_plan" : "com.app.soakstream.yearlyplan",
      amount: '',
      title: 'Yearly Plan',
      description: '/year',
      isSelected: false.obs,
      isPurchased: false.obs,
    ),
    // SubscriptionModel(
    //   id: "life_time_plan",
    //   amount: '',
    //   title: 'Lifetime Plan',
    //   description: '/life_time',
    //   isSelected: false.obs,
    //   isPurchased: false.obs,
    // ),
  ].obs;

  StreamSubscription? stream;
  ProductDetailsResponse? response;
  RxInt selectedPlanIndex = 0.obs;
  ProductDetails? currentPlan;
  bool isPurchased = true; // This variable is used to stop multiple api call from the stream
  bool isRestore = true; // This variable is used to stop multiple api call from the stream
  bool isShowFreeTrial = false; // This variable is used to get the status of free trial

  Future<void> loginApi({bool isHarshil = true}) async {
    await getIt<AuthService>()
        .login(
      pass: '123456',
      email: isHarshil ? 'harshil.kmphitech@gmail.com' : 'mayur.kmphasis@gmail.com',
    )
        .handler(
      null,
      onSuccess: (value) async {
        user = value;
        getIt<SharedPreferences>().setToken = value.data?.token;

        utils.showToast(message: value.message ?? 'loginApi onSuccess');
        tempCount.value++;
      },
      onFailed: (value) {
        utils.showToast(isError: true, message: value.error.description);
        tempCount.value++;
      },
    );
  }

  /// This function is used to check the user plan
  Future<void> checkUserPlanApi() async {
    if (utils.isValueEmpty(user.data?.id)) await loginApi();

    // if user already has a plan and it's not expired then we will not do anything
    var expiryDate = DateTime.tryParse(user.data?.planExpiry ?? '') ?? DateTime.now();
    var isPlanExpired = expiryDate.isBefore(DateTime.now());
    if (user.data?.isSubscription == '1' && !isPlanExpired) return;

    await getIt<SubscriptionService>().checkUserPlanApi().handler(
      null,
      onSuccess: (value) async {
        if (value.data == null) return;

        if (!utils.isValueEmpty(value.data?.planExpiry)) {
          var expiryDate = DateTime.tryParse(value.data?.planExpiry ?? '') ?? DateTime.now();
          var isPlanExpired = expiryDate.isBefore(DateTime.now());
          if (isPlanExpired) {
            value.data?.isSubscription = '0';
            value.data?.productId = '';
            value.data?.planExpiry = '';
          }
        }
        user = value;

        if (value.data?.isSubscription != '1') {
          apiRepeatCount = 0;
          // If user does not have any subscription plan so here we check if user has purchased any plan in the store and if user has any plan then we call the restore api
          Platform.isAndroid ? restorePurchasePlanAndroid(isShowLoading: false) : restorePurchasePlan(isShowLoading: false);
        }

        tempCount.value++;
      },
      onFailed: (value) {
        utils.showToast(isError: true, message: value.error.description);
        tempCount.value++;
      },
    );
  }

  Future<void> onRestorePress() async {
    printAction('-------111');
    apiRepeatCount = 0;

    if (Platform.isIOS) {
      printAction('-------222');
      await restorePurchasePlan();
    } else {
      printAction('-------333');
      isRestore = false;
      Loading.show();
      try {
        printAction('-------444');
        printAction('------- stream == null = ${stream == null}');
        if (stream == null) await subscriptionStream();
        isPurchased = false;

        await InAppPurchase.instance.restorePurchases(applicationUserName: user.data?.id);
        printAction('-------555');
      } catch (e) {
        printAction('-------666');
        printWarning('------catch e: $e');
        Loading.dismiss();
      }
      printAction('-------777');
      Loading.dismiss();
    }
    printAction('-------888');
  }

  Future<void> onPurchasePress() async {
    /// If user already purchased any plan then user can't select purchased plan
    /// ex: if user purchased monthly plan then user can't select monthly plan; Make the other plan selected
    if (user.data?.productId?.contains('monthly') ?? false) {
      if (selectedPlanIndex.value == 0) return;
    }
    if (user.data?.productId?.contains('yearly') ?? false) {
      if (selectedPlanIndex.value == 1) return;
    }

    apiRepeatCount = 0;
    isPurchased = false;
    if (response == null) await fetchSubscriptions();
    if (stream == null) await subscriptionStream();
    Platform.isAndroid ? purchaseBottomSheet() : restorePurchasePlan(isFromPurchase: true);
  }

  Future<void> fetchSubscriptions() async {
    printAction('----- fetchSubscriptions start');

    try {
      Loading.show();

      final bool isAvailable = await InAppPurchase.instance.isAvailable();

      printAction('----- isAvailable = $isAvailable');
      if (!isAvailable) {
        utils.showToast(message: 'The payment platform is not ready or not available in this device.');
        Loading.dismiss();
        return;
      }

      Set<String> subscriptionIds = <String>{
        Platform.isAndroid ? 'monthly_plan' : "com.app.soakstream.monthlyplan",
        Platform.isAndroid ? 'yearly_plan' : "com.app.soakstream.yearlyplan",
        // "life_time_plan",
      };

      response = await InAppPurchase.instance.queryProductDetails(subscriptionIds);
      printAction("--- response productDetails.length = ${response?.productDetails.length}");

      currentPlan = null;
      currentPlan = response?.productDetails.firstWhere(
        (pd) => pd.id.contains(selectedPlanIndex.value == 0 ? 'monthly' : 'yearly'),
      );

      for (var pd in response?.productDetails ?? <ProductDetails>[]) {
        printAction('');
        printAction('-----productDetails id = ${pd.id}');
        printAction("-----productDetails price = ${pd.price}");
        for (var s in subscriptionList) {
          if (s.id == pd.id) {
            s.amount = pd.price;
            s.isSelected.refresh();
            if (s.id == user.data?.productId && user.data?.isSubscription == '1') {
              s.isPurchased.value = true;
              s.isPurchased.refresh();
            }
          }
        }
      }
    } catch (e) {
      printError('----- fetchSubscriptions catch error= $e');
      utils.showToast(message: "Error is $e", isError: true);
      Loading.dismiss();
    } finally {
      printSuccess('----- fetchSubscriptions finally -----');
      Loading.dismiss();
    }

    printAction('----- fetchSubscriptions end');
  }

  Future<void> subscriptionStream() async {
    printAction('----- subscriptionStream start');

    stream?.cancel();
    stream = null;

    stream = InAppPurchase.instance.purchaseStream.listen(
      (event) async {
        printAction("--- event.length ${event.length}");

        if (event.isEmpty) {
          printWarning("------> event.isEmpty <------");

          Loading.dismiss();
          utils.showToast(message: "Currently, you have no plans.");
        }

        // ignore: avoid_function_literals_in_foreach_calls
        event.forEach((element) async {
          printWarning("--- element.status = ${element.status}");
          printWarning("--- element.error = ${element.error}");
          printWarning("--- element.productID = ${element.productID}");
          printWarning("--- element.purchaseID = ${element.purchaseID}");
          printWarning("--- element.transactionDate = ${element.transactionDate}");
          printWarning("--- element.verificationData.source = ${element.verificationData.source}");
          printWarning("--- element.pendingCompletePurchase = ${element.pendingCompletePurchase}");

          if (element.pendingCompletePurchase) {
            printSuccess("");
            printSuccess("--- element.status=${element.status}");
            printSuccess("--- element.pendingCompletePurchase=${element.pendingCompletePurchase}");
            printSuccess("");
            try {
              await InAppPurchase.instance.completePurchase(element);
              printSuccess("--- completePurchase done ---");
            } catch (e) {
              printError("--- CompletePurchase catch error: $e");
            }
          }

          if (element.status == PurchaseStatus.error || element.status == PurchaseStatus.canceled) {
            printAction("API CALLED 1 - PurchaseStatus.error || PurchaseStatus.canceled");

            if (Platform.isIOS) {
              if (element.error?.details?['NSUnderlyingError']?['userInfo']?['NSLocalizedFailureReason'] == "You are currently subscribed to this") {
                await restorePurchasePlan();
              }
            } else if (Platform.isAndroid) {
              printError("---element.error?.message=${element.error?.message}");

              if (element.error?.message == "BillingResponse.itemAlreadyOwned") {
                isRestore = false;

                await InAppPurchase.instance.restorePurchases(applicationUserName: user.data?.id);
              }
            }

            Loading.dismiss();
          } else if (element.status == PurchaseStatus.pending) {
            printAction("API CALLED 2 - PurchaseStatus.pending");
          } else if (element.status == PurchaseStatus.purchased) {
            printAction("API CALLED 3 - PurchaseStatus.purchased");

            if (!isPurchased) {
              isPurchased = true;
              printAction("API CALLED 4");

              if (Platform.isIOS) {
                printAction("API CALLED 6");

                apiRepeatCount = 0;
                purchasePlan(element);
              } else {
                printAction("API CALLED 5");
                printAction("--- element.productID = ${element.productID}");
                printAction("jsonDecoded orderId = ${jsonDecode(element.verificationData.localVerificationData)['orderId']}");

                purchaseAndroidPlan(
                  type: "purchase",
                  productId: element.productID,
                  orderId: jsonDecode(element.verificationData.localVerificationData)['orderId'],
                  purchaseToken: jsonDecode(element.verificationData.localVerificationData)['purchaseToken'],
                );
              }
            }
          } else if (element.status == PurchaseStatus.restored) {
            printAction("API CALLED 0 - PurchaseStatus.restored");

            if (Platform.isAndroid) {
              printAction("-----event.length=${event.length}");
              if (element == event.last) {
                printAction("-----isRestore=$isRestore");

                if (!isRestore) {
                  isRestore = true;

                  restorePurchasePlanAndroid();
                }
              }
            }
          }
        });
      },
      onDone: () {
        printAction("----- subscriptionStream onDone");
        stream?.cancel();
        stream = null;
        Loading.dismiss();
      },
      onError: (error) {
        printError("----- subscriptionStream onError = $error");
        Loading.dismiss();
      },
    );

    printAction('----- subscriptionStream end');
  }

  Future<void> purchaseBottomSheet() async {
    Loading.show();
    var planId = subscriptionList[selectedPlanIndex.value].id;
    printWarning("----- purchaseBottomSheet planId = $planId");

    currentPlan = response?.productDetails.firstWhere(
      (pd) => pd.id.contains(selectedPlanIndex.value == 0 ? 'monthly' : 'yearly'),
    );

    PurchaseParam? purchaseParam;

    printAction("----- response == null = ${response == null}");
    if (response == null) await fetchSubscriptions();
    if (stream == null) await subscriptionStream();

    printAction("----- response?.productDetails.length = ${response?.productDetails.length}");
    for (int i = 0; i < (response?.productDetails.length ?? 0); i++) {
      printAction("----- planId = $planId response?.productDetails[i].id = ${response?.productDetails[i].id}");

      if (response?.productDetails[i].id.trim() == planId) {
        printWarning("----- response?.productDetails[i].id.trim() == planId = ${response?.productDetails[i].id.trim() == planId}");
        printWarning("----- user.data?.id = ${user.data?.id}");

        purchaseParam = PurchaseParam(productDetails: response!.productDetails[i], applicationUserName: user.data?.id);
        printAction("----- purchaseBottomSheet purchaseParam.productDetails.id = ${purchaseParam.productDetails.id}");
        break;
      }
    }

    try {
      printAction("----- purchaseBottomSheet purchaseParam is null = ${purchaseParam == null}");
      if (purchaseParam != null) {
        // First, check for any pending transactions
        var purchases = await InAppPurchase.instance.purchaseStream.first;
        if (purchases.isNotEmpty) {
          for (var purchase in purchases) {
            if (purchase.productID == planId && purchase.pendingCompletePurchase) {
              printAction("----- Found pending transaction for $planId, completing it first");
              await InAppPurchase.instance.completePurchase(purchase);
              printAction("----- Completed pending transaction");
              // Wait a moment for the completion to process
              await Future.delayed(Duration(seconds: 1));
            }
          }
        }

        // Now attempt the new purchase
        await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
        printAction("----- buyNonConsumable done");
      } else {
        Loading.dismiss();
        utils.showToast(message: "Something went wrong; Please try again later.");
      }
    } catch (e) {
      printAction("----- purchaseBottomSheet catch error = $e");
      stream?.cancel();
      stream = null;

      Loading.dismiss();

      if (e is PlatformException) {
        printWarning("----- ");
        printAction("----- purchaseBottomSheet catch error code = ${e.code}");
        printAction("----- purchaseBottomSheet catch error details = ${e.details}");
        printAction("----- purchaseBottomSheet catch error message = ${e.message}");
        printWarning("----- ");

        if (e.code == 'storekit_duplicate_product_object') {
          // Try to complete any pending transactions
          try {
            var purchases = await InAppPurchase.instance.purchaseStream.first;
            if (purchases.isNotEmpty) {
              for (var purchase in purchases) {
                if (purchase.productID == planId && purchase.pendingCompletePurchase) {
                  printAction("----- Found pending transaction for $planId, completing it first");
                  await InAppPurchase.instance.completePurchase(purchase);
                  printAction("----- Completed pending transaction");
                  // After completing, try the purchase again
                  await Future.delayed(Duration(seconds: 1));
                  await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam!);
                  return;
                }
              }
            }
          } catch (e) {
            printError("Error completing pending transaction: $e");
          }
          utils.showToast(message: "Please wait a moment and try again.");
          return;
        }

        utils.showToast(message: "Something went wrong. Please try again later.");
      }
    }
  }

  purchasePlan(PurchaseDetails productItem) async {
    printAction("--- purchasePlan api call start ");

    stream?.cancel();
    stream = null;

    String? amount;
    String? productId;
    String? appleTransactionId;
    String? originalTransactionId;

    // The below Future.delayed is used to wait for the payment to be processed; sometimes
    await Future.delayed(const Duration(milliseconds: 2500));

    printAction("-----> getAvailablePurchases <------");
    var list = await FlutterInappPurchase.instance.getAvailablePurchases();

    printAction("list -----> length ------> ${list?.length}");
    if ((list?.length ?? 0) >= 2) list?.sort((a, b) => b.transactionDate!.compareTo(a.transactionDate!));

    if (list == null) {
      apiRepeatCount++;
      printAction("----- apiRepeatCount = $apiRepeatCount ------");
      if (apiRepeatCount <= 2) purchasePlan(productItem);
      return;
    }

    for (var l in list) {
      printWarning('---=== List = ${l.productId} --- ${l.transactionDate}');
    }

    for (int i = 0; i < list.length; i++) {
      printAction("\n productItem.productID ------> ${productItem.productID}");
      printAction("currentPlan?.id ------> ${currentPlan?.id}");
      printAction("list[i].originalTransactionIdentifierIOS ------> ${list[i].originalTransactionIdentifierIOS}");
      printAction("list[i].productId ---condition--->${list[i].productId}");
      printAction("list[i].productId ---transactionId--->${list[i].transactionId}");
      printAction("list[i].productId ---transactionDate--->${list[i].transactionDate}");
      printAction("list[i].productId ---transactionStateIOS--->${list[i].transactionStateIOS}");
      printAction("currentPlan?.rawPrice--->${currentPlan?.rawPrice}");

      if (productItem.productID.trim() == list[i].productId?.trim()) {
        printAction("if if if if if if aave che");
        originalTransactionId = list[i].originalTransactionIdentifierIOS;
        appleTransactionId = list[i].transactionId ?? productItem.purchaseID ?? '';
        productId = productItem.productID;
        amount = currentPlan?.rawPrice.toString();
        break;
      }
    }

    await getIt<SubscriptionService>()
        .applePlanPurchaseApi(
      amount: amount ?? '0',
      productId: productId ?? '-',
      appleTransactionId: appleTransactionId ?? '-',
      originalTransactionId: originalTransactionId ?? '-',
    )
        .handler(
      null,
      onSuccess: (value) async {
        user = value;
        isPurchased = true;

        printSuccess("SUCCESSS-=-=-=-=-=-=-=-=-=-=--=-=-=-=-SUCCESSS");
        utils.showToast(message: value.message ?? 'androidPlanPurchaseApi onSuccess');

        tempCount.value++;
      },
      onFailed: (value) {
        tempCount.value++;
        if (value.statusCode == 409) {
          utils.showToast(isError: true, message: value.response?.data?['message']);
          return;
        }
        utils.showToast(isError: true, message: value.error.description);
      },
    );

    printAction("--- purchasePlan api call end ");
  }

  purchaseAndroidPlan({
    required String type,
    required String purchaseToken,
    required String productId,
    required String orderId,
  }) async {
    printAction("--- purchaseAndroidPlan api call start ");

    stream?.cancel();
    stream = null;

    await getIt<SubscriptionService>()
        .androidPlanPurchaseApi(
      type: type,
      productId: productId, // "productId": productItem.productID
      purchaseToken: purchaseToken, // "purchase_token": jsonDecode(productItem.verificationData.localVerificationData)['purchaseToken']
      orderId: orderId, // 'order_id': jsonDecode(productItem.verificationData.localVerificationData)['orderId']
      amount: '${currentPlan?.rawPrice ?? 10}',
    )
        .handler(
      null,
      onSuccess: (value) async {
        user = value;
        isPurchased = true;

        printSuccess("SUCCESSS-=-=-=-=-=-=-=-=-=-=--=-=-=-=-SUCCESSS");
        utils.showToast(message: value.message ?? 'androidPlanPurchaseApi onSuccess');

        tempCount.value++;
      },
      onFailed: (value) {
        tempCount.value++;

        if (value.statusCode == 409) {
          utils.showToast(isError: true, message: value.response?.data?['message']);
          return;
        }

        utils.showToast(isError: true, message: value.error.description);
      },
    );

    printAction("--- purchaseAndroidPlan api call end ");
  }

  restorePurchasePlan({bool isShowLoading = true, bool isFromPurchase = false}) async {
    printAction("--- restorePurchasePlan api call start ");
    printAction("--- isShowLoading = $isShowLoading --- isFromPurchase = $isFromPurchase");

    stream?.cancel();
    stream = null;

    if (isShowLoading) Loading.show();

    String? productId;
    String? appleTransactionId;
    String? originalTransactionId;

    printAction("-----> try <------");
    try {
      await FlutterInappPurchase.instance.getAvailablePurchases().timeout(
        Duration(seconds: 30),
        onTimeout: () async {
          apiRepeatCount++;
          printAction("----- apiRepeatCount = $apiRepeatCount ------");

          if (apiRepeatCount < 2) restorePurchasePlan(isShowLoading: isShowLoading);
          return null;
        },
      ).then(
        (list) async {
          printAction("list -----> length ------> ${list?.length}");
          printAction("----- apiRepeatCount = $apiRepeatCount ------");

          if (list == null) {
            if (apiRepeatCount >= 2) {
              if (isShowLoading) utils.showToast(message: "Please try again after some time.");
              if (isShowLoading) Loading.dismiss();
              apiRepeatCount = 0;
            }
            return;
          }

          if (list.isNotEmpty) {
            list.sort((a, b) => b.transactionDate!.compareTo(a.transactionDate!));

            for (int i = 0; i < list.length; i++) {
              printAction("\nlist[i].originalTransactionIdentifierIOS ------> ${list[i].originalTransactionIdentifierIOS}");
              printAction("list[i].productId ---condition--->${list[i].productId}");
              printAction("list[i].productId ---transactionId--->${list[i].transactionId}");
              printAction("list[i].productId ---transactionDate--->${list[i].transactionDate}");

              if (list[i].originalTransactionIdentifierIOS != null && list[i].originalTransactionIdentifierIOS != "") {
                printAction("----- if if if if if");
                originalTransactionId = list[i].originalTransactionIdentifierIOS;
                appleTransactionId = list[i].transactionId;
                if (!isFromPurchase) productId = list[i].productId;
                break;
              }
            }

            if (isFromPurchase) productId = subscriptionList[selectedPlanIndex.value].id;

            printAction('----productId=$productId');
            printAction('----appleTransactionId=$appleTransactionId');
            printAction('----originalTransactionId=$originalTransactionId');

            if (utils.isValueEmpty(originalTransactionId) || utils.isValueEmpty(appleTransactionId)) {
              if (isFromPurchase) {
                purchaseBottomSheet();
                return;
              }

              if (isShowLoading) utils.showToast(message: "Currently, you have no plans.");
              if (isShowLoading) Loading.dismiss();
              return;
            }

            await getIt<SubscriptionService>()
                .applePlanRestoreApi(
              isNewUser: isFromPurchase,
              productId: productId ?? '-',
              appleTransactionId: appleTransactionId ?? '-',
              originalTransactionId: originalTransactionId ?? '-',
            )
                .handler(
              null,
              isLoading: isShowLoading,
              onSuccess: (value) async {
                user = value;
                isPurchased = true;

                printSuccess("SUCCESSS-=-=-=-=-=-=-=-=-=-=--=-=-=-=-SUCCESSS");
                if (isShowLoading) utils.showToast(message: value.message ?? 'androidPlanPurchaseApi onSuccess');

                tempCount.value++;
              },
              onFailed: (value) {
                tempCount.value++;

                if (value.statusCode == 327 && isFromPurchase) {
                  purchaseBottomSheet();
                  return;
                }

                if (value.statusCode == 404) {
                  if (isShowLoading) utils.showToast(message: "Currently, you have no plans.");
                  return;
                }

                if (isShowLoading) utils.showToast(isError: true, message: value.error.description);
              },
            );
          } else {
            if (isFromPurchase) {
              purchaseBottomSheet();
              return;
            }

            if (isShowLoading) utils.showToast(message: "Currently, you have no plans");
            if (isShowLoading) Loading.dismiss();
          }
        },
      );
    } catch (e) {
      printError("-----eeeeeee5555555=$e");
      if (isShowLoading) Loading.dismiss();
      if (isShowLoading) utils.showToast(message: "$e", isError: true);
    } finally {
      if (isShowLoading) Loading.dismiss();
    }
  }

  restorePurchasePlanAndroid({bool isShowLoading = true}) async {
    printAction("--- restorePurchasePlanAndroid api call start ");

    stream?.cancel();
    stream = null;

    String? purchaseToken;
    String? productId;
    if (isShowLoading) Loading.show();

    try {
      await FlutterInappPurchase.instance.getAvailablePurchases().timeout(
        Duration(seconds: 30),
        onTimeout: () async {
          apiRepeatCount++;
          printAction("----- apiRepeatCount = $apiRepeatCount ------");

          if (apiRepeatCount < 2) restorePurchasePlanAndroid(isShowLoading: isShowLoading);
          return null;
        },
      ).then(
        (list) async {
          printAction("list -----> length ------> ${list?.length}");

          if (list == null) return;

          if (list.isNotEmpty) {
            list.sort((a, b) => b.transactionDate!.compareTo(a.transactionDate!));

            for (int i = 0; i < list.length; i++) {
              printAction("list[i].productId ---condition--->${list[i].productId}");
              printAction("list[i].productId ---transactionId--->${list[i].purchaseToken}");

              if (list[i].purchaseToken != null && list[i].purchaseToken != "") {
                purchaseToken = list[i].purchaseToken;
                productId = list[i].productId;
              }
            }

            if (!utils.isValueEmpty(purchaseToken) && !utils.isValueEmpty(productId)) {
              await getIt<SubscriptionService>()
                  .androidPlanRestoreApi(
                purchaseToken: purchaseToken ?? '-',
              )
                  .handler(
                null,
                isLoading: isShowLoading,
                onSuccess: (value) async {
                  user = value;
                  isPurchased = true;

                  printSuccess("SUCCESSS-=-=-=-=-=-=-=-=-=-=--=-=-=-=-SUCCESSS");
                  if (isShowLoading) utils.showToast(message: value.message ?? 'androidPlanPurchaseApi onSuccess');

                  tempCount.value++;
                },
                onFailed: (value) async {
                  if (isShowLoading) utils.showToast(isError: true, message: value.error.description);
                  tempCount.value++;
                },
              );
            } else {
              if (isShowLoading) Loading.dismiss();
              if (isShowLoading) utils.showToast(message: "Currently, you have no plan");
            }
          } else {
            if (isShowLoading) Loading.dismiss();
            if (isShowLoading) utils.showToast(message: "Currently, you have no plans");
          }
        },
      );
    } catch (e) {
      printError("-----eeeeeee4444444=$e");
      if (isShowLoading) Loading.dismiss();
      if (isShowLoading) utils.showToast(message: "$e", isError: true);
    } finally {
      if (isShowLoading) Loading.dismiss();
    }
  }

  checkFreeTrial({bool isShowLoading = true}) async {
    printAction("--- checkFreeTrial api call start ");

    if (isShowLoading) Loading.show();

    printAction("-----> try <------");
    try {
      await FlutterInappPurchase.instance
          .getPurchaseHistory()
          .timeout(
            Duration(seconds: 30),
            onTimeout: () => null,
          )
          .then(
        (list) async {
          printAction("list -----> length ------> ${list?.length}");

          if (list == null) return;

          if (list.isEmpty) {
            isShowFreeTrial = true;
          } else {
            // This is free trial plan id
            final planId = Platform.isAndroid ? "yearly_plan" : "com.app.soakstream.yearlyplan";

            for (int i = 0; i < list.length; i++) {
              printAction("list[i].productId ---condition--->${list[i].productId}");

              if (list[i].productId == planId) {
                isShowFreeTrial = false;
                break;
              }
              isShowFreeTrial = true;
            }
          }
          if (isShowLoading) Loading.dismiss();
        },
      );
    } catch (e) {
      printError("-----eeeeeee5555555=$e");
      if (isShowLoading) Loading.dismiss();
      // if (isShowLoading) utils.showToast(message: "$e", isError: true);
    } finally {
      if (isShowLoading) Loading.dismiss();
    }
  }

  @override
  void onInit() {
    try {
      checkUserPlanApi();
      fetchSubscriptions();

      FlutterInappPurchase.instance.finalize().then((value) async {
        printAction("----- FlutterInappPurchase finalize value = $value");
        final val = await FlutterInappPurchase.instance.initialize();
        printAction("----- FlutterInappPurchase initialize value = $val");
      });
    } catch (e) {
      printError("----- onInit Catch error = $e");
    }

    super.onInit();
  }

  @override
  void onClose() {
    stream?.cancel();
    stream = null;
    FlutterInappPurchase.instance.finalize();

    super.onClose();
  }
}

class SubscriptionModel {
  String id;
  String amount;
  String title;
  String description;
  RxBool isPurchased;
  RxBool isSelected;

  SubscriptionModel({
    required this.id,
    required this.amount,
    required this.title,
    required this.description,
    required this.isPurchased,
    required this.isSelected,
  });
}
