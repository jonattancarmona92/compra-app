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
}

// El plugin bluetooth_print_plus declara compileSdk 31 en su propio
// android {} (Groovy clásico), pero las AAR de androidx que arrastra exigen
// API 34+. Se registra el override justo antes de que el módulo evalúe (así
// se ejecuta después de su bloque pero antes de que AGP finalice las
// variantes) para superar el chequeo de AAR metadata.
gradle.beforeProject {
    if (this.name == "bluetooth_print_plus") {
        afterEvaluate {
            extensions.getByName("android")?.let { androidExtension ->
                if (androidExtension is com.android.build.gradle.LibraryExtension) {
                    androidExtension.compileSdk = 36
                }
            }
        }
    }
}

// Algunos plugins (secured_storage, flutter_bluetooth_serial, printing, etc.)
// aún compilan con Java 8, obsoleto en JDK 17+. Se fuerza Java 17 en el
// compileOptions de cada módulo Android para eliminar los warnings
// `source/target value 8 is obsolete` sin tocar el pub-cache.
gradle.beforeProject {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
            ?.compileOptions?.let { options ->
                options.sourceCompatibility = org.gradle.api.JavaVersion.VERSION_17
                options.targetCompatibility = org.gradle.api.JavaVersion.VERSION_17
            }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
