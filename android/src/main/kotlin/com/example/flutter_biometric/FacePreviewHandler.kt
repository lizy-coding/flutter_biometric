package com.example.flutter_biometric

import android.content.Context
import android.util.Log
import android.util.Size
import android.view.Surface
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.LifecycleOwner
import io.flutter.view.TextureRegistry
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/**
 * 人脸预览处理器
 * 负责管理相机预览并将预览帧共享给Flutter
 */
class FacePreviewHandler(
    private val context: Context,
    private val activity: FragmentActivity,
    private val textureRegistry: TextureRegistry
) {
    companion object {
        private const val TAG = "FacePreviewHandler"
    }

    private var cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var cameraProvider: ProcessCameraProvider? = null
    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var previewSurface: Surface? = null

    /**
     * 启动人脸预览
     * @return 纹理ID，用于Flutter侧显示相机预览
     */
    suspend fun startPreview(): Int = suspendCoroutine { continuation ->
        try {
            // 获取纹理入口
            textureEntry = textureRegistry.createSurfaceTexture()
            val surfaceTexture = textureEntry?.surfaceTexture()
            
            // 设置预览尺寸
            surfaceTexture?.setDefaultBufferSize(640, 480)
            previewSurface = Surface(surfaceTexture)
            
            // 获取相机提供者
            val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
            cameraProviderFuture.addListener({
                try {
                    cameraProvider = cameraProviderFuture.get()
                    
                    // 配置相机用例
                    val preview = Preview.Builder()
                        .setTargetResolution(Size(640, 480))
                        .build()
                    
                    // 修正SurfaceProvider的设置
                    val surfaceProvider = Preview.SurfaceProvider { request ->
                        surfaceTexture?.let { texture ->
                            request.provideSurface(
                                previewSurface!!,
                                cameraExecutor
                            ) {}
                        }
                    }
                    
                    preview.setSurfaceProvider(cameraExecutor, surfaceProvider)
                    
                    // 配置图像分析
                    val imageAnalysis = ImageAnalysis.Builder()
                        .setTargetResolution(Size(640, 480))
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .build()
                        .apply {
                            setAnalyzer(cameraExecutor) { imageProxy ->
                                // 这里可以添加人脸检测逻辑
                                imageProxy.close()
                            }
                        }
                    
                    // 选择前置摄像头
                    val cameraSelector = CameraSelector.Builder()
                        .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                        .build()
                    
                    // 绑定相机用例
                    cameraProvider?.unbindAll()
                    cameraProvider?.bindToLifecycle(
                        activity as LifecycleOwner,
                        cameraSelector,
                        preview,
                        imageAnalysis
                    )
                    
                    // 返回纹理ID (确保返回Int类型)
                    continuation.resume(textureEntry?.id()?.toInt() ?: -1)
                } catch (e: Exception) {
                    Log.e(TAG, "相机预览启动失败: ${e.message}", e)
                    continuation.resume(-1)
                }
            }, ContextCompat.getMainExecutor(context))
        } catch (e: Exception) {
            Log.e(TAG, "相机预览初始化失败: ${e.message}", e)
            continuation.resume(-1)
        }
    }

    /**
     * 停止人脸预览
     */
    fun stopPreview() {
        try {
            cameraProvider?.unbindAll()
            previewSurface?.release()
            textureEntry?.release()
            textureEntry = null
            cameraExecutor.shutdown()
        } catch (e: Exception) {
            Log.e(TAG, "停止相机预览失败: ${e.message}", e)
        }
    }
} 