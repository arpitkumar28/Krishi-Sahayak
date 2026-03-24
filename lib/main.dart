import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:krishi_sahayak/src/routing/app_router.dart';
import 'package:krishi_sahayak/src/features/authentication/data/auth_repository.dart';
import 'package:krishi_sahayak/src/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables before starting
  await dotenv.load(fileName: ".env");
  
  final container = ProviderContainer();
  
  try {
    await container.read(authRepositoryProvider.notifier).init();
  } catch (e) {
    debugPrint('Auth initialization error: $e');
  }
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      title: 'Krishi Sahayak',
      theme: AppTheme.lightTheme,
    );
  }
}
