# Task Manager — Backend API

Spring Boot REST API for the Task Manager 3-tier application.

## Tech Stack
- Java 21 (Corretto)
- Spring Boot 3.3
- Spring Data JPA
- MySQL 9.x
- Maven

## APIs

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | Get all tasks (newest first) |
| POST | `/api/tasks` | Create a new task |
| PUT | `/api/tasks/{id}` | Update task (title/status) |
| DELETE | `/api/tasks/{id}` | Delete a task |
| GET | `/api/tasks/health` | Health check (for ALB) |

## Prerequisites
- Java 21+
- Maven 3.8+
- MySQL running with `taskdb` database (see task-manager-database repo)

## Run Locally

```bash
# Build
mvn clean package

# Run
mvn spring-boot:run

# Or run the JAR directly
java -jar target/task-manager-backend-1.0.0.jar
```

App starts on: http://localhost:8080

## Test the APIs

```bash
# Health check
curl http://localhost:8080/api/tasks/health

# Get all tasks
curl http://localhost:8080/api/tasks

# Create a task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "My first task"}'

# Update task status
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"status": "COMPLETED"}'

# Delete a task
curl -X DELETE http://localhost:8080/api/tasks/1
```

## Configuration

Edit `src/main/resources/application.properties` to change:
- Database URL (for AWS RDS: replace localhost with RDS endpoint)
- Server port
- JPA settings
