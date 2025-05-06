FROM openjdk:11-jre-slim
COPY target/hello-kaniko-1.0.jar /app/hello-kaniko.jar
ENTRYPOINT ["java", "-jar", "/app/hello-kaniko.jar"]
