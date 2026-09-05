package com.hasangseon.three_sec_habit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundReceiver
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HabitWidgetProvider4x2 : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout_4x2).apply {
                // 상단 헤더 누르면 앱 메인 실행
                val headerIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_4x2_header, headerIntent)

                // 테마 모드 판단 (앱 설정 및 시스템 다크모드 연동)
                val themeMode = widgetData.getString("widget_theme_mode", "system") ?: "system"
                val isSystemDark = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES
                val isDark = when (themeMode) {
                    "dark" -> true
                    "light" -> false
                    else -> isSystemDark
                }

                // 배경 및 칩 Drawable 동적 적용
                setInt(
                    R.id.widget_root_4x2,
                    "setBackgroundResource",
                    if (isDark) R.drawable.widget_background_dark else R.drawable.widget_background_light
                )
                setInt(
                    R.id.widget_4x2_progress_summary,
                    "setBackgroundResource",
                    if (isDark) R.drawable.widget_success_chip_bg_dark else R.drawable.widget_success_chip_bg_light
                )

                setTextColor(
                    R.id.widget_4x2_title,
                    if (isDark) 0xFFA78BFA.toInt() else 0xFF7C3AED.toInt()
                )

                val summary = widgetData.getString("widget_4x2_summary", "0 / 0 완료") ?: "0 / 0 완료"
                setTextViewText(R.id.widget_4x2_progress_summary, summary)
                setTextColor(
                    R.id.widget_4x2_progress_summary,
                    if (isDark) 0xFF34D399.toInt() else 0xFF059669.toInt()
                )

                setInt(
                    R.id.widget_4x2_divider,
                    "setBackgroundColor",
                    if (isDark) 0xFF1E293B.toInt() else 0xFFF1F5F9.toInt()
                )

                setTextColor(
                    R.id.widget_empty_view,
                    if (isDark) 0xFF64748B.toInt() else 0xFF94A3B8.toInt()
                )

                // RemoteViewsService 연결
                val serviceIntent = Intent(context, HabitListWidgetService::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
                }
                setRemoteAdapter(R.id.widget_list_view, serviceIntent)
                setEmptyView(R.id.widget_list_view, R.id.widget_empty_view)

                // 리스트 아이템 클릭 템플릿 (FLAG_MUTABLE 필수)
                val templateIntent = Intent(context, HomeWidgetBackgroundReceiver::class.java).apply {
                    action = "es.antonborri.home_widget.action.BACKGROUND"
                }
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                val pendingIntentTemplate = PendingIntent.getBroadcast(context, 0, templateIntent, flags)
                setPendingIntentTemplate(R.id.widget_list_view, pendingIntentTemplate)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list_view)
        }
    }
}
