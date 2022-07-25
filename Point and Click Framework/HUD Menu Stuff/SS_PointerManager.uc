Class SS_PointerManager extends Actor
    placeable;

var(Globals) bool ShowHighlighter; // Show higlighter for buttons
var(Globals) bool ShowHighlighterForEnabledButtons <EditCondition=ShowHighlighter>; // When hovering show highlighter on ENABLED buttons
var(Globals) bool ShowHighlighterForDisabledButtons <EditCondition=ShowHighlighter>; // When hovering show highlighter on DISABLED buttons
var(Globals) float GamePadSpeedMultipier <UIMin=0.1 | UIMax=3.0>;

var(Pointer) bool DesaturateMouse; // Desaturate Mouse to allow custom coloring instead, don't activate this if your mouse texture a solid color by default!
var(Pointer) Color MouseColor, MouseClickColor <EditCondition=DesaturateMouse>; // REQUIRES DesaturatedMouse set to true!
var(Pointer) float CustomMousePositionOffset; // Offset the texture for correct point
var(Pointer) float InteractRange; // Range of interaction, if it's farther than this value it won't be "hovering"

defaultproperties
{
    ShowHighlighter = true;
    ShowHighlighterForEnabledButtons = true;
    GamePadSpeedMultipier = 1.0f;
    CustomMousePositionOffset = 0.0225f;
    InteractRange = -1.0f;
    MouseColor = (R = 19, G = 74, B = 255, A = 255);
    MouseClickColor = (R = 0, G = 51, B = 255, A = 255);

    Begin Object Class=SpriteComponent Name=Sprite
		Sprite = Texture2D'SS_Minigame_Content.Cursor'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		Scale = 0.25f;
	End Object
	Components.Add(Sprite);
}