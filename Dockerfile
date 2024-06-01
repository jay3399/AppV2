FROM openjdk:17-jdk-alpine

COPY --platform=$TARGETPLATFORM openjdk:17-jdk-alpine AS builder

ENTRYPOINT ["java", "-jar", "app.jar"]

EXPOSE 8080