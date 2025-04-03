# 📬 Flask + Celery + RabbitMQ Async App

This project demonstrates a simple Flask web app that runs **background tasks** using **Celery** and **RabbitMQ**. It includes:

- A fake email-sending endpoint (simulated delay)
- A web scraping endpoint that parses HTML (CVE exploits)
- Background processing using Celery workers
- A Dockerized RabbitMQ broker
- Task status checking

---

## 🧱 Components Overview

| Component   | Role                                                                 |
|-------------|----------------------------------------------------------------------|
| **Flask**   | Handles web requests (HTTP API)                                      |
| **Celery**  | Executes long-running tasks in the background                        |
| **RabbitMQ**| Acts as a **message broker**, delivering jobs from Flask to Celery   |
| **BeautifulSoup** | Parses and extracts information from an HTML page              |

---

## 🔄 Order of Execution

### Email Sending Example:
1. A user sends a POST request to `/send_email` with JSON data.
2. Flask **queues** the task using `async_send_email.delay(...)`.
3. Celery **picks up** the task from RabbitMQ and simulates sending it (5 sec sleep).
4. The user can continue using the app — no delay!

### HTML Parsing Example:
1. A user POSTs to `/parse_exploits`.
2. Flask queues the task `async_parse_exploits`.
3. Celery fetches and parses an external HTML table (CVE data).
4. Logs and returns the first 100 rows.

---

## 🧩 About Decorators

| Decorator                  | Purpose                                               |
|----------------------------|-------------------------------------------------------|
| `@flask_app.get("/")`      | Defines a GET route on the Flask app                 |
| `@flask_app.post(...)`     | Defines a POST route                                 |
| `@shared_task()`           | Marks the function as a Celery task (runs async)     |
| `@celery.task`             | Alternative to `@shared_task`, same purpose          |

---

## 📦 Installation with [uv](https://github.com/astral-sh/uv)

> ✅ Make sure you have Python 3.8+ and `uv` installed.

### 1. Clone the project
```bash
git clone https://github.com/yourusername/flask-celery-rabbitmq.git
cd flask-celery-rabbitmq
2. Create & activate virtual environment
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows
3. Install dependencies with uv
uv pip install flask celery requests beautifulsoup4 python-dotenv
🐳 Set Up RabbitMQ with Docker

Run RabbitMQ in a container:

docker run -d --rm \
  --hostname rabbitmq \
  --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  rabbitmq:3-management
Broker URL: amqp://localhost:5672
Web UI: http://localhost:15672
Login: guest / guest
🚀 Run the Application

1. Start Flask
flask --app rabbitmq.app run
(Assuming app.py is inside the rabbitmq/ folder)

2. Start Celery Worker
In another terminal (same virtualenv):

celery -A rabbitmq.app.celery_app worker --loglevel=info
🔁 API Endpoints

1. Home Page
GET /
Returns HTML instructions.

2. Send a Fake Email (Simulated Delay)
POST /send_email
Request Body:

{
  "email": "john@example.com",
  "subject": "Hello!",
  "body": "This is a test message."
}
Curl Command:

curl -X POST http://localhost:5000/send_email \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","subject":"Hello!","body":"Test"}'
Result: The task is queued. It will print a success message in the Celery worker terminal after 5 seconds.

3. Parse Exploit Table from CVE Website
POST /parse_exploits
Curl Command:

curl -X POST http://localhost:5000/parse_exploits
Returns a task ID. You can then check the result using the next endpoint.

4. Check Task Status
GET /check_task/<task_id>
Example:

curl http://localhost:5000/check_task/<your_task_id_here>
Returns JSON:

{
  "task_id": "xyz123",
  "task_status": "SUCCESS",
  "task_result": { ... }
}
