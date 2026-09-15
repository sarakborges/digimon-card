using DigimonCard.Domain;

namespace DigimonCard.Content;

public static class HeroCatalog
{
    public static HeroDefinition Agumon { get; } = new("Agumon");
    public static HeroDefinition Gabumon { get; } = new("Gabumon");

    public static IReadOnlyList<HeroDefinition> All { get; } =
        new[] { Agumon, Gabumon };
}
