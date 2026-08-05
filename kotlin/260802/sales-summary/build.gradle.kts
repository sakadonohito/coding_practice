plugins {
    kotlin("jvm") version "2.4.0"
    application
    id("org.jlleitschuh.gradle.ktlint") version "12.1.2" // ★ これを追記
}

group = "example"
version = "0.1.0"

repositories {
    mavenCentral()
}

kotlin {
    jvmToolchain(21)
}

application {
    mainClass.set("sales.MainKt")
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.14.4")
}

tasks.test {
    useJUnitPlatform()

    testLogging {
        events("passed", "skipped", "failed")
    }
}
