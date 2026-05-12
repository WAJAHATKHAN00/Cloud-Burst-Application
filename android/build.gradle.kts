import org.gradle.api.Project

plugins {
    // ...

    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.4" apply false

}

val forcedNdkVersion = "27.0.12077973"

fun Project.forceAndroidNdkVersion(version: String) {
    extensions.findByName("android")?.let { androidExtension ->
        androidExtension.javaClass.methods
            .firstOrNull { it.name == "setNdkVersion" && it.parameterCount == 1 }
            ?.invoke(androidExtension, version)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    plugins.withId("com.android.application") {
        forceAndroidNdkVersion(forcedNdkVersion)
    }

    plugins.withId("com.android.library") {
        forceAndroidNdkVersion(forcedNdkVersion)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
