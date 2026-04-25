# JobTrail

Backend service to track job applications during a job hunt — from saved listing to offer.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-brightgreen)
![Status](https://img.shields.io/badge/status-in%20development-yellow)

> **Status:** 🚧 Day 1 of a 90-day build. See the [roadmap](#roadmap) for what's shipped and what's next.

## Why I'm building this

Job hunting at scale is a tracking problem. Spreadsheets break down after ~50 applications, and existing tools (Huntr, Teal) are either overpriced or miss features I want. I'm building JobTrail to:

1. Solve a real problem I have right now (active job search)
2. Get hands-on with a production-grade backend stack: Spring Boot, PostgreSQL, Docker, CI/CD
3. Have a project I can speak to deeply in technical interviews — every architectural decision will be mine

## Tech stack

| Layer | Choice | Why |
|---|---|---|
| Language | Java 21 (LTS) | Industry standard for backend; broad enterprise usage |
| Framework | Spring Boot 3.5 | De facto Java backend framework |
| Database | H2 (dev) → PostgreSQL (Phase 3) | Start zero-config, migrate to industry standard later |
| Build | Maven | Familiar tooling |
| Test | JUnit 5 + Mockito | Standard JVM testing stack |
| Deployment | Docker + Render/Railway (Phase 4) | Cloud-deployed with CI/CD |

## Roadmap

- [x] **Day 1** — Project scaffold, README, plan
- [ ] **Week 1–2** — REST API for application CRUD (H2)
- [ ] **Week 3** — Tests + GitHub Actions CI
- [ ] **Week 4** — Docker, Postgres migration, Swagger/OpenAPI
- [ ] **Week 5** — Deploy to Render/Railway
- [ ] **Week 6–7** — React + Tailwind dashboard
- [ ] **Week 8** — Email reminders for follow-ups
- [ ] **Week 9** — Architecture diagram, demo, polish

## Getting started

### Prerequisites

- Java 21+
- Maven 3.9+ (or use the included Maven wrapper)

### Run locally

```bash
./mvnw spring-boot:run
```

App starts at `http://localhost:8080`.

| Endpoint | Purpose |
|---|---|
| `GET /actuator/health` | Service health check |
| `GET /h2-console` | H2 database console (dev only) |

### Run tests

```bash
./mvnw test
```

## Project structure

```
jobtrail/
├── src/
│   ├── main/
│   │   ├── java/com/kuldeep/jobtrail/   # Application code
│   │   └── resources/
│   │       └── application.properties   # Config
│   └── test/                            # Tests
├── pom.xml                              # Maven build
└── README.md
```

## License

MIT — see [LICENSE](LICENSE).

---

*Part of a 90-day learning project: going from Java basics to shipping production backend services.*
