using Godot;
using System.Collections.Generic;

namespace DigimonCard.UI;

public partial class StartScreen : Control
{
    private const float HoverOffset = 20.0f;
    private const double HoverDuration = 0.14;

    private static readonly Color IdleOutline = new(0.0f, 0.0f, 0.0f, 0.0f);
    private static readonly Color HoverOutline = new(0.36f, 0.67f, 1.0f, 0.42f);

    private readonly Dictionary<Button, float> _restingX = new();
    private readonly Dictionary<Button, Tween> _activeTweens = new();

    private Button _libraryButton = null!;
    private Button _exitButton = null!;

    public override void _Ready()
    {
        _libraryButton = GetNode<Button>("Sidebar/Menu/LibraryButton");
        _exitButton = GetNode<Button>("Sidebar/Menu/ExitButton");

        _exitButton.Pressed += OnExitPressed;

        CallDeferred(MethodName.InitializeMenuInteractions);
    }

    private void InitializeMenuInteractions()
    {
        ConfigureHover(_libraryButton);
        ConfigureHover(_exitButton);
    }

    private void ConfigureHover(Button button)
    {
        _restingX[button] = button.Position.X;

        button.MouseEntered += () => SetHovered(button, true);
        button.MouseExited += () => SetHovered(button, false);
        button.FocusEntered += () => SetHovered(button, true);
        button.FocusExited += () => SetHovered(button, false);
    }

    private void SetHovered(Button button, bool hovered)
    {
        if (_activeTweens.Remove(button, out Tween? currentTween))
        {
            currentTween.Kill();
        }

        float targetX = _restingX[button] + (hovered ? HoverOffset : 0.0f);
        button.AddThemeColorOverride("font_outline_color", hovered ? HoverOutline : IdleOutline);
        button.AddThemeConstantOverride("outline_size", hovered ? 6 : 0);

        Tween tween = CreateTween();
        tween.SetTrans(Tween.TransitionType.Cubic);
        tween.SetEase(Tween.EaseType.Out);
        tween.TweenProperty(button, "position:x", targetX, HoverDuration);

        _activeTweens[button] = tween;
    }

    private void OnExitPressed()
    {
        GetTree().Quit();
    }
}
