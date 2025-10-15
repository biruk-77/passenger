// FILE: /lib/services/notification_service.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> onNotificationClick =
      StreamController<String?>.broadcast();

  /// Call this early in app startup
  Future<void> init() async {
    // ✅ CORRECT: The small icon is defined *only* here.
    // 'notification_icon' must match the filename in android/app/src/main/res/drawable
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    // initialize plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          onNotificationClick.add(response.payload);
        } else {
          onNotificationClick.add(null);
        }
      },
    );

    // create channel
    await _createAndroidNotificationChannels();

    Logger.success("NotificationService", "Notification Service Initialized");
  }

  Future<void> _createAndroidNotificationChannels() async {
    try {
      const AndroidNotificationChannel rideUpdatesChannel =
          AndroidNotificationChannel(
            'ride_updates_channel', // id
            'Ride Updates', // title
            description: 'Notifications for ride status changes.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            sound: RawResourceAndroidNotificationSound('notification'),
          );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(rideUpdatesChannel);

      Logger.success(
        "NotificationService",
        "✅ Notification channel 'ride_updates_channel' created successfully.",
      );
    } catch (e) {
      Logger.error(
        "NotificationService",
        "❌ Failed to create notification channel: $e",
      );
    }
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    Logger.info('NotificationService', 'Downloading image: $url');

    try {
      final client = http.Client();
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          Logger.warning('NotificationService', 'Empty image data');
          return null;
        }

        final Directory directory = await getTemporaryDirectory();
        final String filePath = '${directory.path}/$fileName';
        final File file = File(filePath);

        await file.writeAsBytes(bytes);

        if (await file.exists()) {
          final fileSize = await file.length();
          Logger.success(
            'NotificationService',
            'Image saved: $filePath ($fileSize bytes)',
          );
          return filePath;
        } else {
          Logger.error('NotificationService', 'File not created');
          return null;
        }
      } else {
        Logger.error(
          'NotificationService',
          'HTTP ${response.statusCode} for $url',
        );
        return null;
      }
    } on TimeoutException {
      Logger.error('NotificationService', 'Image download timeout');
      return null;
    } on SocketException catch (e) {
      Logger.error('NotificationService', 'Network error: $e');
      return null;
    } catch (e) {
      Logger.error('NotificationService', 'Download failed: $e');
      return null;
    }
  }

  /// Shows a persistent notification for ride updates.
  Future<void> showRideUpdateNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    Logger.info(
      'NotificationService',
      "Showing notification: $title - Image: $imageUrl",
    );

    String? largeIconPath;
    String? bigPicturePath;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final fileName = 'notif_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedPath = await _downloadAndSaveFile(imageUrl, fileName);

        if (savedPath != null) {
          largeIconPath = savedPath;
          bigPicturePath = savedPath;
          Logger.success(
            'NotificationService',
            'Image downloaded successfully',
          );
        } else {
          Logger.warning(
            'NotificationService',
            'Image download failed, using fallback',
          );
        }
      } catch (e) {
        Logger.error('NotificationService', 'Image processing error: $e');
      }
    }

    try {
      final AndroidNotificationDetails androidDetails;

      if (bigPicturePath != null && largeIconPath != null) {
        // With image
        androidDetails = AndroidNotificationDetails(
          'ride_updates_channel',
          'Ride Updates',
          channelDescription: 'Notifications about your ride status.',
          importance: Importance.max,
          priority: Priority.high,

          // --- FIX ---
          // ❌ The 'smallIcon' parameter is REMOVED from here.
          // The icon from init() will be used automatically.
          ongoing: true,
          autoCancel: false,

          largeIcon: FilePathAndroidBitmap(largeIconPath),
          styleInformation: BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: title,
            summaryText: body,
            hideExpandedLargeIcon: false,
          ),
          enableVibration: true,
          playSound: true,
        );
      } else {
        // Without image (fallback)
        androidDetails = AndroidNotificationDetails(
          'ride_updates_channel',
          'Ride Updates',
          channelDescription: 'Notifications about your ride status.',
          importance: Importance.high,
          priority: Priority.high,

          // --- FIX (APPLIED HERE FOR CONSISTENCY) ---
          // ❌ The 'smallIcon' parameter is REMOVED from here as well.
          ongoing: true,
          autoCancel: false,

          enableVibration: true,
          playSound: true,
        );
      }

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      const int rideUpdateNotificationId = 0;

      await _notificationsPlugin.show(
        rideUpdateNotificationId,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      Logger.success(
        'NotificationService',
        '✅ Notification displayed/updated (id=$rideUpdateNotificationId)',
      );
    } catch (e) {
      Logger.error('NotificationService', '❌ Notification failed: $e');
    }
  }

  /// Cancels the persistent ride notification. Call this when the ride is complete or cancelled.
  Future<void> cancelRideNotification() async {
    const int rideUpdateNotificationId = 0;
    await _notificationsPlugin.cancel(rideUpdateNotificationId);
    Logger.info(
      'NotificationService',
      'Cancelled ride notification (id=$rideUpdateNotificationId)',
    );
  }

  Future<void> cleanupTempFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = await tempDir.list().toList();

      final now = DateTime.now();
      for (final file in files) {
        if (file.path.contains('notif_')) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          if (age.inHours > 24) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      Logger.error('NotificationService', 'Cleanup error: $e');
    }
  }
}
