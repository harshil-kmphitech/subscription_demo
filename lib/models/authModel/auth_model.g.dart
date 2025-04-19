// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) => AuthModel(
      version: json['version'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      isSuccess: json['isSuccess'] as bool?,
      data: json['data'] == null
          ? null
          : AuthData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AuthModelToJson(AuthModel instance) => <String, dynamic>{
      'version': instance.version,
      'statusCode': instance.statusCode,
      'isSuccess': instance.isSuccess,
      'data': instance.data,
      'message': instance.message,
    };

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      profile: json['profile'] as String?,
      ucode: json['ucode'] as String?,
      token: json['token'] as String?,
      deviceToken: json['deviceToken'] as String?,
      isFb: json['isFb'] as String?,
      fbId: json['fbId'] as String?,
      isGoogle: json['isGoogle'] as String?,
      googleId: json['googleId'] as String?,
      isApple: json['isApple'] as String?,
      appleId: json['appleId'] as String?,
      deleteReason: json['deleteReason'] as String?,
      isSubscription: json['isSubscription'] as String?,
      planExpiry: json['planExpiry'] as String?,
      lastPurchaseToken: json['lastPurchaseToken'] as String?,
      originalTransactionId: json['originalTransactionId'] as String?,
      appleTransactionId: json['appleTransactionId'] as String?,
      productId: json['productId'] as String?,
      isFreeTrialUsed: (json['isFreeTrialUsed'] as num?)?.toInt(),
      deviceType: json['deviceType'] as String?,
    );

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'profile': instance.profile,
      'ucode': instance.ucode,
      'token': instance.token,
      'deviceToken': instance.deviceToken,
      'isFb': instance.isFb,
      'fbId': instance.fbId,
      'isGoogle': instance.isGoogle,
      'googleId': instance.googleId,
      'isApple': instance.isApple,
      'appleId': instance.appleId,
      'deleteReason': instance.deleteReason,
      'isSubscription': instance.isSubscription,
      'planExpiry': instance.planExpiry,
      'lastPurchaseToken': instance.lastPurchaseToken,
      'originalTransactionId': instance.originalTransactionId,
      'appleTransactionId': instance.appleTransactionId,
      'productId': instance.productId,
      'isFreeTrialUsed': instance.isFreeTrialUsed,
      'deviceType': instance.deviceType,
    };
