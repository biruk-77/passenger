// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- 1. IMPORT THE PACKAGE

// --- YOUR EXISTING LOCALIZATION FILES ---
import 'l10n/app_localizations.dart';
import 'l10n/custom_localizations.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/l10n.dart';

// --- YOUR PROJECT IMPORTS ---
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/saved_places_provider.dart';
import 'providers/history_provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/google_maps_service.dart';
import 'services/connectivity_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/passenger_login_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'utils/constants.dart';
import 'theme/themes.dart';
import 'utils/logger.dart'; // Make sure you have a logger
import 'screens/video_splash_screen.dart';
import 'widgets/theme_transition_animation.dart';

// <-- 2. ADD THIS FUNCTION TO REQUEST PERMISSION
/// This function requests the mandatory notification permission on Android 13+.
Future<void> _requestNotificationPermission() async {
  // permission_handler knows this is only needed on Android 13+
  final status = await Permission.notification.request();

  if (status.isGranted) {
    Logger.success("Permissions", "✅ Notification permission granted.");
  } else if (status.isDenied) {
    Logger.warning("Permissions", "⚠️ Notification permission denied by user.");
    // Here, you could show a dialog explaining why notifications are useful
  } else if (status.isPermanentlyDenied) {
    Logger.error(
      "Permissions",
      "❌ Notification permission permanently denied. User must enable it in app settings.",
    );
    // Here, you could show a dialog with a button to open the app settings
    // Open app settings to allow user to enable notification permission
    if (status.isPermanentlyDenied) {
      Logger.error(
        "Permissions",
        " Notification permission permanently denied. User must enable it in app settings.",
      );
      await openAppSettings();
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service so channels are created
  await NotificationService().init();

  // <-- 3. CALL THE PERMISSION FUNCTION RIGHT AFTER INIT
  // This will show the pop-up to the user on the first launch.
  await _requestNotificationPermission();

  // Initialize date formatting
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('am', null),
    initializeDateFormatting('om', null),
    initializeDateFormatting('so', null),
    initializeDateFormatting('ti', null),
  ]);
  runApp(
    MultiProvider(
      providers: [
        // Your other providers are fine
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SavedPlacesProvider()),
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
        Provider<GoogleMapsService>(
          create: (_) => GoogleMapsService(apiKey: ApiConstants.googleApiKey),
        ),
        Provider<NotificationService>(create: (_) => NotificationService()),

        // ▼▼▼ THIS IS THE FINAL, CORRECTED BLOCK ▼▼▼

        // 1. Provide SocketService. No changes here.
        Provider<SocketService>(
          create: (context) {
            final socketService = SocketService();
            socketService.setNotificationService(
              context.read<NotificationService>(),
            );
            return socketService;
          },
          dispose: (_, service) => service.dispose(),
        ),

        // 2. Provide AuthService. No changes here.
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(context.read<SocketService>()),
        ),

        // 3. This is the part with the error.
        ProxyProvider<AuthService, ApiService>(
          // The function gives us: context, the AuthService, and the previous ApiService
          update:
              (
                BuildContext context,
                AuthService authService,
                ApiService? previousApiService,
              ) {
                final apiService = ApiService(authService);

                // Now, use the 'context' from the function signature to read SocketService
                final socketService = context.read<SocketService>();

                // Link the services
                socketService.setAuthService(authService);
                socketService.setApiService(apiService);

                return apiService;
              },
        ),
        // ▲▲▲ END OF THE FINAL, CORRECTED BLOCK ▲▲▲

        // The rest of your providers are fine
        ChangeNotifierProxyProvider2<
          ApiService,
          GoogleMapsService,
          HistoryProvider
        >(
          create: (context) => HistoryProvider(
            Provider.of<ApiService>(context, listen: false),
            Provider.of<GoogleMapsService>(context, listen: false),
          ),
          update: (_, apiService, googleMapsService, __) =>
              HistoryProvider(apiService, googleMapsService),
        ),
        StreamProvider<ConnectivityResult>(
          create: (context) =>
              context.read<ConnectivityService>().connectionStream,
          initialData: ConnectivityResult.mobile,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// NO CHANGES NEEDED BELOW THIS LINE for MyApp or AuthWrapper
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  TextTheme _getTextThemeForLocale(TextTheme base, Locale? currentLocale) {
    String fontFamily = 'Poppins';
    if (currentLocale != null &&
        ['am', 'om', 'ti'].contains(currentLocale.languageCode)) {
      fontFamily = 'NotoSansEthiopic';
    }
    return base.apply(fontFamily: fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentLocale = localeProvider.locale;

    final finalLightTheme = AppThemes.lightTheme.copyWith(
      textTheme: _getTextThemeForLocale(
        AppThemes.lightTheme.textTheme,
        currentLocale,
      ),
    );
    final finalDarkTheme = AppThemes.darkTheme.copyWith(
      textTheme: _getTextThemeForLocale(
        AppThemes.darkTheme.textTheme,
        currentLocale,
      ),
    );

    return MaterialApp(
      title: 'Rideshare Passenger App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: finalLightTheme,
      darkTheme: finalDarkTheme,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        OromoMaterialLocalizationsDelegate(),
        OromoCupertinoLocalizationsDelegate(),
        SomaliMaterialLocalizationsDelegate(),
        SomaliCupertinoLocalizationsDelegate(),
        TigrinyaMaterialLocalizationsDelegate(),
        TigrinyaCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
        Locale('so'),
        Locale('ti'),
      ],
      home: const ThemeTransitionAnimation(
        child: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasShownSplash = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _linkServices();
    });
  }

  void _linkServices() {
    // --- THIS IS THE FIX ---
    // Change listen: true to listen: false. This function only needs to link
    // the services once, it doesn't need to rebuild the widget when they change.
    final socketService = Provider.of<SocketService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );

    socketService.setApiService(apiService);
    socketService.setNotificationService(notificationService);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: true);

    return StreamBuilder<AuthStatus>(
      stream: authService.authStatusStream,
      builder: (context, snapshot) {
        // Step 1: Check if the connection is waiting (loading) and we haven't shown splash yet
        if (snapshot.connectionState == ConnectionState.waiting && !_hasShownSplash) {
          _hasShownSplash = true;
          return const Center(child: VideoSplashScreen());
        }

        // Step 2: If we have data, process the auth status
        setL10n(AppLocalizations.of(context)!);
        if (snapshot.hasData) {
          final authStatus = snapshot.data!;

          switch (authStatus) {
            case AuthStatus.authenticated:
              return const HomeScreen();
            case AuthStatus.needsProfileCompletion:
              return const CompleteProfileScreen();
            case AuthStatus.unauthenticated:
            case AuthStatus.unknown:
              // Show splash screen only for first-time unauthenticated users
              if (!_hasShownSplash) {
                _hasShownSplash = true;
                return const Center(child: VideoSplashScreen());
              }
              return const PassengerLoginScreen();
          }
        }

        // Step 3: If no data yet and we haven't shown splash, show it
        if (!_hasShownSplash) {
          _hasShownSplash = true;
          return const Center(child: VideoSplashScreen());
        }

        // As a fallback, show the login screen.
        return const PassengerLoginScreen();
      },
    );
  }
}
