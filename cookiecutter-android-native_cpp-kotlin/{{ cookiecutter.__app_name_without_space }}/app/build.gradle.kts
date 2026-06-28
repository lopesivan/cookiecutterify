plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "{{ cookiecutter.package_name }}"
    compileSdk {
        version = release({{ cookiecutter.target_sdk_version }}) {
            minorApiLevel = 1
        }
    }

    defaultConfig {
        applicationId = "{{ cookiecutter.package_name }}"
        minSdk = {{ cookiecutter.min_sdk_version }}
        targetSdk = {{ cookiecutter.target_sdk_version }}
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        externalNativeBuild {
            cmake {
                cppFlags += "-std=c++{{ cookiecutter.cpp_version }}"
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "{{ cookiecutter.cmake_version }}"
        }
    }
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.core.ktx)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.androidx.junit)
}