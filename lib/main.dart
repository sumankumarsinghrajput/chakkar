import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/services/notification_service.dart';
import 'features/multiplayer/lobby_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox('chakkar_prefs');

  await notificationService.init(
    onTap: (payload) {
      if (payload != null && payload.startsWith('room:')) {
        final roomId = payload.substring(5);
        if (roomId.isNotEmpty && roomId != 'null') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => LobbyScreen(roomId: roomId, isJoining: true),
            ),
          );
        }
      }
    },
  );

  runApp(const ProviderScope(child: ChakkarApp()));
}

class ChakkarApp extends StatelessWidget {
  const ChakkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chakkar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}
