import 'package:json_annotation/json_annotation.dart';

part 'refresh_token_model.g.dart';

RefreshTokenResponse deserializeRefreshTokenResponse(Map<String, dynamic> json) => RefreshTokenResponse.fromJson(json);

Map<String, dynamic> serializeRefreshTokenResponse(RefreshTokenResponse model) => model.toJson();

@JsonSerializable()
class RefreshTokenResponse {
  String version;
  int statusCode;
  bool isSuccess;
  Map<String, dynamic> data;
  String message;

  RefreshTokenResponse({
    required this.version,
    required this.statusCode,
    required this.isSuccess,
    required this.data,
    required this.message,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) => _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}
