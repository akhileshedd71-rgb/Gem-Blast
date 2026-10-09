# Validation record

Tested October 9, 2026 with Godot **4.6.3.stable.official.7d41c59c4**.

- Clean Godot import and script loading.
- Core suite: **105,475 checks, zero failures**. Covers all 200 Resources and 1,600 simulated turns, stable starting boards, legal swaps, invalid move restoration, match grouping, special creation/chaining, ice/stone counters, segmented gravity, reward idempotence, and daily gifts.
- UI integration: **22 checks, zero failures**. Splash/home transition, map and locks, shop transactions, cosmetic ownership, settings, briefing, animated tap/swipe turns, pause, hammer consumption, win/unlock, next level, failed attempts, paid continuation, and free retry.
- Save suite: **7 checks, zero failures**. Save creation, profile restoration, settings/inventory, and recovery from a corrupt primary save using the backup. Tests use an isolated user-data directory.
- Rendered screen review: splash, home, map, shop, customization, settings, briefing, gameplay, and a completed animated turn under OpenGL Compatibility (Mesa llvmpipe). Corrected layout anchors and font variation rendering during review.
- Campaign analysis: 168/200 first-seed wins by a simple one-step greedy bot, without boosters. All 200 levels were exercised; bot losses are kept distinct from test failures.

The Xvfb display reports an unsupported V-Sync change warning; the rendered game and captures work. Final headless suites report no script errors. Audio synthesis exists and loads, but subjective sound quality was not assessed by listening. Physical mobile hardware, APK/AAB/iOS exports, accessibility assistive technology, production economy balance, and human campaign completion are unverified.
