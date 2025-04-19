// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:subscription_demo/helpers/all.dart' as _i932;
import 'package:subscription_demo/helpers/injectable/injectable%20properties/injectable_properties.dart'
    as _i658;
import 'package:subscription_demo/services/auth/auth_service.dart' as _i30;
import 'package:subscription_demo/services/refreshToken/refresh_token_service.dart'
    as _i465;
import 'package:subscription_demo/services/subscription/subscription_service.dart'
    as _i275;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final authModule = _$AuthModule();
    await gh.factoryAsync<_i932.SharedPreferences>(
      () => authModule.sharedPref(),
      preResolve: true,
    );
    gh.singleton<_i932.Dio>(() => authModule.dio());
    gh.lazySingleton<_i30.AuthService>(() => _i30.AuthService(gh<_i932.Dio>()));
    gh.lazySingleton<_i465.RefreshTokenService>(
        () => _i465.RefreshTokenService(gh<_i932.Dio>()));
    gh.lazySingleton<_i275.SubscriptionService>(
        () => _i275.SubscriptionService(gh<_i932.Dio>()));
    return this;
  }
}

class _$AuthModule extends _i658.AuthModule {}
