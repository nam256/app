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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Fix for Windows file lock issues - disable clean tasks globally
subprojects {
    tasks.configureEach {
        // Disable clean tasks that cause file lock
        if (name.contains("clean") && (name.contains("Merge") || name.contains("bundleLib"))) {
            enabled = false
        }
    }
    
    // Fix for bundleLibRuntimeToDirDebug "Not a directory" errors
    // Use whenTaskAdded instead of afterEvaluate to avoid evaluation timing issues
    tasks.whenTaskAdded {
        if (name.contains("preBuild") || name == "assembleDebug" || name == "assembleRelease") {
            doFirst {
                try {
                    val buildDir = project.layout.buildDirectory.get().asFile
                    if (buildDir.exists()) {
                        // Find and remove any files named bundleLibRuntimeToDirDebug/Release that should be directories
                        buildDir.walkTopDown().forEach { file ->
                            if ((file.name == "bundleLibRuntimeToDirDebug" || file.name == "bundleLibRuntimeToDirRelease") 
                                && file.exists() && !file.isDirectory) {
                                file.delete()
                            }
                        }
                    }
                } catch (e: Exception) {
                    // Ignore cleanup errors, continue with build
                }
            }
        }
    }
}