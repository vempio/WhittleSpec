# Mechanism inventory

Bounded list of WS marker IDs in the canonical corpus. One `id: mechanism (LAYER)`
record per mechanism, not per marker: a mechanism may be marked in several places --
its doctrine region plus the procedures that read it. The validator
(`ws-layer-check.sh`) requires every marked id to be listed here and every listed id
to be marked somewhere. This lists only replaceable / environment-sensitive
mechanisms -- it does not restate CORE doctrine.

verification-binding: project verification command, bound in WHITTLESPEC.md (IF-CONFIGURED)
bdd-onboarding: one-line BDD explainer shown to users with no BDD policy (EXAMPLE)
claude-code-tools: Claude Code tool-name mapping for autonomous file ops (EXAMPLE)
work-ledger: durable home for committed work — tracker or local task files (IF-CONFIGURED)
durability: how completed work is persisted — git commit per task by default, or a configured equivalent + timing (IF-CONFIGURED)
current-behaviour-authority: which surface is authoritative for current behaviour — docs+tests+code precedence by default, or a bound custom hierarchy (IF-CONFIGURED)
discovery-capture: where retained discoveries land — local ideas/seed/work-ledger by default, or bound extra/replacement destinations (IF-CONFIGURED)
tiers: project-governance weight scheme (Exploratory/Operational/Strategic) (DEFAULT)
portfolio-scan: capacity-check scan of tracker epics + sibling PROJECT_INTENT.md dirs + planning doc (EXAMPLE)
strategy-linkage: strategic-tier link to an initiative doc in a strategy/planning area (EXAMPLE)
independent-review-agent: fresh-context reviewer for the slice-cut / spec review — spawned subagent by default, invariant-preserving fallback when absent (DEFAULT)
bdd-red-step-syntax: per-framework step-definition syntax for BDD red (pytest-bdd / behave / Cucumber) (EXAMPLE)
test-visibility-syntax: per-language/framework syntax for todo/pending test stubs (EXAMPLE)
closure-mechanism: how a closed spec stops binding live behaviour — archive move to `_completed/` plus inbound-link rewrite by default, persisted as one unit (DEFAULT)
claude-code-skills-dir: default skills-directory layout when WS_SKILLS_DIR is unset — one harness's convention, not the interface (DEFAULT)
runner-counterexample: concrete runner names cited as the anti-pattern in never-hardcode doctrine (EXAMPLE)
demo-phrasing: a concrete command shown to illustrate what a good "what's new" demo sounds like (EXAMPLE)
framework-detection: signals identifying which test framework a project already uses (EXAMPLE)
inv1-audit-citations: harness specifics quoted in INV-1's audit trail — a finding, fix or blocker names the mechanism it is about (EXAMPLE)
install-prerequisites: shell, build tool and agent the shipped installer needs, plus the platforms it is tested on (DEFAULT)
install-routes: the shell/build-tool/symlink mechanics of the clone-and-build install route (DEFAULT)
