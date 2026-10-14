# Security and operational boundaries

This is a pure numerical/design library, not a safety-certified experiment executor.
Do not directly run physical equipment or make medical/financial/safety decisions from its
outputs. Review actual factor units, axial points, constraints, model rank and termination.

Input size/dimension/work limits bound allocations and selected search operations, not wall
clock time. Reject oversized transport payloads before parsing. CSV export quotes names/IDs,
but is **not spreadsheet-formula neutralization**: spreadsheet applications may interpret a
leading `=`, `+`, `-` or `@` even inside quoted cells. Import as literal text or sanitize at the
presentation layer. CSV data uses coded values; never assume they are instrument setpoints.

JSON requires exact schema fields; the core parser's duplicate-key last-value behavior is
inherited. This is not a canonical signed JSON format. CSV numeric syntax follows JSON numbers.
Malformed shapes, identifiers and bounded nonfinite values throw DesignError; public mutable
arrays still require caller synchronization. Predicate callbacks can throw/abort in caller code;
no sandbox is provided.

Report defects through the repository's GitHub issues with synthetic reproductions. Do not
include API tokens, credentials, personal contacts or private measurement data in reports.
