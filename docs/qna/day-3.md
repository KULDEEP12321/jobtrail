# Day 3 — Q&A Log

Conceptual notes from refactoring the flat Day 2 layout into layer-based packages, ahead of adding a Service layer and DTOs.

---

## Q1: Why bother refactoring the package structure at all — isn't flat fine?

Flat *was* fine on Day 2 and would have been *wrong* to split then. The principle is **structure follows pressure**: you introduce packaging the moment a "role bucket" holds more than one file, not before.

- Day 2: one entity, one repo, one controller → splitting them gives you folders with a single file each. That's ceremony, not organization. Premature structure is itself a form of technical debt.
- Day 3: we're about to add a Service layer and DTOs. *Now* the buckets fill up, `package-private` visibility becomes useful, and flatness starts to hurt. That's the trigger.

The interview-grade version: *"I started flat deliberately and refactored when the first role bucket got its second file."*

---

## Q2: Layer-based vs feature-based packaging — what's the difference, and why did we pick layer-based?

**Layer-based (by-role / horizontal):** packages are `controller/`, `service/`, `repository/`, `entity/`, `dto/`, `config/`. Each package holds one *kind* of class.

**Feature-based (by-feature / vertical):** packages are `application/`, `user/`, `auth/` — each holds *everything* for one feature (its entity + repo + controller + service together).

| | Layer-based | Feature-based |
|---|---|---|
| Cohesion | Low — one feature's files scattered across 4–5 packages | High — one feature lives in one folder |
| Familiarity | ~80% of codebases; every tutorial matches | Rarer (though Spring's own Petclinic uses it) |
| Deleting a feature | Touch many packages | Delete one folder |

We chose **layer-based** for three reasons specific to a *learning* project: (1) tutorial alignment — every resource we'll read assumes it; (2) interview alignment — reviewers place every class instantly; (3) reversibility — layer→feature is a one-day refactor later, and doing that refactor is itself a portfolio talking point. Full reasoning in `docs/notes/concept-package-structure.md`.

---

## Q3: After moving classes into sub-packages, will Spring still find my beans? Do I need to change any config?

**No config change needed — they're found automatically.** `@SpringBootApplication` includes `@ComponentScan`, which scans the package its class lives in *and all sub-packages*. Since `JobtrailApplication` is at the root `com.kuldeep.jobtrail`, the new `entity`, `repository`, `controller`, `config` sub-packages are all *below* it and get scanned for free.

The thing that *would* break it: moving the main class itself into a sub-package (e.g. `com.kuldeep.jobtrail.app`). Then it can no longer see its sibling packages, and beans silently stop loading. **Keep the `@SpringBootApplication` class at the root of the package tree.** This is a classic interview gotcha.

---

## Q4: Why did moving the files force me to add `import` statements that weren't there before?

In Java, classes in the **same package** can reference each other with no import. On Day 2 everything was in `com.kuldeep.jobtrail`, so `JobApplicationController` could name `JobApplication` and `JobApplicationRepository` directly.

The moment you split into packages, those references cross a package boundary — and **cross-package references require an explicit `import`** (or a fully-qualified name). So:

- `repository` now imports `entity.JobApplication`
- `controller` now imports `entity.JobApplication` + `repository.JobApplicationRepository`
- `config` (DataSeeder) now imports `entity.JobApplication`, `entity.Status`, `repository.JobApplicationRepository`

This isn't busywork — it's the same encapsulation mechanism that later lets you make a class `package-private` to *hide* it from other packages. Imports are the visible cost of real module boundaries.

---

## Q5: Why use `git mv` instead of just dragging the files / delete-and-recreate?

`git mv` records the change as a **rename**, so Git (and `git log --follow`) preserves the file's history across the move. A delete + create looks like two unrelated changes and loses the through-line of who-changed-what-when.

Git is actually smart enough to *infer* many renames after the fact (it noticed all five here even though we also edited the files), but `git mv` makes the intent explicit and is the safe habit.

---

## Q6: How do I know a refactor didn't break anything? It "looks" the same.

You don't trust "looks" — you trust the **build**. A refactor is by definition behaviour-preserving, and the proof is:

1. `./mvnw clean compile` succeeds → every `package` declaration and `import` resolves; the new structure is internally consistent.
2. `./mvnw test` is green → the `contextLoads` test boots the *entire* Spring context. If any bean failed to be discovered after the move, or any wiring broke, this test fails.

That context-load test is doing more than it looks: it's an end-to-end assertion that the layered structure is wired identically to the old flat one.

---

## Q7: The build failed with "A required class is missing: SurefireReportParameters". Did the refactor break Maven?

No — that error (and a sibling one naming `org.codehaus.plexus.util.Os`) is about **Maven's own plugins**, not your application code. The tell is the package prefix: `org.apache.maven.*` and `org.codehaus.plexus.*` are build-tooling classes.

What happened: the local `~/.m2` cache was missing some plugin dependencies, and the build ran with the **`-o` (offline)** flag, so Maven couldn't download the missing jars. Dropping `-o` (building online) let Maven fetch them, and the build went green.

**Rule of thumb:** when a build error names Maven/Plexus classes, the problem is your **build environment or cache**, not your source files. Don't debug your Java for a tooling problem. Avoid `-o` until you know the cache is complete.

---

## Q8 (open): When *would* we switch jobtrail to feature-based packaging?

*Hint: think about what makes the layer packages start to hurt — how many distinct features, and what bigger architectural move feature-packaging is a stepping stone toward.*

_Answer to be added after we discuss it — see `concept-package-structure.md` §4 for the two trigger points._
