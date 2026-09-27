package com.example.upi_tracker

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

class GPayNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "GPAY_LISTENER"

        private const val GPAY_PACKAGE =
            "com.google.android.apps.nbu.paisa.user"

        private const val PREFS_NAME =
            "upi_tracker_gpay_queue"

        private const val QUEUE_KEY =
            "pending_gpay_notifications"

        private const val MAX_QUEUE_SIZE = 100
    }

    override fun onListenerConnected() {
        super.onListenerConnected()

        Log.d(
            TAG,
            "Notification listener connected"
        )
    }

    override fun onNotificationPosted(
        sbn: StatusBarNotification
    ) {
        // Only process Google Pay.
        if (sbn.packageName != GPAY_PACKAGE) {
            return
        }

        val notification = sbn.notification
        val extras = notification.extras

        val title =
            extras.getCharSequence(
                Notification.EXTRA_TITLE
            )?.toString()
                ?: ""

        val text =
            extras.getCharSequence(
                Notification.EXTRA_TEXT
            )?.toString()
                ?: ""

        val bigText =
            extras.getCharSequence(
                Notification.EXTRA_BIG_TEXT
            )?.toString()
                ?: ""

        Log.d(
            TAG,
            """
            GPay notification
            ---------------------
            Title: $title
            Text: $text
            BigText: $bigText
            ---------------------
            """.trimIndent()
        )

        // Only capture split requests for now.
        if (!title.contains(
                "split request",
                ignoreCase = true
            )
        ) {
            return
        }

        saveToPendingQueue(
            title = title,
            text = text,
            bigText = bigText,
            timestamp = sbn.postTime,
        )
    }

    private fun saveToPendingQueue(
        title: String,
        text: String,
        bigText: String,
        timestamp: Long,
    ) {
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

        val queue =
            if (stored.isNullOrEmpty()) {
                JSONArray()
            } else {
                try {
                    JSONArray(stored)
                } catch (_: Exception) {
                    JSONArray()
                }
            }

        if (queue.length() >= MAX_QUEUE_SIZE) {
            queue.remove(0)
        }

        val notification = JSONObject().apply {
            put(
                "id",
                UUID.randomUUID().toString(),
            )

            put(
                "title",
                title,
            )

            put(
                "text",
                text,
            )

            put(
                "bigText",
                bigText,
            )

            put(
                "timestamp",
                timestamp,
            )
        }

        queue.put(notification)

        preferences.edit()
            .putString(
                QUEUE_KEY,
                queue.toString(),
            )
            .apply()

        Log.d(
            TAG,
            "GPay split notification saved to queue"
        )
    }
}