package com.example.upi_tracker

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import org.json.JSONArray

class MainActivity : FlutterActivity() {
private lateinit var smsChannel: MethodChannel

private var initialTransactionId: String? = null
    companion object {

        private const val SMS_CHANNEL =
            "upi_tracker/incoming_sms"

        private const val PREFS_NAME =
            "upi_tracker_sms_queue"

        private const val QUEUE_KEY =
            "pending_sms"

        // Notification configuration
        private const val NOTIFICATION_CHANNEL_ID =
            "transaction_notifications"

        private const val NOTIFICATION_CHANNEL_NAME =
            "Transaction Notifications"

        private const val NOTIFICATION_CHANNEL_DESCRIPTION =
            "Notifications for newly detected transactions"

        private const val NOTIFICATION_PERMISSION_REQUEST_CODE =
            1001

        private const val NOTIFICATION_PAYLOAD_KEY =
            "transaction_id"
    }

    private var notificationPermissionResult:
        MethodChannel.Result? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(
            flutterEngine
        )
        initialTransactionId =
    intent.getStringExtra("transaction_id")

        createNotificationChannel()

        smsChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        SMS_CHANNEL,
         )

        smsChannel.setMethodCallHandler { call, result ->

            when (call.method) {

                // ------------------------------------------------
                // Existing SMS queue functionality
                // ------------------------------------------------

                "getPendingSms" -> {
                    result.success(
                        getPendingSms()
                    )
                }

                "acknowledgeSms" -> {
                    val id =
                        call.argument<String>("id")

                    if (id.isNullOrEmpty()) {
                        result.error(
                            "INVALID_ID",
                            "SMS id is required",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val removed =
                        acknowledgeSms(id)

                    result.success(removed)
                }
                "getInitialTransactionId" -> {
                    result.success(initialTransactionId)
                    initialTransactionId = null
                }
                // ------------------------------------------------
                // Notification functionality
                // ------------------------------------------------

                "requestNotificationPermission" -> {
                    requestNotificationPermission(
                        result
                    )
                }

                "areNotificationsEnabled" -> {
                    result.success(
                        areNotificationsEnabled()
                    )
                }

                "showTransactionNotification" -> {
                    val notificationId =
                        call.argument<Int>(
                            "notificationId"
                        )

                    val title =
                        call.argument<String>(
                            "title"
                        )

                    val body =
                        call.argument<String>(
                            "body"
                        )

                    val transactionId =
                        call.argument<String>(
                            "transactionId"
                        )

                    if (
                        notificationId == null ||
                        title.isNullOrEmpty() ||
                        body.isNullOrEmpty() ||
                        transactionId.isNullOrEmpty()
                    ) {
                        result.error(
                            "INVALID_NOTIFICATION_DATA",
                            "notificationId, title, body and transactionId are required",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val shown =
                        showTransactionNotification(
                            notificationId =
                                notificationId,
                            title = title,
                            body = body,
                            transactionId =
                                transactionId,
                        )

                    result.success(shown)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)

    setIntent(intent)

    val transactionId =
        intent.getStringExtra("transaction_id")

    if (
        !transactionId.isNullOrEmpty() &&
        ::smsChannel.isInitialized
    ) {
        smsChannel.invokeMethod(
            "notificationTapped",
            transactionId,
        )
    }
}

    // ============================================================
    // Notification permission
    // ============================================================

    private fun requestNotificationPermission(
        result: MethodChannel.Result
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }

        if (
            checkSelfPermission(
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }

        notificationPermissionResult = result

        requestPermissions(
            arrayOf(
                Manifest.permission.POST_NOTIFICATIONS
            ),
            NOTIFICATION_PERMISSION_REQUEST_CODE,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults,
        )

        if (
            requestCode ==
            NOTIFICATION_PERMISSION_REQUEST_CODE
        ) {
            val granted =
                grantResults.isNotEmpty() &&
                    grantResults[0] ==
                    PackageManager.PERMISSION_GRANTED

            notificationPermissionResult
                ?.success(granted)

            notificationPermissionResult = null
        }
    }

    private fun areNotificationsEnabled(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (
                checkSelfPermission(
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return false
            }
        }

        return NotificationManagerCompat
            .from(this)
            .areNotificationsEnabled()
    }

    // ============================================================
    // Notification channel
    // ============================================================

    private fun createNotificationChannel() {
        if (
            Build.VERSION.SDK_INT <
            Build.VERSION_CODES.O
        ) {
            return
        }

        val channel =
            NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                NOTIFICATION_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description =
                    NOTIFICATION_CHANNEL_DESCRIPTION
            }

        val notificationManager =
            getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

        notificationManager.createNotificationChannel(
            channel
        )
    }

    // ============================================================
    // Show notification
    // ============================================================

    private fun showTransactionNotification(
        notificationId: Int,
        title: String,
        body: String,
        transactionId: String,
    ): Boolean {

        if (!areNotificationsEnabled()) {
            return false
        }

        val intent =
            Intent(
                this,
                MainActivity::class.java,
            ).apply {
                putExtra(
                    NOTIFICATION_PAYLOAD_KEY,
                    transactionId,
                )

                flags =
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val pendingIntent =
            PendingIntent.getActivity(
                this,
                notificationId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE,
            )

        val notification =
            NotificationCompat.Builder(
                this,
                NOTIFICATION_CHANNEL_ID,
            )
                .setSmallIcon(
                    android.R.drawable.ic_dialog_info
                )
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(
                    NotificationCompat.PRIORITY_HIGH
                )
                .setAutoCancel(true)
                .setContentIntent(
                    pendingIntent
                )
                .build()

        NotificationManagerCompat
            .from(this)
            .notify(
                notificationId,
                notification,
            )

        return true
    }

    // ============================================================
    // Existing SMS queue
    // ============================================================

    private fun getPendingSms(): List<Map<String, Any>> {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE,
            )

        val stored =
            preferences.getString(
                QUEUE_KEY,
                null,
            )

        if (stored.isNullOrEmpty()) {
            return emptyList()
        }

        return try {
            val jsonArray =
                JSONArray(stored)

            buildList {
                for (
                    index in
                    0 until jsonArray.length()
                ) {
                    val item =
                        jsonArray.getJSONObject(index)

                    add(
                        mapOf(
                            "id" to
                                item.optString(
                                    "id"
                                ),

                            "sender" to
                                item.optString(
                                    "sender"
                                ),

                            "body" to
                                item.optString(
                                    "body"
                                ),

                            "timestamp" to
                                item.optLong(
                                    "timestamp"
                                ),
                        )
                    )
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun acknowledgeSms(
        id: String,
    ): Boolean {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE,
            )

        val stored =
            preferences.getString(
                QUEUE_KEY,
                null,
            )

        if (stored.isNullOrEmpty()) {
            return false
        }

        return try {
            val oldQueue =
                JSONArray(stored)

            val newQueue =
                JSONArray()

            var removed = false

            for (
                index in
                0 until oldQueue.length()
            ) {
                val item =
                    oldQueue.getJSONObject(index)

                val itemId =
                    item.optString("id")

                if (itemId == id) {
                    removed = true
                    continue
                }

                newQueue.put(item)
            }

            if (removed) {
                preferences.edit()
                    .putString(
                        QUEUE_KEY,
                        newQueue.toString(),
                    )
                    .apply()
            }

            removed
        } catch (_: Exception) {
            false
        }
    }
}