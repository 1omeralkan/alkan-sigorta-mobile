import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/register_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/parameter_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/application/presentation/pages/application_create_page.dart';
import '../../features/application/presentation/pages/applications_list_page.dart';
import '../../features/application/presentation/bloc/application_cubit.dart';
import '../../features/application/data/datasources/application_remote_data_source.dart';
import '../../features/application/data/repositories/application_repository_impl.dart';
import '../../features/product/presentation/bloc/product_cubit.dart';
import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/storage_service.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) {
            final dioClient = DioClient();
            final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
            final authRepository = AuthRepositoryImpl(authRemoteDataSource);
            final storageService = StorageService();
            final authCubit = AuthCubit(authRepository, storageService);

            return BlocProvider(
              create: (_) => authCubit,
              child: const LoginPage(),
            );
          },
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) {
            final dioClient = DioClient();
            final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
            final parameterRemoteDataSource = ParameterRemoteDataSourceImpl(dioClient);
            final authRepository = AuthRepositoryImpl(authRemoteDataSource);
            final registerCubit = RegisterCubit(authRepository, parameterRemoteDataSource);

            return BlocProvider(
              create: (_) => registerCubit,
              child: const RegisterPage(),
            );
          },
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case '/application-create':
        return MaterialPageRoute(
          builder: (_) {
            final dioClient = DioClient();

            final applicationRemoteDataSource = ApplicationRemoteDataSourceImpl(dioClient);
            final applicationRepository = ApplicationRepositoryImpl(applicationRemoteDataSource);
            final applicationCubit = ApplicationCubit(applicationRepository);

            final productRemoteDataSource = ProductRemoteDataSourceImpl(dioClient);
            final productRepository = ProductRepositoryImpl(productRemoteDataSource);
            final productCubit = ProductCubit(productRepository);

            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => applicationCubit),
                BlocProvider(create: (_) => productCubit..fetchProducts()),
              ],
              child: const ApplicationCreatePage(),
            );
          },
        );
      case '/applications':
        return MaterialPageRoute(
          builder: (_) => const ApplicationsListPage(),
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
