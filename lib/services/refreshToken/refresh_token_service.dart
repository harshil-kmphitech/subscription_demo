import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:subscription_demo/helpers/all.dart';
import 'package:subscription_demo/models/refreshToken/refresh_token_model.dart';

part 'refresh_token_service.g.dart';

@RestApi(parser: Parser.FlutterCompute, baseUrl: AppConfig.baseUrl)
@lazySingleton
abstract class RefreshTokenService {
  @factoryMethod
  factory RefreshTokenService(Dio dio) = _RefreshTokenService;

  @POST(EndPoints.refreshToken)
  Future<RefreshTokenResponse> refreshToken(
    @Field('user_id') String userId,
  );
}
