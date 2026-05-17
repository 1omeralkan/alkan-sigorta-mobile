import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../core/network/dio_client.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) {
            final dioClient = DioClient();
            final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
            final authRepository = AuthRepositoryImpl(authRemoteDataSource);
            final authCubit = AuthCubit(authRepository);

            return BlocProvider(
              create: (_) => authCubit,
              child: const LoginPage(),
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı'),
            ),
          ),
        );
    }
  }
}
