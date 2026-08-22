# Contributing to Alive

Thanks for helping make uninterrupted agent sessions better.

## Before you start

- Search existing issues before opening a new one.
- Keep the app private by design: new analytics, telemetry, accounts, or required network services are out of scope.
- Keep the runtime native and lightweight.

## Local workflow

1. Fork the repository and create a focused branch.
2. Run `swift build --product Alive` and `swift test`.
3. If you changed packaging, run `scripts/make_release.sh` and launch `build/Alive.app`.
4. If you changed the site, preview `site/` at desktop and mobile widths with reduced motion enabled once.
5. Open a pull request explaining the user-visible change and how you verified it.

## Code style

- Prefer small types with explicit responsibilities.
- Keep process matching in `AliveCore` so it remains independently testable.
- Pair bug fixes with a regression test where possible.
- Avoid adding dependencies unless the platform cannot reasonably provide the capability.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
