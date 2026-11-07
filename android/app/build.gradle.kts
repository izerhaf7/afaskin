import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: create android/key.properties (never commit it), e.g.
//   storeFile=/path/to/afaskin-release.jks
//   storePassword=...
//   keyAlias=afaskin
//   keyPassword=...
// Without it, release builds fall back to the debug key (fine for demos,
// not for publishing).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "id.ac.ipb.trk.afaskin"
    // permission_handler_android 14 requires compiling against SDK 37. Compile
    // SDK only affects which APIs are visible at build time; minSdk (24) and
    // targetSdk (runtime behavior) are unchanged.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "id.ac.ipb.trk.afaskin"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8 meng-obfuscate kelas internal ML Kit pada build release
            // (build/app/outputs/mapping/release/mapping.txt:
            // com.google.mlkit.vision.common.InputImage -> b). Akibatnya
            // InputImage.fromByteArray melempar NullPointerException di
            // InputImageConverter, deteksi wajah tidak pernah menghasilkan
            // status, dan tombol shutter tidak pernah aktif. Debug tidak
            // terkena karena tidak menjalankan R8. Dimatikan sampai ada
            // proguard-rules.pro yang benar-benar menjaga ML Kit dan TFLite.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
