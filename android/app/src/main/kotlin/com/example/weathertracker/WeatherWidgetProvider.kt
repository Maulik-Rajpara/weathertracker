package com.example.weathertracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val city = widgetData.getString("city", "--")
                val temp = widgetData.getString("temp", "--")
                val desc = widgetData.getString("desc", "--")
                val wind = widgetData.getString("wind", "-- m/s")
                val humidity = widgetData.getString("humidity", "--%")
                setTextViewText(R.id.widget_city, city)
                setTextViewText(R.id.widget_temp, temp)
                setTextViewText(R.id.widget_desc, desc)
                setTextViewText(R.id.widget_wind, "Wind: $wind")
                setTextViewText(R.id.widget_humidity, "Humidity: $humidity")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
} 