FROM openjdk:17
LABEL authors="ATAS Digital"

#EXPOSE 8080

ARG JAR_FILE=./target/*.jar

COPY ${JAR_FILE} app.jar

ENV BOT_NAME=<bot_name>
ENV BOT_TOKEN=<bot_token>
ENV ADMIN_PASSWORD=<admin_password>
ENV POSTGRE_PASSWORD=postgres

ENTRYPOINT ["java", "-jar", "app.jar", "BOT_NAME", "BOT_TOKEN", "ADMIN_PASSWORD", "POSTGRE_PASSWORD"]