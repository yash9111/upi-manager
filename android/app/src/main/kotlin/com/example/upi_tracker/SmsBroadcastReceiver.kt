package com.example.upi_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID
import android.util.Log

class SmsBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val PREFS_NAME =
            "upi_tracker_sms_queue"

        private const val QUEUE_KEY =
            "pending_sms"

        private const val MAX_QUEUE_SIZE = 500
    }

   override fun onReceive(
    context: Context,
    intent: Intent
) {
    Log.d(
        "UPI_SMS",
        "Broadcast received: ${intent.action}"
    )

    if (
        intent.action !=
        Telephony.Sms.Intents.SMS_RECEIVED_ACTION
    ) {
        Log.d(
            "UPI_SMS",
            "Ignoring unrelated broadcast"
        )
        return
    }

    val messages =
        Telephony.Sms.Intents
            .getMessagesFromIntent(intent)

    Log.d(
        "UPI_SMS",
        "Messages received: ${messages?.size ?: 0}"
    )

    if (messages.isNullOrEmpty()) {
        return
    }

    val body = buildString {
        messages.forEach { message ->
            append(message.messageBody ?: "")
        }
    }.trim()

    val sender =
        messages.firstOrNull()
            ?.originatingAddress
            .orEmpty()

    val timestamp =
        messages.firstOrNull()
            ?.timestampMillis
            ?: System.currentTimeMillis()

    Log.d(
        "UPI_SMS",
        "Sender: $sender"
    )

    Log.d(
        "UPI_SMS",
        "Body: $body"
    )

    saveToPendingQueue(
        context = context,
        sender = sender,
        body = body,
        timestamp = timestamp,
    )

    Log.d(
        "UPI_SMS",
        "SMS saved to native queue"
    )
}
    private fun saveToPendingQueue(
        context: Context,
        sender: String,
        body: String,
        timestamp: Long,
    ) {
        val preferences =
            context.getSharedPreferences(
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

        val sms = JSONObject().apply {
            put(
                "id",
                UUID.randomUUID().toString(),
            )

            put(
                "sender",
                sender,
            )

            put(
                "body",
                body,
            )

            put(
                "timestamp",
                timestamp,
            )
        }

        queue.put(sms)
Log.d(
    "UPI_SMS",
    "Saving SMS to queue"
)
        preferences.edit()
            .putString(
                QUEUE_KEY,
                queue.toString(),
            )
            .apply()
    }
}