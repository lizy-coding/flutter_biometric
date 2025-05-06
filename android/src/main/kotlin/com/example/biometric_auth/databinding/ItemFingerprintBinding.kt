package com.example.biometric_auth.databinding

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import com.example.flutter_biometric.R

/**
 * 指纹列表项的视图绑定类
 */
class ItemFingerprintBinding(val root: View) {
    val textFingerprintName: TextView = root.findViewById(R.id.textFingerprintName)
    val buttonDelete: Button = root.findViewById(R.id.buttonDelete)

    companion object {
        fun inflate(inflater: LayoutInflater, parent: ViewGroup?, attachToParent: Boolean): ItemFingerprintBinding {
            val view = inflater.inflate(R.layout.item_fingerprint, parent, attachToParent)
            return ItemFingerprintBinding(view)
        }
    }
} 