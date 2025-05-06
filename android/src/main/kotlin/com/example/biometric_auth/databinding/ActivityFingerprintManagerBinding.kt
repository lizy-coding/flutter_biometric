package com.example.biometric_auth.databinding

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.RecyclerView
import com.example.flutter_biometric.R

/**
 * 手动实现的 FingerprintManagerActivity 的视图绑定类
 */
class ActivityFingerprintManagerBinding(val root: View) {
    val toolbar: Toolbar = root.findViewById(R.id.toolbar)
    val recyclerViewFingerprints: RecyclerView = root.findViewById(R.id.recyclerViewFingerprints)
    val buttonAddFingerprint: Button = root.findViewById(R.id.buttonAddFingerprint)
    val buttonClearFingerprints: Button = root.findViewById(R.id.buttonClearFingerprints)
    val buttonChangePassword: Button = root.findViewById(R.id.buttonChangePassword)
    val textFingerprintCount: TextView = root.findViewById(R.id.textFingerprintCount)

    companion object {
        fun inflate(inflater: LayoutInflater, parent: ViewGroup?, attachToParent: Boolean): ActivityFingerprintManagerBinding {
            val view = inflater.inflate(R.layout.activity_fingerprint_manager, parent, attachToParent)
            return ActivityFingerprintManagerBinding(view)
        }
    }
} 