import 'package:injectable/injectable.dart';
import 'package:subscription_demo/helpers/all.dart';

@module
abstract class AuthModule {
  @singleton
  Dio dio() => Dio(
        BaseOptions(
          sendTimeout: Duration(seconds: AppConfig.timeoutDuration),
          receiveTimeout: Duration(seconds: AppConfig.timeoutDuration),
          connectTimeout: Duration(seconds: AppConfig.timeoutDuration),
        ),
      );
  @preResolve
  Future<SharedPreferences> sharedPref() => SharedPreferences.getInstance();
}
