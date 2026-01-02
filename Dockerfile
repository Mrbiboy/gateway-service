# build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .

# Cache Maven repo between builds to avoid redownloading dependencies
RUN --mount=type=cache,target=/root/.m2 \
    mvn -q -DskipTests dependency:go-offline

COPY src ./src

# Reuse the same Maven cache for the actual build
RUN --mount=type=cache,target=/root/.m2 \
    mvn -q -DskipTests clean package

# run stage
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8088
ENTRYPOINT ["java","-jar","app.jar"]
