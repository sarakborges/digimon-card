# digimon-card

Digimon card game client built with Godot 4.7.2 .NET.

The project owns game-specific presentation and authored content. Gameplay mechanics are consumed directly from the sibling local `card-engine` repository through `ProjectReference` entries.

Expected local layout:

```text
workspace/
├── card-engine/
└── digimon-card/
```

`CardEngine.Core` is referenced now when present. Optional engine projects such as Serialization or AI should only be referenced when the game actually uses them; `CardEngine.Runner` is never a game dependency.
