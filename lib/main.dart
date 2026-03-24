import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_sahayak/src/routing/app_router.dart';
import 'package:krishi_sahayak/src/features/authentication/data/auth_repository.dart';
import 'package:krishi_sahayak/src/core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter is fully initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Professional State Initialization
  final container = ProviderContainer();
  
  // Initialize Authentication State (Checks for existing session)
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
      // Using the Professional Theme we created
      theme: AppTheme.lightTheme,
    );
  }
}
