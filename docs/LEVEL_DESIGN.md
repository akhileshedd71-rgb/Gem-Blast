# Campaign design

The campaign is stored as 200 individual `LevelData` Resources, not generated on each launch. `tools/generate_levels.py` is an optional, deterministic authoring utility. **Running it overwrites all 200 Resources**, so commit any manual level edits first. Normal game startup never runs it.

| Levels | World | Progression |
| --- | --- | --- |
| 1–20 | Crystal Cove | Score tutorial, color collection from 4, ice from 11 |
| 21–40 | Bubblegum Bay | Mixed targets, corner-cut boards from 31 |
| 41–60 | Sunbeam Gardens | Break stones beside matches |
| 61–80 | Amethyst Forest | Multiple objectives, more irregular masks |
| 81–100 | Cloudberry Peaks | Sixth gem color, denser ice |
| 101–120 | Moonstone Lagoon | More masked layouts and mixed objectives |
| 121–140 | Coral Carnival | Tighter budgets, six-stone variants |
| 141–160 | Starlight Palace | Longer collections and more ice |
| 161–180 | Aurora Falls | Demanding combination and blocker planning |
| 181–200 | Prism Summit | Final mixed-goal crown challenges |

Every tenth level is a crown challenge. Move budgets decrease in stages, while collection counts, ice coverage, masks, and palette complexity increase. Easier levels between challenges provide relief; difficulty is intentionally not strictly increasing at every level number.

Each initial board has no accidental matches and at least one legal move. The seed changes between attempts within a session. Winning requires every enabled goal; a large score alone does not bypass unfinished blockers or collections. Star ratings reward score and moves remaining.

Automated greedy play completed 168/200 first-seed levels without boosters. Results by world were 20, 20, 20, 20, 18, 16, 16, 15, 9, and 14 wins out of 20. This demonstrates a broad ramp but is **not** an assessment of human win rates. All levels passed board invariants and move simulation. The remaining bot losses do not establish impossibility; they need human playtesting and further tuning. See `tests/balance_campaign.gd` to reproduce the analysis.
