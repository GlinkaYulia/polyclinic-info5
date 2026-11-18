# Інформаційно-довідкова система поліклініки

Лабораторна робота №5. Хмарний деплой (Render), змінні середовища, моніторинг.

## Структура
- `client/` — React (Vite)
- `server/` — Ruby/Sinatra API (`lib/config.rb`, `lib/metrics.rb`, `bin/prepare_db.rb`, `routes/system.rb`)
- `db/` — SQL-схема, тестові дані, таблиці користувачів
- `Dockerfile`, `.dockerignore`, `render.yaml` — розгортання
- `scripts/loadtest.mjs` — навантажувальний тест

## Локальна розробка
```bash
psql -U postgres -c "CREATE DATABASE polyclinic ENCODING 'UTF8';"
cd server && cp .env.example .env     # заповніть значення
bundle install
ruby bin/prepare_db.rb                # створює таблиці та дані (якщо БД порожня)
bundle exec ruby app.rb               # http://localhost:4567
cd ../client && npm install && npm run dev   # http://localhost:5173
```

## Деплой на Render
1. Закомітьте проєкт на GitHub (включно з `server/Gemfile.lock`).
2. Render → **New → Blueprint** → оберіть репозиторій → **Apply**.
3. Дочекайтесь статусу *Live* і відкрийте адресу сервісу.

Змінні середовища (`DATABASE_URL`, `SESSION_SECRET`, `METRICS_TOKEN`, `RACK_ENV`) створюються з `render.yaml`.
Перегляд і зміна: сервіс → вкладка **Environment**.

## Моніторинг
- `GET /api/health` — стан сервера й БД (200 або 503)
- `GET /api/metrics` — метрики (потрібен `Authorization: Bearer <METRICS_TOKEN>` або вхід як admin)
- Логи (JSON) і метрики CPU/пам'яті — у панелі Render
- Зовнішній монітор: UptimeRobot → HTTP(s) → `https://<ваш-сервіс>.onrender.com/api/health`

```bash
curl https://<ваш-сервіс>.onrender.com/api/health
curl -H "Authorization: Bearer <METRICS_TOKEN>" https://<ваш-сервіс>.onrender.com/api/metrics
node scripts/loadtest.mjs https://<ваш-сервіс>.onrender.com/api/doctors 200 10
```

## Типові проблеми
- **Збірка Docker падає на `bundle install`** — переконайтесь, що `server/Gemfile.lock` закомічено.
- **Сервіс довго відповідає вперше** — безкоштовний план «засинає» після простою (холодний старт).
- **503 на `/api/health`** — БД ще створюється або недоступна, перевірте вкладку Logs.
- **Приклад Postman-колекції (лаба №3)** тут не працює без входу (потрібен admin).
