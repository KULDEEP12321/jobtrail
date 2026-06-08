# JobTrail

Backend service to track job applications during a job hunt — from saved listing to offer.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-brightgreen)
![Status](https://img.shields.io/badge/status-in%20development-yellow)

> **Status:** 🚧 Day 3 of a 90-day build — **Phase 1 (Core REST API)**. See the [roadmap](#roadmap) for what's shipped and what's next.

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

A 90-day build, organized into phases. Each phase spans roughly one to two weeks; each work session ("Day N") ships a small vertical slice and is documented in [`docs/`](docs/).

| Phase | Focus | Weeks | Status |
|---|---|---|---|
| **Phase 1** | Core REST API on H2 (CRUD, layered architecture) | 1–3 | 🚧 In progress |
| **Phase 2** | Tests + GitHub Actions CI | 3–4 | ⬜ Not started |
| **Phase 3** | Docker, PostgreSQL migration (Flyway), Swagger/OpenAPI | 4–5 | ⬜ Not started |
| **Phase 4** | Deploy to Render/Railway | 5 | ⬜ Not started |
| **Phase 5** | React + Tailwind dashboard | 6–7 | ⬜ Not started |
| **Phase 6** | Email reminders for follow-ups | 8 | ⬜ Not started |
| **Phase 7** | Architecture diagram, demo, polish | 9 | ⬜ Not started |

### Progress log

Day-by-day, what's been committed. Full learning notes for each day live in [`docs/notes/`](docs/notes/) with a Q&A log in [`docs/qna/`](docs/qna/).

| Day | Shipped | Notes |
|---|---|---|
| **Day 1** | ✅ Project scaffold, README, 90-day plan | — |
| **Day 2** | ✅ `GET /api/v1/applications` — entity → JPA → repository → controller → JSON, seeded H2 | [notes](docs/notes/day-2.md) · [q&a](docs/qna/day-2.md) |
| **Day 3** | ✅ Refactor to layer-based packages (`controller/`, `service/`, `repository/`, `entity/`, `config/`, `dto/`) | [notes](docs/notes/day-3.md) · [concept](docs/notes/concept-package-structure.md) · [q&a](docs/qna/day-3.md) |

**Next (Phase 1, rest):** `@Service` layer + DTOs → write endpoints (`POST`, `GET /{id}`) → full CRUD (`PUT`, `DELETE`) → validation + error handling.

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
| `GET /api/v1/applications` | List all job applications (JSON) |
| `GET /actuator/health` | Service health check |
| `GET /h2-console` | H2 database console (dev only) |

### Run tests

```bash
./mvnw test
```

## Project structure

Layer-based (by-role) packaging — the conventional Spring Boot layout. See [`docs/notes/concept-package-structure.md`](docs/notes/concept-package-structure.md) for the reasoning.

```
jobtrail/
├── src/
│   ├── main/
│   │   ├── java/com/kuldeep/jobtrail/
│   │   │   ├── JobtrailApplication.java     # @SpringBootApplication entry point (root)
│   │   │   ├── controller/                  # REST endpoints (HTTP ↔ Java)
│   │   │   ├── service/                      # business logic            (Day 3, in progress)
│   │   │   ├── repository/                   # Spring Data JPA interfaces
│   │   │   ├── entity/                       # @Entity classes + enums
│   │   │   ├── dto/                          # request/response payloads (Day 3, in progress)
│   │   │   └── config/                       # @Configuration (e.g. seed data)
│   │   └── resources/
│   │       └── application.properties        # Config (port, H2, JPA, actuator)
│   └── test/java/com/kuldeep/jobtrail/       # Tests
├── docs/
│   ├── notes/                                # Day-by-day learning notes (Markdown + PDF)
│   └── qna/                                  # Q&A learning logs
├── scripts/
│   └── notes-to-pdf.sh                       # Markdown → styled PDF converter
├── pom.xml                                   # Maven build
└── README.md
```

## License

MIT — see [LICENSE](LICENSE).

---

*Part of a 90-day learning project: going from Java basics to shipping production backend services.*
