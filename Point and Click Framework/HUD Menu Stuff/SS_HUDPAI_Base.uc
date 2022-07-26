/*
* Framework for the Point Interact HUD!
* Made by SamiSha
*/
Class SS_HUDPAI_Base extends Hat_HUDMenu;

var bool bDisableMovement, bDisableCamera, bForceMouseActivatedCheck, bPressing;

// Gamepad support
var Vector2D LastPointerPosition, PointerPosition;
var bool bGamePad, bSuppressWatchDog;
var float GamePadSpeedMultipier;

// Custom Mouse
var bool bCustomMouse;
var bool Greyscaled;
var MaterialInterface MouseMat;
var Texture2D MouseTexture;
var MaterialInstanceTimeVarying CustomMouse;
var float CustomMousePositionOffset; // Diagonally!!!!
var float MouseSize;
var Color MouseColor, MouseClickColor;

const MOUSE_PARAMETER_PRESSED = 'Pressed';
const MOUSE_PARAMETER_HOVER = 'Hover';
const MOUSE_PARAMETER_HOVER_TEXTURE = 'HoverTexture';
const MOUSE_PARAMETER_TEXTURE = 'MouseTexture';
const MOUSE_PARAMETER_GREYSCALE = 'Desaturate';
const MOUSE_PARAMETER_PRESSED_COLOR = 'PressColor';
const MOUSE_PARAMETER_RELEASED_COLOR = 'ReleaseColor';

// Highlighter, just call CornerBorders(...); with the right values!
var bool ShowHighlighter;
var Array<Surface> BorderCorners;
var float CornerSizeMultiplier; // 1.0f

// Adjusts default values for the Wobble() function
const WOBBLE_RATE = 0.75f; // How fast the wobble is
const WOBBLE_RANGE = 0.02f; // Range is % of screen size
const WOBBLE_POSITIVERANGE = true; // Make the wobble absolute, thus animation would take a bounce once it reaches 0 see this: https://i.imgur.com/lo4A4nS.png

const ALLOW_PRINT_DEBUG = true;

var SS_PointerManager Global_PointManager;

function OnOpenHUD(HUD H, optional String command)
{
    Super.OnOpenHUD(H, command);
    AdjustToGlobal();
    ControlChangeWatchDog(H);
    if(bCustomMouse || bGamepad) SetCustomMouse(H, true);
    PointerPosition = IsGamePad(H) ? vect2d(0.5f, 0.5f) : vect2d(0.0f, 0.0f);
}

function bool Render(HUD H)
{
    if(!Super.Render(H)) return false;
    ControlChangeWatchDog(H);
    // Default back to white color
    H.Canvas.SetDrawColor(255,255,255,255);
    if(bCustomMouse || bGamepad) DrawCustomMouse(H);
    
    return true;
}

function bool Tick(HUD H, float d)
{
    local Vector2d v2d;

    if (!Super.Tick(H, d)) return false;

    LastPointerPosition = PointerPosition;
    if (bGamepad)
	{	
        d *= GamePadSpeedMultipier;
		if (Hat_PlayerController(H.PlayerOwner) != None)
		{
			v2d = vect2d(H.PlayerOwner.PlayerInput.RawJoyRight, H.PlayerOwner.PlayerInput.RawJoyUp * -1.0f) * Hat_PlayerController(H.PlayerOwner).GetAnalog() * d;
            if (`IsMirrorMode) v2d = vect2d(v2d.X * -1, v2d.Y);
		}
		else
            v2d = vect2d(PowNegative(H.PlayerOwner.PlayerInput.RawJoyRight, 2), PowNegative(H.PlayerOwner.PlayerInput.RawJoyUp, 2) * -1.0f) * d;
        PointerPosition = V2DClamp(PointerPosition + v2d, vect2d(0.0f, 0.0f), vect2d(1.0f, 1.0f));
	}
    else
        PointerPosition = GetMousePos(H);


	return true;
}

static function CallRemoteEvent(Name RemoteEventName, Actor InOriginator, optional Actor InInstigator)
{
    local int i;
    local Sequence GameSeq;
    local array<SequenceObject> AllSeqEvents;
    
    if(String(RemoteEventName) ~= "") return;
	if(InInstigator == None) InInstigator = InOriginator;
    
    GameSeq = Class'WorldInfo'.static.GetWorldInfo().GetGameSequence();
    if(GameSeq == None) return;

    GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);
    for(i=0; i < AllSeqEvents.Length; i++)
    {
        if(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName != RemoteEventName) continue;
        SequenceEvent(AllSeqEvents[i]).CheckActivate(InOriginator, InInstigator);
    }    
}

final function Print(coerce string msg)
{
    local WorldInfo wi;

    if(!ALLOW_PRINT_DEBUG) return;

    wi = class'WorldInfo'.static.GetWorldInfo();
    if (wi == None) return;

    msg = "[" $ Class $ "]" @ msg;

    if(wi.GetALocalPlayerController() != None)
        wi.GetALocalPlayerController().TeamMessage(None, msg, 'Event', 6);
    else
        wi.Game.Broadcast(wi, msg);
}

// Handles the custom mouse to be moved around and so on
function DrawCustomMouse(HUD H)
{
    local float X, Y;
    //H.Canvas.SetDrawColor(MouseColor.R, MouseColor.G, MouseColor.B, MouseColor.A);
    X = (bGamePad ? PointerPosition.X : GetMousePosX(H)/H.Canvas.ClipX) + CustomMousePositionOffset * ScreenToSquaredRatio(H);
    Y = (bGamePad ? PointerPosition.Y : GetMousePosY(H)/H.Canvas.ClipY) + CustomMousePositionOffset;

    DrawClippedCenter(H, X, Y, MouseSize * H.Canvas.ClipY, MouseSize * H.Canvas.ClipY, CustomMouse);
}

// All of pos and scales are between 0 and 1! Clipped functions OMEGALUL
// Squared => true => Y Square scaling
function CornerBorders(HUD H, float t, Vector2D Pos, optional bool Squared = true, optional Vector2D Scale = vect2d(0.1f, 0.1f))
{
    local float up, down, left, right, CornerScale;
    if(!ShowHighlighter) return;
    
    if(Squared)
        Scale.X = Scale.Y * ScreenToSquaredRatio(H);
    // Reminder: [0, 0] to [maxWidth, maxHeight] is from: top left corner TO bottom right!!!
    up = Pos.Y - Scale.Y;
    down = Pos.Y + Scale.Y;
    left = Pos.X - Scale.X;
    right = Pos.X + Scale.X;

    CornerScale = 0.05f * H.Canvas.ClipY;

    DrawClippedCenter(H, left * (1 + -Wobble(t)), up * (1 + -Wobble(t)), CornerScale, CornerScale, BorderCorners[0]); // Top left
    DrawClippedCenter(H, right * (1 + Wobble(t)), up * (1 + -Wobble(t)), CornerScale, CornerScale, BorderCorners[1]); // Top right 
    DrawClippedCenter(H, left * (1 + -Wobble(t)), down * (1 + Wobble(t)), CornerScale, CornerScale, BorderCorners[2]); // Bottom left
    DrawClippedCenter(H, right * (1 + Wobble(t)), down * (1 + Wobble(t)), CornerScale, CornerScale, BorderCorners[3]); // Bottom right
}

function float Wobble(float Time, optional float Range = WOBBLE_RANGE, optional float Rate = WOBBLE_RATE, optional bool PositiveRange = WOBBLE_POSITIVERANGE)
{
    local float v;
    v = Sin(Rate * Pi * Time);
    if(PositiveRange) v = Abs(v);
    v *= Range;
    return v;
}

// Clipped for positions only!!! You need to manually clip Scale/Size!
// Text rendering, "Size" is ridiclously awkward for this function so pass 1.0f and mess around from that value, normally you'd do something like 0.05f * H.Canvas.ClipY but IMO its not worth it
function DrawClippedBorderedText(HUD H, string S, float X, float Y, float Size, optional bool Shadow, optional TextAlign Align, optional float ShadowAlpha = 0.5, optional float BorderWidth = 4.0, optional Color BorderColor, optional float VerticalSize = -1, optional float BorderQuality = 1)
{
    DrawBorderedText(H.Canvas, S, X * H.Canvas.ClipX, Y * H.Canvas.ClipY, Size, Shadow, Align, ShadowAlpha, BorderWidth, BorderColor, VerticalSize, BorderQuality);    
}

// Materials (Yes MaterialInterface is a parent of all materials, just pass materials, trust me)
function DrawClippedMat(HUD H, float x, float y, float scaleX, float scaleY, MaterialInterface texture, optional float angle, optional Vector RotationCenter = vect(0.5,0.5,0.0))
{
    DrawCenterMat(H, H.Canvas.ClipX * x, H.Canvas.ClipY * y, scaleX, scaleY, texture, angle, RotationCenter);
}

// Textures (Like the above but Surface is a parent of all textures and also materials, but overall use this specifically for flat PNGs and nothing else!)
function DrawClippedCenter(HUD H, float fX, float fY, float fScaleX, float fScaleY, Surface hTexture, optional float angle, optional Vector RotationCenter = vect(0.5,0.5,0.0))
{
    DrawCenter(H, fx * H.Canvas.ClipX, fY * H.Canvas.ClipY, fScaleX, fScaleY, hTexture, angle, RotationCenter);
}

function bool DisablesMovement(HUD H)
{
    return bDisableMovement;
}

function bool DisablesCameraMovement(HUD H)
{
    return bDisableCamera;
}

// Sets up the Custom Mouse
function SetCustomMouse(HUD H, bool b)
{
    if(CustomMouse == None && MouseMat != None)
        InitCustomMouse();
	Hat_PlayerController(H.PlayerOwner).SetMouseHidden(b);
}

// Initialize the Mouse Material and save it into the global variable CustomMouse
function InitCustomMouse()
{
    local MaterialInstanceTimeVarying m;
    local LinearColor mc, mcc;
    m = new Class'MaterialInstanceTimeVarying';
    m.SetParent(MouseMat);
    // Custom texture? We got it!
    if(MouseTexture != None) m.SetTextureParameterValue(MOUSE_PARAMETER_TEXTURE, MouseTexture);

    // Greyscaled? Let's give em a color!
    if(Greyscaled)
    {
        mc = ColorToLinearColor(MouseColor);
        mcc = ColorToLinearColor(MouseClickColor);
        m.SetLinearColorParameterValue(MOUSE_PARAMETER_PRESSED_COLOR, mcc);
        m.SetLinearColorParameterValue(MOUSE_PARAMETER_RELEASED_COLOR, mc);
    }

    CustomMouse = m;
    CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_GREYSCALE, Greyscaled ? 1.0f : 0.0f);
}

function UpdateCustomMouseColors(bool bDesaturate, Color ReleaseColor, Color PressColor)
{
    local LinearColor mc, mcc;

    Greyscaled = bDesaturate;

    MouseColor = ReleaseColor;
    MouseClickColor = PressColor;

    if(Greyscaled)
    {
        mc = ColorToLinearColor(MouseColor);
        mcc = ColorToLinearColor(MouseClickColor);
    }
    else
    {
        mc = MakeLinearColor(1.0f, 1.0f, 1.0f, 1.0f);
        mcc = mc;
    }

    CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_GREYSCALE, Greyscaled ? 1.0f : 0.0f);
    CustomMouse.SetLinearColorParameterValue(MOUSE_PARAMETER_RELEASED_COLOR, mc);
    CustomMouse.SetLinearColorParameterValue(MOUSE_PARAMETER_PRESSED_COLOR, mcc);
}

function SetNewMouseTexture(Texture2D mt)
{
    CustomMouse.SetTextureParameterValue(MOUSE_PARAMETER_TEXTURE, mt);
}

// When clicking, this needs to be manually called (mostly in "OnClick()")
function bool OnMouseClick(HUD H, bool release)
{
    if(!bCustomMouse) return false;
    bPressing = !release;
    CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_PRESSED, release ? 0.0f : 1.0f);
    return true;
}

// When hovering, this needs to be manually called! Recommend to call this when there's a valid point of interest by checking a variable or something
function bool OnMouseHover(HUD H, bool hover, optional bool HoverMatParam = false)
{
    if(!bCustomMouse) return false;
    hover = HoverMatParam && hover;
    CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_HOVER, hover ? 1.0f : 0.0f);
    IsSpecialTextureHover(H);
    return true;
}

function bool IsSpecialTextureHover(HUD H)
{
    return false;
}

function bool OnSpecialTextureHover(HUD H, Texture2D t)
{
    if(!bCustomMouse) return false;
    CustomMouse.SetTextureParameterValue(MOUSE_PARAMETER_HOVER_TEXTURE, t);
    return true;
}

// For squaring values
function float ScreenToSquaredRatio(HUD H, optional bool Width = false)
{
    return Width ? (H.Canvas.ClipX / H.Canvas.ClipY) : (H.Canvas.ClipY / H.Canvas.ClipX);
}

function Vector2D GetCorrectPointer(HUD H)
{
    local Vector2D point;
    if(bGamePad)
    {
        point.X = H.Canvas.ClipX * PointerPosition.X;
        point.Y = H.Canvas.ClipY * PointerPosition.Y;
    }
    else
        point = GetMousePos(H);
    
    return point;
}

function Vector2D V2DClamp(Vector2D V2D, Vector2D Min, Vector2D Max)
{
    V2D.X = FClamp(V2D.X, Min.X, Max.X);
    V2D.Y = FClamp(V2D.Y, Min.Y, Max.Y);
    return V2D;
}

function float PowNegative(float F, float P)
{
    return class'Hat_Math'.static.PowNegative(F, P);
}

// Every frame check to see any sign of switching between keyboard and controller
function ControlChangeWatchDog(HUD H)
{
    // If true, ignore controls cuz they are supported in a different way.
    if(bSuppressWatchDog) return;

    // Any controller
    if(IsGamePad(H) && !bGamePad)
    {
        bGamePad = true;
        OnControlsChanged(H, bGamepad);
    }
    // Mouse
    else if(!IsGamePad(H) && bGamePad)
    {
        bGamePad = false;
        OnControlsChanged(H, bGamepad);
    }
}

function OnControlsChanged(HUD H, bool GamePad)
{
    if(GamePad)
        PointerPosition = GetMousePos(H);
    else
        SetMousePos(H, PointerPosition);
    LastPointerPosition = PointerPosition;
    SetCustomMouse(H, bCustomMouse || GamePad);
}

function bool AdjustToGlobal()
{
    Global_PointManager = GetGlobalManager();
    if(Global_PointManager == None) return false;

    Greyscaled = Global_PointManager.DesaturateMouse;
    MouseColor = Global_PointManager.MouseColor;
    MouseClickColor = Global_PointManager.MouseClickColor;
    GamePadSpeedMultipier = Global_PointManager.GamePadSpeedMultipier; 
    CustomMousePositionOffset = Global_PointManager.CustomMousePositionOffset;
    return true;
}

function SS_PointerManager GetGlobalManager()
{
    local SS_PointerManager pm;

    foreach GetWorldInfo().AllActors(Class'SS_PointerManager', pm)
    {
        if(!pm.IsA('SS_PointerManager')) continue;
        return pm;
    }
    return None;
}

defaultproperties
{
    bDisableCamera = true;
    bDisableMovement = true;
    RequiresMouse = true;

    // Mouse
    MouseMat = Material'SS_PAI_Content.Cursor_Mat';
    //DefaultHoverTexture = ;
    MouseSize = 0.1f;

    // Useful for SetDrawColor(...);
    Greyscaled = true;

    // Highlighter
    BorderCorners(0) = Texture2D'hatintime_ui_demomenu.Textures.border_topleft';
    BorderCorners(1) = Texture2D'hatintime_ui_demomenu.Textures.border_topright';
    BorderCorners(2) = Texture2D'hatintime_ui_demomenu.Textures.border_bottomleft';
    BorderCorners(3) = Texture2D'hatintime_ui_demomenu.Textures.border_bottomright';
    CornerSizeMultiplier = 1.0f;
    
    GamePadSpeedMultipier = 1.0f;

    MouseColor = (R = 255, G = 255, B = 255, A = 255);
    MouseClickColor = (R = 255, G = 255, B = 255, A = 255);
}