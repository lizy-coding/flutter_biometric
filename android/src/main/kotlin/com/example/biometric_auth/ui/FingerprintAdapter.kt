package com.example.biometric_auth.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.biometric_auth.databinding.ItemFingerprintBinding

/**
 * 指纹列表适配器
 */
class FingerprintAdapter(
    private val fingerprints: List<String>,
    private val onDeleteClick: (Int) -> Unit
) : RecyclerView.Adapter<FingerprintAdapter.FingerprintViewHolder>() {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): FingerprintViewHolder {
        val binding = ItemFingerprintBinding.inflate(
            LayoutInflater.from(parent.context), 
            parent, 
            false
        )
        return FingerprintViewHolder(binding)
    }
    
    override fun onBindViewHolder(holder: FingerprintViewHolder, position: Int) {
        holder.bind(fingerprints[position], position)
    }
    
    override fun getItemCount(): Int = fingerprints.size
    
    inner class FingerprintViewHolder(private val binding: ItemFingerprintBinding) : 
        RecyclerView.ViewHolder(binding.root) {
        
        fun bind(fingerprintName: String, position: Int) {
            binding.textFingerprintName.text = fingerprintName
            binding.buttonDelete.setOnClickListener {
                onDeleteClick(position)
            }
        }
    }
} 