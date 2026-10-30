# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - Unreleased

### Added
- `Cinema#latitude` and `Cinema#longitude` as Floats in decimal degrees, from the Vista sites response. They are `nil` when a site has no location or sits at 0, 0.
- `CurzonUk.ensure_token!` fetches a guest token only when there is none or it expires within an hour, and `CurzonUk.token_expires_at` reads its expiry. Both come from cinebase's `Vista::TokenHolder`.

### Changed
- A token the API rejects is cleared from `CurzonUk.token`, so the next `ensure_token!` fetches a fresh one.
- Requires cinebase 5.6.

## [1.0.0] - 2026-10-22

### Added
- `CurzonUk::Cinema.all` and `CurzonUk::Cinema.new(id)` for Curzon's cinemas, from the Vista API behind curzon.com.
- `CurzonUk::Performance.at(id, from:, to:)` with booking links, subtitles, variants, film years and festivals, following cinebase 5.4.
- `CurzonUk.token` and `CurzonUk.acquire_token!`, with platform gems that bundle curl-impersonate 2.2.3.
- Hand-written fixtures, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
