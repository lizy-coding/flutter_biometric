package com.example.biometric_auth.ui

import android.annotation.SuppressLint
import android.content.Context
import androidx.camera.core.CameraX
import androidx.camera.core.Preview
import androidx.camera.core.UseCaseGroup
import androidx.camera.core.impl.utils.executor.CameraXExecutors

class Camera2PreviewManager(context: Context) {

    @SuppressLint("RestrictedApi")
    private var cameraX: CameraX? = null
    private var preview: Preview? = null

    fun startPreview() {
        // TODO: 实现相机预览启动逻辑
    }

    fun stopPreview() {
        // TODO: 实现相机预览停止逻辑
    }

    @SuppressLint("RestrictedApi")
    fun release() {
        stopPreview()
        cameraX?.shutdown()
    }
}