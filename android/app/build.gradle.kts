plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dispatcher"
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
        applicationId = "com.example.dispatcher"
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

    flavorDimensions += "app" // Correct syntax for adding a dimension

    productFlavors {
        create("dev") { // Use create() for flavors
            dimension = "app" // Use '=' for property assignment
            applicationIdSuffix = ".dev" // Use '='
            versionNameSuffix = "-dev" // Use '='
            resValue("string", "app_name", "Dispatcher(Dev)") // Use () for function call
        }
        create("prod") { // Use create() for flavors
            dimension = "app" // Use '=' for property assignment
            resValue("string", "app_name", "Dispatcher") // Use () for function call
        }
    }
}



flutter {
    source = "../.."
}
