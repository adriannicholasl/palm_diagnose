// android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.0") // ✅ Sesuaikan versi
        classpath("com.google.gms:google-services:4.4.1") // ✅ Plugin Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Opsional - jika kamu ingin mengatur folder build kustom
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
