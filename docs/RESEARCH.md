# Implementation notes and references

The supplied development documents were treated as architectural guidance alongside the requested game. The empty repository had no existing scenes, dependency choices, or systems to preserve.

References reviewed before and during implementation:

- Godot resources and custom exported data: https://docs.godotengine.org/en/4.6/tutorials/scripting/resources.html
- Godot input event handling and touchscreen events: https://docs.godotengine.org/en/4.6/tutorials/inputs/inputevent.html
- FontVariation OpenType axis configuration: https://docs.godotengine.org/en/4.6/classes/class_fontvariation.html
- WAV looping properties: https://docs.godotengine.org/en/4.6/classes/class_audiostreamwav.html
- Godot 4.6 Android export requirements: https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html

Where the documentation website was inaccessible in the build environment, the official `godotengine/godot-docs` and `godotengine/godot` source repositories supplied the documentation. OpenType numeric tags were used after a rendered test showed that a string variation key did not select the intended font weight in the installed engine.

Design decisions:

- Pure board rules make match/gravity invariants reproducible without a graphics driver.
- Scene composition preserves editable UI layouts and reusable gems/objectives/products.
- Static level Resources allow manual balancing without editing runtime code.
- Input locks prevent overlapping swaps, booster use, or transitions during a cascade.
- Scoped, isolated test save directories prevent test profiles from overwriting player progress.
- A single shared Theme and bundled font keep screens consistent and self-contained.
- Payment and advertisement integration is deferred visibly; there are no mock charges.
