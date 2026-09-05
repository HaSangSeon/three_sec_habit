package com.hasangseon.three_sec_habit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
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

                // 테마 모드 판단 (앱 설정 및 시스템 다크모드 연동)
                val themeMode = widgetData.getString("widget_theme_mode", "system") ?: "system"
                val isSystemDark = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES
                val isDark = when (themeMode) {
                    "dark" -> true
                    "light" -> false
                    else -> isSystemDark
                }

                // 배경 및 카드 Drawable 동적 적용
                setInt(
                    R.id.widget_root_2x2,
                    "setBackgroundResource",
                    if (isDark) R.drawable.widget_background_dark else R.drawable.widget_background_light
                )
                setInt(
                    R.id.widget_2x2_quick_check_btn,
                    "setBackgroundResource",
                    if (isDark) R.drawable.widget_card_bg_dark else R.drawable.widget_card_bg_light
                )
                setInt(
                    R.id.widget_2x2_percent_text,
                    "setBackgroundResource",
                    if (isDark) R.drawable.widget_success_chip_bg_dark else R.drawable.widget_success_chip_bg_light
                )

                // SharedPreferences 데이터 읽기
                val progressText = widgetData.getString("widget_progress_text", "0 / 0") ?: "0 / 0"
                val percentText = widgetData.getString("widget_percent_text", "0% 완료") ?: "0% 완료"
                val dateStr = widgetData.getString("widget_date_str", "오늘") ?: "오늘"
                val topHabitTitle = widgetData.getString("widget_top_habit_title", "습관 만들기") ?: "습관 만들기"
                val topHabitId = widgetData.getInt("widget_top_habit_id", -1)
                val topHabitDone = widgetData.getBoolean("widget_top_habit_done", false)

                // 텍스트 및 색상 적용
                setTextViewText(R.id.widget_2x2_progress_text, progressText)
                setTextColor(
                    R.id.widget_2x2_progress_text,
                    if (isDark) 0xFFF8FAFC.toInt() else 0xFF0F172A.toInt()
                )

                setTextViewText(R.id.widget_2x2_percent_text, percentText)
                setTextColor(
                    R.id.widget_2x2_percent_text,
                    if (isDark) 0xFF34D399.toInt() else 0xFF059669.toInt()
                )

                setTextViewText(R.id.widget_2x2_date, dateStr)
                setTextColor(
                    R.id.widget_2x2_date,
                    if (isDark) 0xFF94A3B8.toInt() else 0xFF64748B.toInt()
                )

                setTextViewText(R.id.widget_2x2_quick_title, topHabitTitle)
                setTextColor(
                    R.id.widget_2x2_quick_title,
                    if (isDark) 0xFFF8FAFC.toInt() else 0xFF0F172A.toInt()
                )

                val topHabitBtnText = widgetData.getString("widget_top_habit_btn_text", if (topHabitDone) "✓" else "○") ?: "○"
                setTextViewText(R.id.widget_2x2_check_icon, topHabitBtnText)

                val checkColor = if (topHabitDone) {
                    if (isDark) 0xFF34D399.toInt() else 0xFF059669.toInt()
                } else {
                    if (isDark) 0xFFA78BFA.toInt() else 0xFF7C3AED.toInt()
                }
                setTextColor(R.id.widget_2x2_check_icon, checkColor)

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
