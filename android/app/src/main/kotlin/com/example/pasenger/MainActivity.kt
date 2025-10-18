package com.dailytransport.pasenger

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "com.dailytransport.pasenger/sms"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
      when (call.method) {
        "sendSms" -> {
          val phone = call.argument<String>("phone")
          val message = call.argument<String>("message")
          val subscriptionId = call.argument<Int>("subscriptionId")

          if (phone.isNullOrBlank() || message.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "Phone number and message are required", null)
            return@setMethodCallHandler
          }

          if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            result.error("MISSING_PERMISSION", "SEND_SMS permission not granted", null)
            return@setMethodCallHandler
          }

          try {
            val smsManager = resolveSmsManager(subscriptionId)
            sendMessage(smsManager, phone, message)
            result.success(null)
          } catch (ex: IllegalStateException) {
            result.error("SMS_MANAGER_UNAVAILABLE", ex.message, null)
          } catch (ex: Exception) {
            result.error("SMS_FAILED", ex.localizedMessage ?: "Unknown error", null)
          }
        }

        else -> result.notImplemented()
      }
    }
  }

  @SuppressLint("MissingPermission")
  private fun sendMessage(smsManager: SmsManager, phone: String, message: String) {
    val parts = smsManager.divideMessage(message)
    if (parts != null && parts.size > 1) {
      smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
    } else {
      smsManager.sendTextMessage(phone, null, message, null, null)
    }
  }

  private fun resolveSmsManager(subscriptionId: Int?): SmsManager {
    if (subscriptionId != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
      return SmsManager.getSmsManagerForSubscriptionId(subscriptionId)
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val manager = getSystemService(SmsManager::class.java)
      if (manager != null) {
        return manager
      }
    }

    return SmsManager.getDefault()
      ?: throw IllegalStateException("No SmsManager available on this device")
  }
}