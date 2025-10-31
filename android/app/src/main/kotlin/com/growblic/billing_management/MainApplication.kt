package com.growblic.billing_management

import android.app.Application
import androidx.multidex.MultiDex
import androidx.multidex.MultiDexApplication

class MainApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        MultiDex.install(this)
    }
}


