import java.util.Properties
import java.io.FileInputStream


plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 명시적 타입 지정으로 재귀적 타입 검사 문제 해결
val keyStoreProperties = Properties().apply {
    val keyStoreFile = rootProject.file("key.properties")
    if (keyStoreFile.exists()) {
        load(FileInputStream(keyStoreFile))
    }
}

android {
    namespace = "com.tomorrowcho.test"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tomorrowcho.test"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // 디버그 설정 수정
        getByName("debug") {
            // 디버그 키스토어 사용 안함 (자동으로 기본 디버그 키를 사용하게 함)
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
        
        // key.properties가 있을 때만 릴리스 설정 적용
        val keyStoreFile = rootProject.file("key.properties")
        if (keyStoreFile.exists()) {
            create("release") {
                storeFile = file(keyStoreProperties.getProperty("storeFile"))
                storePassword = keyStoreProperties.getProperty("storePassword")
                keyAlias = keyStoreProperties.getProperty("keyAlias")
                keyPassword = keyStoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // key.properties가 있을 때만 릴리스 서명 설정 적용
            if (rootProject.file("key.properties").exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
