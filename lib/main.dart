import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/gamification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const DiskonIndonesiaApp());
}

class DiskonIndonesiaApp extends StatelessWidget {
  const DiskonIndonesiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Diskon Indonesia',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: _buildHome(authProvider),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return const SplashScreen();
    }
    
    if (authProvider.currentUser == null) {
      return const LoginScreen();
    }
    
    return const HomeScreen();
  }
}