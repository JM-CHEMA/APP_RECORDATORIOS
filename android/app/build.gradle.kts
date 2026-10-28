
plugins {
    id("com.android.application")

    // Configuración de Firebase.
    id("com.google.gms.google-services")

    // Integración de Flutter con Gradle.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_lab"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Habilita las API modernas de Java para las notificaciones locales.
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.app_lab"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Firma de desarrollo. Sustituir para publicar la aplicación.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// Biblioteca requerida para la compatibilidad de notificaciones.
dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}

flutter {
    source = "../.."
}
