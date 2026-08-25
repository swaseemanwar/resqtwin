# Configuration

Store non-secret configuration and reviewable examples here.

Guidelines:

- Prefer text formats with documented units and defaults.
- Commit example values, not credentials or machine-specific paths.
- Validate configuration at the boundary of the component that consumes it.
- Add tool-specific subdirectories only when an implementation requires them.

Local overrides belong under the ignored `local/` directory or in ignored environment files.
