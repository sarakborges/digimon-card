using Godot;

namespace DigimonCard.UI;

public partial class StartScreen : Control
{
    private const float RestingLabelX = 44.0f;
    private const float HoverOffset = 20.0f;
    private const double HoverDuration = 0.14;

    private static readonly Color IdleGlow = new(0.36f, 0.67f, 1.0f, 0.0f);
    private static readonly Color HoverGlow = new(0.36f, 0.67f, 1.0f, 0.38f);

    private Button _libraryButton = null!;
    private Button _exitButton = null!;
    private Label _libraryLabel = null!;
    private Label _exitLabel = null!;

    private Tween? _libraryTween;
    private Tween? _exitTween;

    public override void _Ready()
    {
        _libraryButton = GetNode<Button>("Sidebar/Menu/LibraryButton");
        _exitButton = GetNode<Button>("Sidebar/Menu/ExitButton");
        _libraryLabel = GetNode<Label>("Sidebar/Menu/LibraryButton/Label");
        _exitLabel = GetNode<Label>("Sidebar/Menu/ExitButton/Label");

        _libraryButton.MouseEntered += OnLibraryHoverEntered;
        _libraryButton.MouseExited += OnLibraryHoverExited;
        _libraryButton.FocusEntered += OnLibraryHoverEntered;
        _libraryButton.FocusExited += OnLibraryHoverExited;

        _exitButton.MouseEntered += OnExitHoverEntered;
        _exitButton.MouseExited += OnExitHoverExited;
        _exitButton.FocusEntered += OnExitHoverEntered;
        _exitButton.FocusExited += OnExitHoverExited;
        _exitButton.Pressed += OnExitPressed;
    }

    private void OnLibraryHoverEntered() => SetHovered(_libraryLabel, true, ref _libraryTween);

    private void OnLibraryHoverExited() => SetHovered(_libraryLabel, false, ref _libraryTween);

    private void OnExitHoverEntered() => SetHovered(_exitLabel, true, ref _exitTween);

    private void OnExitHoverExited() => SetHovered(_exitLabel, false, ref _exitTween);

    private void SetHovered(Label label, bool hovered, ref Tween? activeTween)
    {
        activeTween?.Kill();

        label.AddThemeColorOverride("font_outline_color", hovered ? HoverGlow : IdleGlow);
        label.AddThemeColorOverride("font_shadow_color", hovered ? HoverGlow : IdleGlow);
        label.AddThemeConstantOverride("outline_size", hovered ? 2 : 0);
        label.AddThemeConstantOverride("shadow_outline_size", hovered ? 8 : 0);
        label.AddThemeConstantOverride("shadow_offset_x", 0);
        label.AddThemeConstantOverride("shadow_offset_y", 0);

        float targetX = RestingLabelX + (hovered ? HoverOffset : 0.0f);

        activeTween = CreateTween();
        activeTween.SetTrans(Tween.TransitionType.Cubic);
        activeTween.SetEase(Tween.EaseType.Out);
        activeTween.TweenProperty(label, "position:x", targetX, HoverDuration);
    }

    private void OnExitPressed()
    {
        GetTree().Quit();
    }
}
