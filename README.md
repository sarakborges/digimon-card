# digimon-card

Digimon card game client built with Godot 4.7.2 .NET.

The project owns game-specific presentation and authored content. The start-screen presentation is implemented in GDScript so it can run independently from C# compilation, while gameplay integration remains available through the .NET project.

During development, `card-engine` is consumed directly from a sibling local checkout rather than through a package:

```text
workspace/
├── card-engine/
└── digimon-card/
```

`DigimonCard.csproj` references `../card-engine/src/CardEngine.Core/CardEngine.Core.csproj` when that project exists. Optional engine projects such as Serialization or AI should only be referenced when the game actually uses them; `CardEngine.Runner` is not a game dependency.
