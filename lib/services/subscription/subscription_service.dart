import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:subscription_demo/helpers/all.dart';
import 'package:subscription_demo/models/authModel/auth_model.dart';

part 'subscription_service.g.dart';

Map<String, dynamic> deserializedynamic(Map<String, dynamic> json) => json;

@RestApi(parser: Parser.FlutterCompute, baseUrl: AppConfig.baseUrl)
@lazySingleton
abstract class SubscriptionService {
  @factoryMethod
  factory SubscriptionService(Dio dio) = _SubscriptionService;

  @POST(EndPoints.inapppurchaseAndroidPlanPurchase)
  Future<AuthModel> androidPlanPurchaseApi({
    @Field() required String type,
    @Field() required String productId,
    @Field() required String purchaseToken,
    @Field() required String orderId,
    @Field() required String amount,
  });

  @POST(EndPoints.inapppurchaseAndroidPlanRestore)
  Future<AuthModel> androidPlanRestoreApi({
    @Field() required String purchaseToken,
  });

  @POST(EndPoints.inapppurchaseApplePlanPurchase)
  Future<AuthModel> applePlanPurchaseApi({
    @Field() required String productId,
    @Field() required String originalTransactionId,
    @Field() required String appleTransactionId,
    @Field() required String amount,
  });

  @POST(EndPoints.inapppurchaseApplePlanRestore)
  Future<AuthModel> applePlanRestoreApi({
    @Field() required String productId,
    @Field() required String appleTransactionId,
    @Field() required String originalTransactionId,
  });

  @POST(EndPoints.inapppurchaseCheckUserPlan)
  Future<AuthModel> checkUserPlanApi();
}
