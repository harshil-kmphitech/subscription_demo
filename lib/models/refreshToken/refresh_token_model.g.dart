// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshTokenResponse _$RefreshTokenResponseFromJson(
        Map<String, dynamic> json) =>
    RefreshTokenResponse(
      version: json['version'] as String,
      statusCode: (json['statusCode'] as num).toInt(),
      isSuccess: json['isSuccess'] as bool,
      data: json['data'] as Map<String, dynamic>,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RefreshTokenResponseToJson(
        RefreshTokenResponse instance) =>
    <String, dynamic>{
      'version': instance.version,
      'statusCode': instance.statusCode,
      'isSuccess': instance.isSuccess,
      'data': instance.data,
      'message': instance.message,
    };
