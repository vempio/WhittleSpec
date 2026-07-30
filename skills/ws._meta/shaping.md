# WhittleSpec Reference: Shaping the Work

How much rigor a piece of work gets, and how the work is cut. Which skills load this
chapter is recorded once, in `ws._meta/SKILL.md` § Chapter routing.

## Process-Shape Hard Rules

Govern the _shape_ of SDD work — single-cycle vs umbrella, slice boundaries, artefact size, task granularity. Shape sits above scale (scale = how much rigor; shape = how rigor is decomposed). Shape errors multiply — wrong umbrella → wrong slices → wrong tasks — so shape gates fire before scale gates.

Driving failure mode (narrated, not a shipped example — the original was private case-history): a one-hour skill-authoring task absorbed a day of multi-slice ceremony because the LLM defaulted to umbrella shape, sliced by technical layer, atomised tasks below the granularity floor, and let `requirements.md` sprawl past attention.

### Default is single-cycle

Single `requirements.md` / `plan.md` / `tasks.md` is the default for every project, regardless of effort estimate. Umbrella shape is opt-in, never opt-out.

The LLM **may not** propose umbrella unprompted. It **may** raise it as a question when load signals appear (next section). Decision is the user's.

- Two related projects → two single-cycle projects in adjacent directories. Not an umbrella.
- One project with "more later" → single-cycle plus a backlog item. Not an umbrella.
- Half a dozen small artefacts (skills, similar fixes) → flat list of single-cycle projects. Not an umbrella.

### Umbrella is a user-owned mental-load device

Umbrellas exist when a project has grown too large for the user to hold in working memory — the SDD analogue of epic-vs-story, a mental-control device, not a size threshold.

Slicing itself **adds** mental load (umbrella spec + slice specs + tracking + cross-slice coordination). The trade is umbrella-load vs whole-project-load — only the user can weigh it. Counting rules ("≥ N outcomes", "> N days of work") are forbidden — they look objective but smuggle a decision the LLM cannot make.

Signals worth raising (qualitative; LLM names, user decides):

- User asked to hold ≥ 3 distinct outcomes simultaneously **and** each is non-trivial enough for its own SDD cycle (rough: several days, not hours). Wide-but-shallow does _not_ qualify — that's a flat list of single-cycle projects.
- Decisions in one part are routinely deferred with "we'll figure that out later" because the present part saturates attention.
- User said "I'm losing track" or asked for the project to be re-stated.

When two or more signals present, ask **once**: _"This is getting wide enough that an umbrella might help — want to switch shapes? Default stays single-cycle."_ Single ask, not recurring nag.

### Slicing must never be justified by architecture

If a slice cannot be defended in user-or-operator terms alone, it does not exist. Forbidden words in any slice _justification_: **layer**, **component**, **module**, **phase**, **skeleton-then-flesh-out**, **walking-skeleton-with-deferred-X**, or any technical surface (API, schema, MCP, CLI, persistence, ingest, reconcile, etc.).

Test before proposing slices: _state the slicing in one sentence using no technical nouns._

Prohibition is on _justification_, not _definition_. A walking skeleton crosses all layers by definition — that's descriptive (and "all layers" appears in that sense elsewhere in this doc). The forbidden move is leading with layered framing when justifying a cut ("slice 1 = API layer, slice 2 = persistence layer"). User/operator framing first; layered description is a consequence.

Acceptable shapes: distinct user-jobs, operator-jobs, or skill-family-members serving distinct operator-jobs. Even these must clear default-single-cycle first — two siblings ≠ umbrella.

Walking-skeleton-with-deferred-branches is a code-shape pattern; it does not transfer to skill / prose / config artefacts. A skeleton that refuses three of five real situations is horizontal scaffolding wearing a skeleton's clothes.

#### Per-surface slicing

One task or slice per tool / function / endpoint / file / command / screen — is horizontal slicing in disguise, and the most common modern form (the forbidden-words list misses it: "one task per endpoint" names no layer). A capability routinely *spans* several surfaces, and binding them into one coherent behaviour is frequently the entire point — so cutting per-surface severs exactly what made it a capability. Discriminator: *is this task a distinct thing the USER does, or a distinct thing the CODE has?* "Update `list_folders`" / "add the `/foo` endpoint" is a thing the code has; "list a folder's messages" / "check out" is a thing the user does. Extending a capability to a genuinely new user-job is vertical (fan-out); splitting one capability across its surfaces is horizontal.

#### Exposure is not a slice

A task whose entire payload is making a capability *visible* — advertising, cataloguing, documenting, adding it to an index / menu / usage-hint — where the capability functions (or will function) without it, is the discoverability-half of another task's behaviour. Merge it. This is the mirror image of leaf-only slicing (which defers exposure *after* behaviour); both split one capability across tasks.

### Artefact size ceilings

Size is a quality bar, not an aspiration. Past the default, attended length collapses; past the hard cap, the SDD level was mis-selected and the project must be re-decided, not re-edited.

| Artefact                                                       | Default ceiling     | Hard cap  | On hard-cap                                                                                                                          |
| -------------------------------------------------------------- | ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `requirements.md` / `umbrella-requirements.md` Decisions block | 200 words / 5 items | 300 words | Split scope. The decisions are bundled features.                                                                                     |
| `requirements.md` / `umbrella-requirements.md` Context block   | 300 words           | 600 words | Re-run `/ws.0-start`. The level was wrong, or recording exceeds reading.                                                           |
| `plan.md` / `umbrella-plan.md`                                 | 400 words           | 800 words | Re-run `/ws.0-start`.                                                                                                              |
| `tasks.md` per cycle                                           | 6 tasks             | 8 tasks   | Either tasks are too small (merge — see granularity rules in `/ws.3-tasks`) or scope is too big (split, do not umbrella by reflex). |

Anti-example (narrated above, under Process-Shape Hard Rules): the same driving failure mode — a `requirements.md` that sprawled past attention — is the shape these ceilings exist to prevent.

### Decisions/Context split in `requirements.md` / `umbrella-requirements.md`

`requirements.md` / `umbrella-requirements.md` fuses two artefacts: the decision surface (what the user must react to) and the record (assumptions, ACs, prior context). Fused, the record drowns the decisions and review fatigue sets in even at small decision counts.

Mandatory structure (from `/ws.1-requirements`):

```markdown
## Decisions

<!-- Read top-to-bottom. What I need you to react to.
     Cap: 5 items. More → split scope before writing. -->

- [ ] Decision 1: <one sentence>. Default: <recommendation>. Alternatives: <one phrase each>.
- [ ] Decision 2: ...

---

## Context

<!-- Skim or skip. Record, not decision surface.
     If you wouldn't read it on review, don't write it. -->

[user story, ACs, out-of-scope, assumptions, prior context, ...]
```

60-second decideability test applies only to Decisions: each item answerable in 60 seconds.

Context is a record, but **recording without reading is theatre.** Holds only what the LLM cannot reconstruct from Decisions + existing project files. No restating tracked issues, the project's principles-file context, or "as a user I want X so that Y" boilerplate when the user-job is already in Decisions. Acceptable: non-obvious out-of-scope, assumptions that affect implementation but didn't rise to a decision, prior research that won't otherwise survive (link if elsewhere).

**Adversarial tests, both directions** (run before presenting):

- **Decisions — "really a decision?"** Each item carries Default + ≥ 1 plausibly-chooseable Alternative. If no credible Alternative ("only other option is _not doing it_"), not a decision — move to Context or cut. Straw alternatives ("Default: persist; Alternative: don't persist") don't count. Recommendation = decision _only_ if it could go the other way.
- **Decisions — "would a knowledgeable reader push back?"** If no plausible push-back exists, the item is settled, not a decision — move to Context.
- **Context — "would removing this change anything downstream?"** If no future planning/task/implementation choice would differ without this paragraph, cut. "For completeness" / "to be thorough" are not answers — they name the failure mode.
- **Cross-block — "decision in disguise in Context?"** Scan for load-bearing items: assumptions constraining the solution, scope cuts that would surprise the user, definitions changing AC meaning. Promote to Decisions.

### Condensation is a deliverable

Length is not rigor; condensed length is. A spec is finished when no further sentence can be cut without losing a decision or irrecoverable context. The first draft is too long by construction; the final pass before any STOP gate is a compaction pass, not an elaboration pass.

Before each STOP gate in `/ws.1-requirements`, `/ws.2-plan`, `/ws.3-tasks`: re-read the artefact and cut. Target **≥ 20% reduction** on first compaction pass. If 20% will not come out, either the artefact was already tight (rare on first draft) or the compaction was not attempted.

### Domain Adaptation

Applies to any substantial deliverable -- research, writing, event planning, strategy. Adapt vocabulary, keep rigor:

| Software Term               | Non-Software Equivalent                          |
| --------------------------- | ------------------------------------------------ |
| Walking skeleton            | Rough draft, outline, pilot, prototype           |
| Components                  | Chapters, sections, workstreams, phases          |
| Interfaces                  | Transitions, handoffs, dependencies              |
| Codebase / existing code    | Prior work, source materials                     |
| Implementation              | Execution, production                            |
| Technical risk              | Execution risk                                   |
| Tests / acceptance criteria | Review criteria, quality checks, success metrics |

**Do not dilute structure.** Strategy docs need requirements and plan just as much as code.

## Scope Split Triggers

**Too many ACs** (>5-7 = bundled features) / **Too many unknowns** (>3 `[NEEDS CLARIFICATION]` at one level) / **Walking skeleton hard to describe** (complex minimal path -> scope too big) / **Too many areas** (>3-4 components) / **Mixed priorities** (must-have + nice-to-have -> split).

**When detected**: Propose specific split: "Two features: [A] and [B]. Split because..." / "Must-haves = MVP. Nice-to-haves = follow-up." / "Tasks 1-3 = end-to-end value. Tasks 4-7 = separate effort."

## Attention Budget

Spec detail past the point of attentive reading has negative marginal value: a skimmed spec gives the _illusion_ of oversight while reducing it.

At each STOP gate in `/ws.1-requirements`, `/ws.2-plan`, `/ws.3-tasks`, `/ws.refine`: ask **"Is this still shorter than your attention span for one sitting?"** If no, split or cut — don't add the next refinement on top of a document the user is already skimming.

Known failure mode: detailed requirements felt thorough to the LLM; user reported "I started skipping and skimming" — extra detail worsened review quality. Length is not rigor; attended length is.

Corollary for retros: drift between "spec says" and "shipped behaviour" is more likely on long specs — the human who should catch drift stopped reading. Weight retro drift categories (intentional / discovered / creep / cut / silent drift) against spec length.
