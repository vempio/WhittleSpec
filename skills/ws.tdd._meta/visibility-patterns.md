# Test Visibility: Framework-Specific Patterns

Reference material for implementing `todo`-marked test stubs across frameworks. The principle lives in `SKILL.md`; this file has the syntax for each framework. Every section below is adapter material — the language/framework named is whatever the project uses, never a doctrinal preference.

<!-- WS:EXAMPLE test-visibility-syntax -->
## Python (pytest)

Register a custom marker in `pytest.ini` or `pyproject.toml`:

```ini
[pytest]
markers =
    todo: marks tests as not yet implemented (test outlines for TDD)
    integration: marks tests as integration tests (expensive, requires external services)
```

```python
@pytest.mark.todo
def test_output_mapper_throws_on_missing_file():
    """Verify fail-fast on missing file -- must fail at construction."""
    pytest.skip("TODO: Implement after OutputMapper class exists")
```

## JavaScript (Jest)

Built-in support:

```javascript
test.todo("OutputMapper throws on missing file");
```

## C++ (Catch2)

Hidden tag + todo tag:

```cpp
TEST_CASE("OutputMapper throws on missing file", "[.][todo]") {
    SKIP("TODO: Implement after OutputMapper class exists");
}
```

## Go

Skip with TODO prefix:

```go
func TestOutputMapperThrowsOnMissingFile(t *testing.T) {
    t.Skip("TODO: Implement after OutputMapper struct exists")
}
```

## Rust

Ignore with reason:

```rust
#[test]
#[ignore = "TODO: Implement after OutputMapper exists"]
fn test_output_mapper_throws_on_missing_file() {}
```

## BDD (pytest-bdd)

`@todo` tag in `.feature` file (same Gherkin as any BDD framework):

```gherkin
@todo
Scenario: Daemon loads config from default path when no args provided
  # AC: R-16 - verify backward compatibility without CLI args
```

Scenarios bind to pytest test functions; `@todo` scenario binds via `@pytest.mark.todo` + `pytest.skip()`:

```python
@pytest.mark.todo
@scenario("daemon.feature", "Daemon loads config from default path when no args provided")
def test_daemon_default_config():
    pytest.skip("TODO: Implement step definitions")
```

List `@todo` scenarios: `pytest -m todo --collect-only`.

Feature files live alongside test code (`tests/bdd/*.feature`), not a top-level `features/`. Step definitions are pytest fixtures, organized per feature or per domain in `tests/bdd/test_*.py`. Shared `tests/bdd/conftest.py` holds common Given steps and a `ctx` fixture replacing behave's context object.

## BDD (behave)

`@todo` tag in `.feature` file:

```gherkin
@todo
Scenario: Daemon loads config from default path when no args provided
  # AC: R-16 - verify backward compatibility without CLI args
```

Configure `behave.ini` to exclude `@todo` scenarios from default runs:

```ini
[behave]
tags = ~@todo
```

To explicitly include them (e.g., for progress tracking): `behave --tags @todo --dry-run`

## BDD (Cucumber)

Same `@todo` tag pattern:

```gherkin
@todo
Scenario: User receives confirmation email after registration
  # AC: R-5 - email sent within 30 seconds
```

Exclude with `--tags "not @todo"` in runner configuration.
<!-- /WS -->
