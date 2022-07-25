// HUD Menu designed to interact with the world when possible
Class SS_HUDPAI_WorldInteraction extends SS_HUDPAI_Base;

struct TextPopUp
{
    var Vector2D pos;
    var String text;
    var float Opacity;
    structdefaultproperties
    {
        Opacity = 1.0f;
    }
};

var Array<TextPopUp> PopUps;
var String RemoteEventTarget;
var bool InTransition, bButtonPopUp, bDragging, OverrideAttack;
var SS_3DButton HighlightButton, LastHighlightButton, DragHighlightButton;
var float InteractRange;
var Vector2D Clips;

const MOUSE_PARAMETER_DRAG = 'Drag';
const MOUSE_PARAMETER_DRAG_TEXTURE = 'DragTexture';

const POPUP_MOVEMENT_AMOUNT = -0.1f;

var bool ShowHighlighterForEnabledButtons, ShowHighlighterForDisabledButtons;

function bool Render(HUD H)
{
    local Vector ButtonLoc;
    local Vector2D ButtonScreenPos;
    local int i;

    if(!Super.Render(H)) return false;

    Clips.X = H.Canvas.ClipX;
    Clips.Y = H.Canvas.ClipY;

    H.Canvas.SetDrawColor(255,255,255,255);
    H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont("abcdefghijkmnlopqrstuvwxyzABCDEFGHIJKMNLOPQRSTUVWXYZ");

    if(ButtonEnabled(DragHighlightButton))
    {
        PreCalculateDrag(H);
    }
    else if(PointOnClickable(H, GetCorrectPointer(H)) && ShouldShowHighlighter(HighlightButton))
    {
        ButtonLoc = H.Canvas.Project(HighlightButton.Location);
        ButtonScreenPos.X = ButtonLoc.X / H.Canvas.ClipX + HighlightButton.Trans2D.X;
        ButtonScreenPos.Y = ButtonLoc.Y / H.Canvas.ClipY + HighlightButton.Trans2D.Y;
        CornerBorders(H, GetWorldInfo().TimeSeconds, ButtonScreenPos, HighlightButton.Squared, HighlightButton.Scale2D);
    }

    // Text Popup
    if(bButtonPopUp) DoPopUp(H, HighlightButton);
    for(i = 0; i < PopUps.Length; i++) DrawPopUp(H, i);
    
    return true;
}

function bool Tick(HUD H, float d)
{
    local int i;

    if (!Super.Tick(H, d)) return false;

    OnMouseHover(H, HighlightButton != None, ButtonEnabled(HighlightButton) && HighlightButton.InterestTexture != None);

    for(i = 0; i < PopUps.Length; i++)
    {
        PopUps[i].Opacity -= d*0.75f;
        if(PopUps[i].Opacity <= 0.0f)
        {
            PopUps.Remove(i, 1);
            i--;
        }
    }

	return true;
}

function bool OnClick(HUD H, bool release)
{
    If(!MouseActivated && bForceMouseActivatedCheck) return false;

    OnMouseClick(H, release);

    if(HighlightButton == None && DragHighlightButton == None) return OverrideAttack;

    bButtonPopUp = !release;

    if(!ButtonEnabled(HighlightButton)) return true;

    if(HighlightButton.IsA('SS_3DButton_Drag_Base') || DragHighlightButton != None)
    {
        bDragging = !release;
        SS_3DButton_Drag_Base(DragHighlightButton).bDragged = bDragging;
        DragHighlightButton = (release ? None : HighlightButton);
        OnDrag(H, release);
        if(DragHighlightButton == None) return true;
    }

    if(release) return true;

    HighlightButton.OnInteractingWithButton(H.PlayerOwner.Pawn);
    CallRemoteEvent(Name(HighlightButton.RemoteEventName), H.PlayerOwner.Pawn);

    return true;
}

function bool OnMouseHover(HUD H, bool hover, optional bool HoverMatParam = false)
{
    if(!Super.OnMouseHover(H, hover, HoverMatParam)) return false;
    if(LastHighlightButton == None && HighlightButton == None) return false;
    if(LastHighlightButton.Hovered == hover) return false;
    LastHighlightButton.HoveredOnce = true;
    LastHighlightButton.OnHover(H.PlayerOwner.Pawn, hover);
    return true;
}

// Button function helpers

function DoPopUp(HUD H, SS_3DButton button)
{
    local TextPopUp t;

    bButtonPopUp = false;
    t.text = (ButtonEnabled(button) ? HighlightButton.EnabledMsg : HighlightButton.DisabledMsg);
    if(t.text ~= "") return;
    t.pos = GetCorrectPointer(H); //button.Location;
    PopUps.AddItem(t);
}

function DrawPopUp(HUD H, int i)
{
    local Vector2D v;
    local TextPopUp t;
    t = PopUps[i];
    v = t.pos; //H.Canvas.Project(t.pos);
    v.X = v.X / H.Canvas.ClipX;
    v.Y = v.Y / H.Canvas.ClipY; 
    H.Canvas.SetDrawColor(255,255,255, t.Opacity * 255);
    DrawClippedBorderedText(H, t.text, v.X, v.Y + Lerp(POPUP_MOVEMENT_AMOUNT, 0, t.Opacity), 0.75f, false, TextAlign_Center);
}

function bool PointOnClickable(HUD H, optional Vector2D point)
{
    local WorldInfo wi;
    local Vector HitLocation, HitNormal, WorldOrigin, WorldDirection;
    local SS_3DButton b, lB;
    wi = GetWorldInfo();
    if(wi == None) return false;
    
    //Print("Scanning stay sharp!");
    H.Canvas.DeProject(point, WorldOrigin, WorldDirection);
    if(InteractRange == -1) InteractRange = 99999999.0f;

    foreach wi.TraceActors(Class'SS_3DButton', b, HitLocation, HitNormal, WorldOrigin + InteractRange * WorldDirection, WorldOrigin)
    {
        if(!b.IsA('SS_3DButton')) continue;
        if(b.bHidden) continue;
        //Print("Found it!");
        lB = b;
        break;
    }

    HighlightButton = lB;
    if(HighlightButton != None)
    {
        if(LastHighlightButton != HighlightButton)
            OnMouseHover(H, false, ButtonEnabled(HighlightButton));
        LastHighlightButton = HighlightButton;
    }
    return HighlightButton != None && HighlightButton.IsA('SS_3DButton');
}

function bool IsSpecialTextureHover(HUD H)
{
    local Texture2D t;

    if(HighlightButton != None && HighlightButton.InterestTexture != None && ButtonEnabled(HighlightButton))
        t = HighlightButton.InterestTexture;
    else
        CustomMouse.ClearTextureParameterValue(MOUSE_PARAMETER_HOVER_TEXTURE);
    return OnSpecialTextureHover(H, t);
}   

function PreCalculateDrag(HUD H)
{
    SS_3DButton_Drag_Base(DragHighlightButton).CalculateDrag(H, self, GetCorrectPointer(H));
}

function bool OnDrag(HUD H, bool release)
{
    local SS_3DButton_Drag_Base drag;
    if(DragHighlightButton == None || release)
    {
        CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_DRAG, 0.0f);
        CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_HOVER, 0.0f);
        return true;
    } 
    drag = SS_3DButton_Drag_Base(DragHighlightButton);
    if(drag.InterestDragTexture == None) return true;
    CustomMouse.SetScalarParameterValue(MOUSE_PARAMETER_DRAG, release ? 0.0f : 1.0f);
    CustomMouse.SetTextureParameterValue(MOUSE_PARAMETER_DRAG_TEXTURE, drag.InterestDragTexture);
    
    return true;
}

function bool ButtonEnabled(SS_3DButton b)
{
    return b != None && b.bEnabled;
}

function bool ShouldShowHighlighter(SS_3DButton b)
{
    local bool bb;
    if(!ShowHighlighter) return false;
    bb = ButtonEnabled(b);
    if(bb && ShowHighlighterForEnabledButtons) return true;
    if(!bb && ShowHighlighterForDisabledButtons) return true;
    return false;
}

function bool AdjustToGlobal()
{
    if(!Super.AdjustToGlobal()) return false;
    ShowHighlighter = Global_PointManager.ShowHighlighter;
    ShowHighlighterForEnabledButtons = Global_PointManager.ShowHighlighterForEnabledButtons;
    ShowHighlighterForDisabledButtons = Global_PointManager.ShowHighlighterForDisabledButtons;
    InteractRange = Global_PointManager.InteractRange;
    return true;
}


defaultproperties
{
    ShowHighlighter = true;
    ShowHighlighterForEnabledButtons = true;
    ShowHighlighterForDisabledButtons = false;
    bCustomMouse = true;
    InteractRange = -1;
    CustomMousePositionOffset = 0.0225f;
}