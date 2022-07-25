// HUD Menu that activates during First Person
Class SS_HUDPAI_FP_Interact extends SS_HUDPAI_WorldInteraction;

var Texture2D FirstPersonAimMarker;

function OnOpenHUD(HUD H, optional String command)
{
    Super.OnOpenHUD(H, command);
    SetNewMouseTexture(FirstPersonAimMarker);
}

function bool PointOnClickable(HUD H, optional Vector2D point)
{
    if(!IsFirstPerson(H))
    {
        HighlightButton = None;
        return false;
    }

    return Super.PointOnClickable(H, vect2d(H.Canvas.ClipX * 0.5f, H.Canvas.ClipY * 0.5f));
}

/*
function bool Render(HUD H)
{    
    if(!Super.Render(H)) return false;
    
    return true;
}
*/

function DoPopUp(HUD H, SS_3DButton button)
{
    local TextPopUp t;

    bButtonPopUp = false;
    t.text = (ButtonEnabled(button) ? HighlightButton.EnabledMsg : HighlightButton.DisabledMsg);
    if(t.text ~= "") return;
    t.pos = vect2d(0.5f * H.Canvas.ClipX, 0.5f * H.Canvas.ClipY); //button.Location;
    PopUps.AddItem(t);
}

function DrawCustomMouse(HUD H)
{
    local float X, Y;
    X = 0.5f;
    Y = 0.5f;
    DrawClippedCenter(H, X, Y, MouseSize * H.Canvas.ClipY, MouseSize * H.Canvas.ClipY, CustomMouse);
}

function bool IsFirstPerson(HUD H)
{
    local Hat_PlayerCamera pc;
    local Hat_CamMode cm;

    if(Hat_PawnHiding(H.PlayerOwner.Pawn).IsFirstPerson()) return true;
    
    pc = Hat_PlayerCamera(Hat_PlayerController(H.PlayerOwner).PlayerCamera);
    foreach pc.CameraModes(cm) if(cm.IsA('SS_CamMode_FirstPerson')) return true;

    return false;
}

function PreCalculateDrag(HUD H)
{
    SS_3DButton_Drag_Base(DragHighlightButton).CalculateDrag(H, self, vect2d(H.Canvas.ClipX * 0.5f, H.Canvas.ClipY * 0.5f));
}

defaultproperties
{
    RequiresMouse = false;
    OverrideAttack = true;
    //bCustomMouse = false;
    bDisableMovement = false;
    bDisableCamera = false;
    InteractRange = 600.0f;
    bSuppressWatchDog = true;
    MouseSize = 0.08f;
    FirstPersonAimMarker = Texture2D'SS_Minigame_Content.Crosshair';
}