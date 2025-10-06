package com.mahbub.admobwithkmp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.google.android.gms.ads.MobileAds
import com.mahbub.admobwithkmp.AdMob.AndroidActivityHolder
import com.mahbub.admobwithkmp.AdMob.ConsentManager

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        // Initialize Google Mobile Ads SDK
        ConsentManager(this){
            MobileAds.initialize(this)
        }
        AndroidActivityHolder.current = this

        setContent {
            App()
        }
    }

    override fun onResume() {
        super.onResume()
        AndroidActivityHolder.current = this
    }

    override fun onPause() {
        AndroidActivityHolder.current = null
        super.onPause()
    }
}

@Preview
@Composable
fun AppAndroidPreview() {
    App()
}