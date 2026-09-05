package com.hasangseon.three_sec_habit

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class HabitListWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return HabitListRemoteViewsFactory(this.applicationContext, intent)
    }
}

class HabitListRemoteViewsFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var habits: List<HabitWidgetItem> = listOf()

    data class HabitWidgetItem(
        val id: Int,
        val title: String,
        val btnText: String,
        val isDone: Boolean
    )

    override fun onCreate() {
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonStr = widgetData.getString("widget_habits_json", "[]") ?: "[]"
        try {
            val jsonArray = JSONArray(jsonStr)
            val list = mutableListOf<HabitWidgetItem>()
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val isDone = obj.getBoolean("isDone")
                list.add(
                    HabitWidgetItem(
                        id = obj.getInt("id"),
                        title = obj.getString("title"),
                        btnText = obj.optString("btnText", if (isDone) "✓" else "○"),
                        isDone = isDone
                    )
                )
            }
            habits = list
        } catch (e: Exception) {
            habits = listOf()
        }
    }

    override fun onDestroy() {
        habits = listOf()
    }

    override fun getCount(): Int = habits.size

    override fun getViewAt(position: Int): RemoteViews {
        if (position !in habits.indices) {
            return RemoteViews(context.packageName, R.layout.widget_item_habit)
        }

        val item = habits[position]
        val views = RemoteViews(context.packageName, R.layout.widget_item_habit)

        // 테마 모드 판단 (앱 설정 및 시스템 다크모드 연동)
        val widgetData = HomeWidgetPlugin.getData(context)
        val themeMode = widgetData.getString("widget_theme_mode", "system") ?: "system"
        val isSystemDark = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES
        val isDark = when (themeMode) {
            "dark" -> true
            "light" -> false
            else -> isSystemDark
        }

        // 아이템 카드 배경 동적 적용
        views.setInt(
            R.id.widget_item_root,
            "setBackgroundResource",
            if (isDark) R.drawable.widget_card_bg_dark else R.drawable.widget_card_bg_light
        )

        views.setTextViewText(R.id.widget_item_title, item.title)
        views.setTextColor(
            R.id.widget_item_title,
            if (isDark) 0xFFF8FAFC.toInt() else 0xFF0F172A.toInt()
        )

        views.setTextViewText(R.id.widget_item_check_btn, item.btnText)

        val checkColor = if (item.isDone) {
            if (isDark) 0xFF34D399.toInt() else 0xFF059669.toInt()
        } else {
            if (isDark) 0xFFA78BFA.toInt() else 0xFF7C3AED.toInt()
        }
        views.setTextColor(R.id.widget_item_check_btn, checkColor)

        // FillInIntent: 백그라운드 토글 액션 브로드캐스트로 전달
        val fillInIntent = Intent().apply {
            action = "es.antonborri.home_widget.action.BACKGROUND"
            setPackage(context.packageName)
            data = Uri.parse("habit3sec://toggle/${item.id}?id=${item.id}")
        }
        views.setOnClickFillInIntent(R.id.widget_item_check_btn, fillInIntent)
        views.setOnClickFillInIntent(R.id.widget_item_root, fillInIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long {
        return if (position in habits.indices) habits[position].id.toLong() else position.toLong()
    }

    override fun hasStableIds(): Boolean = true
}
