# Stage 1: Build with Maven
FROM maven:3-eclipse-temurin-17 AS builder

WORKDIR /build

COPY pom.xml .

RUN mvn dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2: Runtime only
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /build/target/*.jar app.jar

RUN addgroup -S app && adduser -S app -G app

USER app

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
