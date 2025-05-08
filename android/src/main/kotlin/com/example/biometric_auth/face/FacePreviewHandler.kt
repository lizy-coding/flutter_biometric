package com.example.biometric_auth.face

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.SurfaceTexture
import android.util.Log
import android.util.Size
import android.view.Surface
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import java.util.concurrent.Executor
import java.util.concurrent.Executors

/**
 * 人脸预览处理器 - 负责相机预览和纹理共享
 */
class FacePreviewHandler(
    private val context: Context,
    private val activity: Activity,
    private val textureRegistry: TextureRegistry
) {
    companion object {
        private const val TAG = "FacePreviewHandler"
        private const val REQUEST_CAMERA_PERMISSION = 10
    }

    private var flutterTexture: TextureRegistry.SurfaceTextureEntry? = null
    private var camera: Camera? = null
    private var cameraExecutor: Executor = Executors.newSingleThreadExecutor()
    private var cameraProvider: ProcessCameraProvider? = null

    /**
     * 处理Flutter方法调用
     */
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startFacePreview" -> {
                startPreview(result)
            }
            "stopFacePreview" -> {
                stopPreview()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 启动相机预览
     */
    private fun startPreview(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.CAMERA),
                REQUEST_CAMERA_PERMISSION
            )
            result.error("PERMISSION_DENIED", "Camera permission is not granted", null)
            return
        }

        try {
            // 创建Flutter纹理
            flutterTexture = textureRegistry.createSurfaceTexture()
            val surfaceTexture = flutterTexture!!.surfaceTexture()
            
            // 设置纹理大小
            surfaceTexture.setDefaultBufferSize(640, 480)
            
            // 获取纹理ID
            val textureId = flutterTexture!!.id()
            
            // 启动相机
            startCamera(surfaceTexture)
            
            // 返回纹理ID给Flutter
            result.success(textureId.toInt())
        } catch (e: Exception) {
            Log.e(TAG, "Error starting preview: ${e.message}")
            result.error("CAMERA_ERROR", "Failed to start camera preview: ${e.message}", null)
        }
    }

    /**
     * 启动相机
     */
    private fun startCamera(surfaceTexture: SurfaceTexture) {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                // 获取ProcessCameraProvider
                cameraProvider = cameraProviderFuture.get()
                
                // 设置预览
                val preview = Preview.Builder()
                    .setTargetResolution(Size(640, 480))
                    .build()
                
                // 设置相机选择器（前置摄像头）
                val cameraSelector = CameraSelector.Builder()
                    .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                    .build()
                
                // 设置预览输出
                val surface = Surface(surfaceTexture)
                preview.setSurfaceProvider { request ->
                    request.provideSurface(surface, cameraExecutor) { }
                }
                
                // 绑定相机
                camera = cameraProvider?.bindToLifecycle(
                    activity as LifecycleOwner,
                    cameraSelector,
                    preview
                )
            } catch (e: Exception) {
                Log.e(TAG, "Camera binding failed", e)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    /**
     * 停止相机预览
     */
    fun stopPreview() {
        try {
            cameraProvider?.unbindAll()
            flutterTexture?.release()
            flutterTexture = null
            camera = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping preview: ${e.message}")
        }
    }
}