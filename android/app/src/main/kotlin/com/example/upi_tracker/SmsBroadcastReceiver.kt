package com.example.upi_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SmsBroadcastReceiver"

        const val ACTION_NEW_SMS =
            "com.example.upi_tracker.NEW_SMS"

        const val EXTRA_SENDER = "sender"
        const val EXTRA_BODY = "body"
        const val EXTRA_TIMESTAMP = "timestamp"
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            return
        }

        val messages =
            Telephony.Sms.Intents.getMessagesFromIntent(intent)

        if (messages.isNullOrEmpty()) {
            return
        }

        /*
         * A single SMS can contain multiple PDUs.
         * Combine their bodies into one logical message.
         */
        val body = buildString {
            messages.forEach { message ->
                append(message.messageBody ?: "")
            }
        }.trim()

        if (body.isEmpty()) {
            return
        }

        val sender = messages.firstOrNull()
            ?.originatingAddress
            .orEmpty()

        val timestamp = messages.firstOrNull()
            ?.timestampMillis
            ?: System.currentTimeMillis()

        Log.d(
            TAG,
            "Incoming SMS from=$sender"
        )

        /*
         * Send a private application broadcast.
         *
         * The Flutter side will listen for this event.
         */
        val newSmsIntent = Intent(ACTION_NEW_SMS).apply {
            setPackage(context.packageName)

            putExtra(
                EXTRA_SENDER,
                sender
            )

            putExtra(
                EXTRA_BODY,
                body
            )

            putExtra(
                EXTRA_TIMESTAMP,
                timestamp
            )
        }

        context.sendBroadcast(newSmsIntent)
    }
}