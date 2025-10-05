package com.mahbub.admobwithkmp

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform