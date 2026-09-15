using System;

namespace DigimonCard.Domain;

public sealed record HeroDefinition
{
    public string Name { get; }

    public HeroDefinition(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ArgumentException("Hero name cannot be empty.", nameof(name));
        }

        Name = name;
    }
}
