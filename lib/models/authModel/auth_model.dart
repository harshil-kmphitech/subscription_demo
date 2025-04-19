import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

AuthModel deserializeAuthModel(Map<String, dynamic> json) => AuthModel.fromJson(json);

Map<String, dynamic> serializeAuthModel(AuthModel model) => model.toJson();

@JsonSerializable()
class AuthModel {
  String? version;
  int? statusCode;
  bool? isSuccess;
  AuthData? data;
  String? message;

  AuthModel({
    this.version,
    this.statusCode,
    this.isSuccess,
    this.data,
    this.message,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}

@JsonSerializable()
class AuthData {
  @JsonKey(name: "_id")
  String? id;
  String? name;
  String? email;
  String? password;
  String? profile;
  String? ucode;
  String? token;
  String? deviceToken;
  String? isFb;
  String? fbId;
  String? isGoogle;
  String? googleId;
  String? isApple;
  String? appleId;
  String? deleteReason;
  String? isSubscription;
  String? planExpiry;
  String? lastPurchaseToken;
  String? originalTransactionId;
  String? appleTransactionId;
  String? productId;
  int? isFreeTrialUsed;
  String? deviceType;

  AuthData({
    this.id,
    this.name,
    this.email,
    this.password,
    this.profile,
    this.ucode,
    this.token,
    this.deviceToken,
    this.isFb,
    this.fbId,
    this.isGoogle,
    this.googleId,
    this.isApple,
    this.appleId,
    this.deleteReason,
    this.isSubscription,
    this.planExpiry,
    this.lastPurchaseToken,
    this.originalTransactionId,
    this.appleTransactionId,
    this.productId,
    this.isFreeTrialUsed,
    this.deviceType,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}
