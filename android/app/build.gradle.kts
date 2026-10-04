plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.art_collection_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.art_collection_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Fix for file lock issues on Windows - disable clean tasks that cause problems
tasks.configureEach {
    if (name.contains("cleanMergeDebugAssets") || name.contains("cleanMergeReleaseAssets")) {
        enabled = false
    }
}

// Alternative: Skip clean if files are locked
tasks.whenTaskAdded {
    if (name.contains("cleanMergeDebugAssets") || name.contains("cleanMergeReleaseAssets")) {
        doFirst {
            try {
                Thread.sleep(1000)
            } catch (e: Exception) {
                // Ignore if clean fails, continue with build
            }
        }
        doLast {
            // Continue even if clean fails
        }
    }
}

flutter {
    source = "../.."
}
