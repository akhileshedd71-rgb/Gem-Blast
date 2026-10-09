# Project architecture

The project follows Scenes → Nodes → Resources → Signals → Scripts. Screens and shared visual components are authored as inspectable scenes. Code instantiates only repeated content such as gems, level buttons, product rows, and objective counters.

| Responsibility | Location |
| --- | --- |
| Navigation, notifications, Android Back | `scenes/main.tscn`, `scripts/ui/main.gd` |
| Screen layouts | `scenes/ui/*.tscn` |
| Board layout and gem visual | `scenes/game/board.tscn`, `gem.tscn` |
| Rules and deterministic RNG | `scripts/game/board_model.gd` |
| Side-effect-free match grouping | `scripts/game/match_finder.gd` |
| Turn animation/input state | `scripts/game/board_view.gd` |
| Per-attempt objectives and scoring | `scripts/game/game_session.gd` |
| Level settings | `LevelData`, 200 `.tres` files |
| Profile, economy, settings | `Progress` autoload |
| Music, sound pool, optional haptics | `Audio` autoload |
| Shared button and text styling | `resources/themes/game_theme.tres` |

`BoardView` transitions through LOCKED → IDLE → SWAPPING → RESOLVING. Input is blocked during animation and modal screens. It emits `move_used`, `cleared`, and `settled`; the gameplay screen updates its `GameSession`, HUD, and results in response. The rules are independent of rendering and can be tested headlessly.

Matches merge intersecting runs. Four in a line creates a directional beam, five in a line creates a Prism, and crossing runs create a burst. A special activates when cleared, chaining other specials. A Prism swaps with any gem to clear its color; two Prisms clear all playable cells. Prism/special swaps turn the matching color into that special. Two beams produce a cross; combinations involving a burst expand the blast. Special-creation anchors retain the matched color.

Gravity operates on contiguous playable column segments, respecting holes and stones. Breaking a stone opens that cell to gravity. Ice stays on the board and is removed when the occupying gem clears. Dead boards are regenerated without using a move; this deliberately replaces existing special gems as well as ordinary gems. Shuffling also retains blocker/objective state.

Mouse-from-touch emulation routes desktop and touchscreen gestures through the same input handler. The design stage is 720×1280; it scales to the window and remains centered on expanded aspect ratios. Decorative backgrounds fill additional space. The board is deliberately calm and contrasts strongly with the gems; all six colors also have distinct shapes.

Progress is local-only and not an anti-cheat system. Economy mutations go through the profile autoload. A first completion pays 100 coins plus 25 per new star; replays cannot repeatedly claim completion rewards. A daily gift pays 120 coins according to the device's UTC date. A paid continue is offered once per attempt. Real payments and ad SDKs are intentionally absent. A future purchase integration should validate transactions and grant currency through a dedicated service rather than enabling the placeholder button.
