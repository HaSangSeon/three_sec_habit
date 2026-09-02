package com.hasangseon.three_sec_habit

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
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

        views.setTextViewText(R.id.widget_item_title, item.title)
        views.setTextViewText(R.id.widget_item_check_btn, item.btnText)

        if (item.isDone) {
            views.setTextColor(R.id.widget_item_check_btn, Color.parseColor("#10B981"))
        } else {
            views.setTextColor(R.id.widget_item_check_btn, Color.parseColor("#8B5CF6"))
        }

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
