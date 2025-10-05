package com.mahbub.admobwithkmp

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.safeContentPadding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import org.jetbrains.compose.resources.painterResource
import org.jetbrains.compose.ui.tooling.preview.Preview

import admobwithkmp.composeapp.generated.resources.Res
import admobwithkmp.composeapp.generated.resources.compose_multiplatform
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Surface
import androidx.compose.ui.unit.dp
import com.mahbub.admobwithkmp.AdMob.AdMobBanner
import com.mahbub.admobwithkmp.AdMob.AdMobInlineAdaptiveBanner
import com.mahbub.admobwithkmp.AdMob.showInterstitialAd
import com.mahbub.admobwithkmp.AdMob.showRewardedAd
import kotlinx.coroutines.launch

@Composable
@Preview
fun App() {
    val scope = rememberCoroutineScope()
    var rewardMessage by remember { mutableStateOf("") }
    var points by remember { mutableStateOf(0) }
    MaterialTheme {
        Column(
            modifier = Modifier
                .background(MaterialTheme.colorScheme.primaryContainer)
                .safeContentPadding()
                .padding(16.dp)
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {


            Spacer(modifier = Modifier.height(8.dp))
            AdMobBanner(modifier = Modifier.fillMaxWidth())



            Spacer(modifier = Modifier.height(16.dp))
            Button(onClick = {
                showInterstitialAd()
            }) {
                Text("Show Interstitial Ad")
            }

            Button(onClick = {
                scope.launch {
                    val earnedPoints = showRewardedAd()
                    points += earnedPoints
                    rewardMessage =
                        if (earnedPoints > 0) "You earned $earnedPoints points" else "No reward"
                }
            }) {
                Text("Show Reword Video Ad")
            }

            Spacer(modifier = Modifier.height(8.dp))
            if (rewardMessage.isNotEmpty()) {
                Text(rewardMessage)
            }

            Spacer(modifier = Modifier.height(8.dp))
            Text("Total points: $points")

            Spacer(modifier = Modifier.height(16.dp))
            AdMobInlineAdaptiveBanner(modifier = Modifier.fillMaxSize())

        }
    }
}