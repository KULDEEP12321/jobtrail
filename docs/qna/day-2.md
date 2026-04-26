# Day 2 — Q&A Log

Conceptual notes from building the first slice of the JobApplication API: entity, repository, controller.

---

## Q1: What's the difference between an entity and a row in a database table?

An **entity** is a Java object; a **row** is data stored in the database. They are two representations of the same thing in two different worlds.

| | Row (database world) | Entity (Java world) |
|---|---|---|
| Lives in | A table on disk (or in H2's memory) | RAM, as a Java object |
| Looks like | `1, Google, SWE, APPLIED` | A `JobApplication` object with fields `id=1, company="Google"…` |
| Spoken to via | SQL (`SELECT * FROM job_application`) | Java method calls (`app.getCompany()`) |

JPA is the translator between them. The `@Entity` annotation tells JPA: *"this class corresponds to a table; treat its instances as rows."* When you call `save(entity)`, JPA generates an `INSERT`. When you call `findById(1)`, JPA generates a `SELECT` and hands you back a Java object.

**Mental model:** Row = data at rest in the DB. Entity = same data, but in Java's hands so your code can manipulate it.

---

## Q2: Why a separate repository class instead of having the controller talk to the database directly?

Three reasons, in order of importance:

1. **Separation of concerns.** The controller's job is to handle HTTP — parse the URL, return JSON, set status codes. The repository's job is to talk to the database. Mixing them produces a class doing two unrelated jobs that becomes a tangled mess as the project grows. If we later swap H2 for Postgres or add a caching layer, only the repository changes — the controller doesn't notice.

2. **Testability.** The controller can be unit-tested by passing in a *fake* repository that returns hard-coded data. No real database needed. Tests stay fast.

3. **Reuse.** The same repository can be used by a controller, a scheduled job, an email service, etc. If DB logic lived inside the controller, every other piece of code would have to duplicate it.

This pattern is called **layered architecture** (or "n-tier"): Controller → Service → Repository → Database. We're skipping the Service layer for now because we have no business logic — we'll add it the moment we need one.

---

## Q3 (open): What problem does JPA/Hibernate solve, and what's the trade-off?

*Hint: Imagine JPA didn't exist. What would you have to write by hand for every database read/write? And what control do you give up when you let a framework generate the SQL for you?*

_Answer to be added after we discuss it._

---

## Q4: Why use `Long` (boxed) instead of `long` (primitive) for the `id` field?

`Long` can be `null`, which is what we want **before** the row is saved — the database hasn't assigned an id yet. A primitive `long` defaults to `0`, which falsely implies "this entity has id 0." Using the boxed type lets JPA distinguish "not yet persisted" from "persisted with id 0."

We also chose `Long` over `Integer` because `int` overflows past ~2.1 billion rows. `Long` is the safe convention from day one.

---

## Q5: What happens if you use `@Enumerated(EnumType.ORDINAL)` and later reorder the enum?

`ORDINAL` stores the enum's **position** as an integer (`SAVED=0, APPLIED=1, ...`). If you reorder the enum from `SAVED, APPLIED, ...` to `APPLIED, SAVED, ...`, every existing row's status flips silently — rows that meant `APPLIED` now mean `SAVED`, with no error and no log.

`EnumType.STRING` stores the literal name (`"APPLIED"`), so reordering the enum is harmless. **Always use `STRING`** for enum columns. This is a classic JPA footgun and a frequent interview question.

---

## Q6: What SQL does Hibernate run on startup when it sees `@Entity` on `JobApplication`?

Because `spring.jpa.hibernate.ddl-auto=update` is set, Hibernate inspects the entity at startup and issues:

```sql
CREATE TABLE job_application (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    company     VARCHAR(255),
    role        VARCHAR(255),
    status      VARCHAR(255),
    PRIMARY KEY (id)
);
```

Notes:
- Table name `job_application` — snake-case derived from the class name.
- `BIGINT` because `Long` is 64-bit.
- `AUTO_INCREMENT` because of `@GeneratedValue(strategy = IDENTITY)`.
- `status` is `VARCHAR` (not `INT`) because of `@Enumerated(EnumType.STRING)`.

`ddl-auto=update` mode only **adds** columns/tables — it never drops anything. In production you replace this with a real migration tool (Flyway or Liquibase) — we'll do that in Phase 3.

---

## Q7: Why is `JobApplicationRepository` declared as an interface, not a class? Where does the implementation come from?

You declare an interface because **you don't write the implementation — Spring Data JPA writes it for you at runtime.**

At application startup, Spring scans the classpath for interfaces extending `JpaRepository` (and its siblings). For each one it finds, it builds a dynamic proxy class that implements the interface, wires it as a singleton bean in the Spring context, and makes it injectable. Two terms worth knowing for interviews: **classpath scanning** + **dynamic proxy generation**.

Net result: one line of declaration gives you `save`, `findById`, `findAll`, `count`, `deleteById`, `existsById`, and ~15 more methods — for free.

---

## Q8: What would break if we wrote `JpaRepository<JobApplication, String>` instead of `JpaRepository<JobApplication, Long>`?

The second type parameter must match the type of the entity's `@Id` field. Since `JobApplication.id` is `Long`, declaring the repository as `JpaRepository<JobApplication, String>` causes a startup failure — Spring detects the mismatch and refuses to build the proxy.

It also means every method that takes the id type would expect a `String`: `findById("abc")` would compile, but the underlying SQL still binds to a `BIGINT` column → runtime error. The generic parameter is a **compile-time guarantee** that you're using the right id type.

---

## Q9: If we add `List<JobApplication> findByCompany(String company);` to the interface, what does Spring Data do at startup?

Spring Data parses the **method name** using its query derivation rules:

- `findBy` → generate a `SELECT`
- `Company` → matches the `company` field on `JobApplication`
- The single `String` parameter binds to the `WHERE company = ?` clause

The generated SQL is roughly:
```sql
SELECT * FROM job_application WHERE company = ?;
```

You wrote zero SQL and zero implementation — just a method signature in the right shape. Other keywords work the same way: `findByCompanyAndStatus`, `findByStatusOrderByIdDesc`, `countByStatus`, `deleteByCompany`, etc. For queries too complex to express in a method name, you fall back to `@Query("...")` with explicit JPQL or SQL.

---

## Q10: What's the difference between `@Controller` and `@RestController`?

`@RestController` is shorthand for `@Controller` + `@ResponseBody`.

- `@Controller` alone treats method return values as **view names** — the framework looks up an HTML template with that name and renders it. This is the older server-rendered web pattern (e.g. Thymeleaf/JSP).
- `@RestController` treats method return values as the **response body** itself, serialized to JSON via Jackson. This is the REST API pattern.

For a JSON backend like jobtrail, always use `@RestController`. Only use `@Controller` if you're rendering server-side HTML.

---

## Q11: Why constructor injection instead of field injection (`@Autowired` on the field)?

Three reasons, all interview-relevant:

1. **Immutability.** Constructor-injected dependencies can be `final`, guaranteeing the reference is set once at construction and never reassigned. Field injection prevents `final`.
2. **Testability.** With a constructor, you can write `new JobApplicationController(fakeRepo)` in a unit test — no Spring context, no reflection. Field injection requires Spring or reflection to populate the field.
3. **Fail-fast on missing dependencies.** If a required dependency is absent, constructor injection fails at startup with a clear error. Field injection often fails much later, at the first usage of the null field — harder to diagnose.

Spring's official recommendation since version 4.x is constructor injection. Field injection is considered a code smell.

---

## Q12: What does Jackson do, and how does it know how to serialize my entity?

Jackson is the JSON library bundled with `spring-boot-starter-web`. When a controller method returns a Java object (or a `List` of them), Spring hands it to Jackson, which:

1. Reflects on the object's class to find getter methods (`getId()`, `getCompany()`, etc.).
2. For each getter, derives a JSON field name from the method name (`getCompany` → `"company"`).
3. Recursively serializes the values, producing valid JSON.

This is why our entity needed Lombok's `@Getter` — without getters, Jackson sees no fields to serialize and would emit `{}`. Customization options exist (`@JsonProperty`, `@JsonIgnore`, custom serializers) but the defaults Just Work for plain POJOs.

---

## Q13: Why use `/api/v1/applications` and not just `/applications`?

Two pieces of convention, both important at scale:

- **`/api/`** — separates JSON API endpoints from any future static pages, dashboards, or server-rendered HTML you might add.
- **`/v1/`** — API versioning. Lets you ship a `/v2/applications` later (with a breaking schema change) **without breaking existing clients** who depend on `v1`. Versioning strategies are a frequent system-design interview topic.

Other versioning approaches you'll see: header-based (`Accept: application/vnd.jobtrail.v1+json`), query-string (`?version=1`). URL-path versioning is the most common because it's the most visible and easiest to debug.
