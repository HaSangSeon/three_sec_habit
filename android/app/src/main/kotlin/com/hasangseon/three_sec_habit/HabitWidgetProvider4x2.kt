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

class HabitWidgetProvider4x2 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout_4x2).apply {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root_4x2, pendingIntent)

                val summary = widgetData.getString("widget_4x2_summary", "0 / 0 완료") ?: "0 / 0 완료"
                setTextViewText(R.id.widget_4x2_progress_summary, summary)

                // 3개 아이템 바인딩
                val itemLayoutIds = intArrayOf(R.id.widget_item_1, R.id.widget_item_2, R.id.widget_item_3)
                val titleIds = intArrayOf(R.id.widget_title_1, R.id.widget_title_2, R.id.widget_title_3)
                val checkBtnIds = intArrayOf(R.id.widget_check_btn_1, R.id.widget_check_btn_2, R.id.widget_check_btn_3)

                for (i in 0..2) {
                    val habitId = widgetData.getInt("widget_habit_id_$i", -1)
                    val title = widgetData.getString("widget_habit_title_$i", "") ?: ""
                    val isDone = widgetData.getBoolean("widget_habit_done_$i", false)

                    if (habitId != -1 && title.isNotEmpty()) {
                        setViewVisibility(itemLayoutIds[i], View.VISIBLE)
                        setTextViewText(titleIds[i], title)

                        if (isDone) {
                            setTextViewText(checkBtnIds[i], "✓")
                            setTextColor(checkBtnIds[i], android.graphics.Color.parseColor("#10B981"))
                        } else {
                            setTextViewText(checkBtnIds[i], "○")
                            setTextColor(checkBtnIds[i], android.graphics.Color.parseColor("#8B5CF6"))
                        }

                        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("habit3sec://toggle?id=$habitId")
                        )
                        setOnClickPendingIntent(checkBtnIds[i], backgroundIntent)
                    } else {
                        setViewVisibility(itemLayoutIds[i], View.GONE)
                    }
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
