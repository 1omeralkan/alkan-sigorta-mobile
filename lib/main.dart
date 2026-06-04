import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alkan_sigorta_mobile/core/constants/app_theme.dart';
import 'package:alkan_sigorta_mobile/core/routes/app_router.dart';
import 'package:alkan_sigorta_mobile/core/network/dio_client.dart';
import 'package:alkan_sigorta_mobile/features/application/data/datasources/application_remote_data_source.dart';
import 'package:alkan_sigorta_mobile/features/application/data/repositories/application_repository_impl.dart';
import 'package:alkan_sigorta_mobile/features/application/domain/repositories/application_repository.dart';
import 'package:alkan_sigorta_mobile/features/collection/data/datasources/collection_remote_data_source.dart';
import 'package:alkan_sigorta_mobile/features/collection/data/repositories/collection_repository_impl.dart';
import 'package:alkan_sigorta_mobile/features/collection/domain/repositories/collection_repository.dart';
import 'package:alkan_sigorta_mobile/features/policy/data/datasources/policy_remote_data_source.dart';
import 'package:alkan_sigorta_mobile/features/policy/data/repositories/policy_repository_impl.dart';
import 'package:alkan_sigorta_mobile/features/policy/domain/repositories/policy_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const AlkanSigortaApp());
}

class AlkanSigortaApp extends StatelessWidget {
  const AlkanSigortaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dioClient = DioClient();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApplicationRepository>(
          create: (_) => ApplicationRepositoryImpl(
            ApplicationRemoteDataSourceImpl(dioClient),
          ),
        ),
        RepositoryProvider<CollectionRepository>(
          create: (_) => CollectionRepositoryImpl(
            CollectionRemoteDataSourceImpl(dioClient),
          ),
        ),
        RepositoryProvider<PolicyRepository>(
          create: (_) => PolicyRepositoryImpl(
            PolicyRemoteDataSourceImpl(dioClient),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Alkan Sigorta',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/',
      ),
    );
  }
}
