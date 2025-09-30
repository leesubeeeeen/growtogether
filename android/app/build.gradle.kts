// 🔹 반드시 파일 최상단(plugins 블록보다 위)에 import
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// 🔐 keystore.properties 로드
val keystorePropsFile = rootProject.file("keystore.properties")
val keystoreProps: Properties = Properties().also { props ->
    if (keystorePropsFile.exists()) {
        keystorePropsFile.inputStream().use { fis ->
            props.load(fis)   // ← 스코프 충돌 없이 안전
        }
    }
}

android {
    namespace = "com.cnu.growtogether"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        applicationId = "com.cnu.growtogether"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (!keystoreProps.isEmpty) {
                val store = requireNotNull(keystoreProps.getProperty("storeFile")) { "missing storeFile" }
                val storePass = requireNotNull(keystoreProps.getProperty("storePassword")) { "missing storePassword" }
                val alias = requireNotNull(keystoreProps.getProperty("keyAlias")) { "missing keyAlias" }
                val keyPass = requireNotNull(keystoreProps.getProperty("keyPassword")) { "missing keyPassword" }

                storeFile = file(store)
                storePassword = storePass
                keyAlias = alias
                keyPassword = keyPass
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter { source = "../.." }
