package com.example.biometric_auth.ui

import android.annotation.SuppressLint
import android.content.Context
import android.view.View
import androidx.camera.core.CameraX

class CameraPlatformView(context: Context) : View(context) {

    @SuppressLint("RestrictedApi")
    private var cameraX: CameraX? = null

    init {
        // 初始化相机预览
        initCamera()
    }

    private fun initCamera() {
        // TODO: 实现相机初始化逻辑
    }

    fun startPreview() {
        // TODO: 实现启动预览逻辑
    }

    fun stopPreview() {
        // TODO: 实现停止预览逻辑
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopPreview()
    }
}