package com.example.biometric_auth.ui

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.View
import androidx.core.graphics.toColorInt

class CircleHoleView(context: Context, attrs: AttributeSet? = null) : View(context, attrs) {

    private val paint = Paint().apply {
        isAntiAlias = true
        color = Color.BLACK
        style = Paint.Style.FILL
    }

    @SuppressLint("DrawAllocation")
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        // 绘制背景
        canvas.drawColor("#80000000".toColorInt())
        // 计算圆形区域
        val centerX = width / 2f
        val centerY = height / 2f
        val radius = (width.coerceAtMost(height) * 0.4).toFloat()
        // 绘制透明圆形
        paint.xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.CLEAR)
        canvas.drawCircle(centerX, centerY, radius, paint)
    }
}