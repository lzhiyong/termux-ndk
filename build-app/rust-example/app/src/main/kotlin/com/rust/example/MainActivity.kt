package com.rust.example

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import com.rust.example.databinding.ActivityMainBinding

public class MainActivity : AppCompatActivity() {

    private var _binding: ActivityMainBinding? = null
    
    private val binding: ActivityMainBinding
      get() = checkNotNull(_binding) { "Activity has been destroyed" }
    
    private val TAG = this::class.simpleName
    
    companion object {
        init {
            // load the libnative.so from rust
            System.loadLibrary("rust")
        }
        
        // JNI fun
        external fun stringFromRust(): String
        
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inflate and get instance of binding
        _binding = ActivityMainBinding.inflate(layoutInflater)

        // set content view to binding's root
        setContentView(binding.root)
        
        binding.textView.setText(stringFromRust())
        
        Log.i(TAG, "rust-jni-example")      
    }
    
    override fun onDestroy() {
        super.onDestroy()
        _binding = null
    }
}
