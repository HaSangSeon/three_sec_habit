package com.hasangseon.three_sec_habit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HabitWidgetProvider2x2 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout_2x2).apply {
                // 앱 실행 PendingIntent 연결
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root_2x2, pendingIntent)

                // SharedPreferences 데이터 읽기
                val progressText = widgetData.getString("widget_progress_text", "0 / 0") ?: "0 / 0"
                val percentText = widgetData.getString("widget_percent_text", "0% 완료") ?: "0% 완료"
                val dateStr = widgetData.getString("widget_date_str", "오늘") ?: "오늘"
                val topHabitTitle = widgetData.getString("widget_top_habit_title", "습관 만들기") ?: "습관 만들기"
                val topHabitId = widgetData.getInt("widget_top_habit_id", -1)
                val topHabitDone = widgetData.getBoolean("widget_top_habit_done", false)

                setTextViewText(R.id.widget_2x2_progress_text, progressText)
                setTextViewText(R.id.widget_2x2_percent_text, percentText)
                setTextViewText(R.id.widget_2x2_date, dateStr)
                setTextViewText(R.id.widget_2x2_quick_title, topHabitTitle)

                val topHabitBtnText = widgetData.getString("widget_top_habit_btn_text", if (topHabitDone) "✓" else "○") ?: "○"
                setTextViewText(R.id.widget_2x2_check_icon, topHabitBtnText)
                if (topHabitDone) {
                    setTextColor(R.id.widget_2x2_check_icon, android.graphics.Color.parseColor("#10B981"))
                } else {
                    setTextColor(R.id.widget_2x2_check_icon, android.graphics.Color.parseColor("#8B5CF6"))
                }

                // 빠른 체크 버튼 클릭 시 백그라운드 콜백 URI 전송 (고유 path 지정)
                if (topHabitId != -1) {
                    val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("habit3sec://toggle/$topHabitId?id=$topHabitId")
                    )
                    setOnClickPendingIntent(R.id.widget_2x2_quick_check_btn, backgroundIntent)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
