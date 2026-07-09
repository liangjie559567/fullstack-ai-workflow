# Testing Instructions

## Core Principles
- Prefer deterministic tests.
- Use AAA: Arrange / Act / Assert.
- Fix flaky causes, do not hide them with sleeps.
- Tests should verify behavior, not internal implementation trivia.

## Unit Tests
- Cover core business logic and edge cases.
- Name by behavior.

## Integration Tests
- Cover API, persistence, and cross-module contracts.
- Use real adapters when practical.

## E2E / Playwright
- Cover critical user journeys.
- Prefer resilient selectors.
- Seed data explicitly.

## Fixtures
- Keep fixtures small and reusable.
- Prefer factory helpers over giant static blobs.
