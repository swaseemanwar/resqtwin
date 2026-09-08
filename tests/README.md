# Tests

Store automated and reproducible verification here.

The eventual suite may include:

- unit tests for reusable functions;
- model and Stateflow tests;
- integration tests across observation, state, decision, and action boundaries;
- deterministic synthetic scenarios; and
- regression evidence for hardware or recorded datasets.

Every test should name the behavior, inputs, expected result, and relevant requirement or failure mode. Hardware- and licence-dependent tests should be clearly separated from fast deterministic checks.

## Running the current MATLAB tests

From the repository root:

```matlab
run("scripts/setupProject.m")
results = runProjectTests();
```

The 14 tests under `matlab/` cover the infinite-slope reference equation,
the wetting trend, decision states, route status, the headless demo command,
and invalid inputs.
