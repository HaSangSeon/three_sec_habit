package com.dexterous.flutterlocalnotifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.annotation.Keep

/**
 * 기기 시간 설정 변경(TIME_SET) 및 타임존 변경(TIMEZONE_CHANGED) 시
 * 예약된 로컬 알림을 재스케줄링하는 리시버
 */
@Keep
class TimeChangeBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action == Intent.ACTION_TIME_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED
        ) {
            FlutterLocalNotificationsPlugin.rescheduleNotifications(context)
        }
    }
}

