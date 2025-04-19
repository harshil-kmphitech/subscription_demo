import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:subscription_demo/helpers/all.dart';
import 'package:subscription_demo/models/authModel/auth_model.dart';

part 'auth_service.g.dart';

Map<String, dynamic> deserializedynamic(Map<String, dynamic> json) => json;

@RestApi(parser: Parser.FlutterCompute, baseUrl: AppConfig.baseUrl)
@lazySingleton
abstract class AuthService {
  @factoryMethod
  factory AuthService(Dio dio) = _AuthService;

  @POST(EndPoints.authLogin)
  Future<AuthModel> login({
    @Field() required String pass,
    @Field() required String email,
  });
}
