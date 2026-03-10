plugins {
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.apache.kafka:kafka-streams:4.2.0")
    implementation("org.slf4j:slf4j-simple:2.0.17")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(25))
    }
}

application {
    mainClass.set("com.example.kafkastreams.SimpleStreamApp")
}

tasks.withType<JavaCompile>().configureEach {
    options.encoding = "UTF-8"
}
