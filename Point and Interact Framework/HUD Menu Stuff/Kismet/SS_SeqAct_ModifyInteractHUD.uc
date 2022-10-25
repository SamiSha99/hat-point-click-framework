class SS_SeqAct_ModifyInteractHUD extends SequenceAction;

//var Actor PlayerTarget;
var(Settings) float InteractRange; // Range of interaction, -1 => infinity
var(Pointer) bool bCustomMouse; // If false, uses default mouse while using a mouse, consoles are ignored
var(Pointer) MaterialInterface MouseMaterial; // Set up a new material for the mouse, THIS WILL INITIALIZE THE MOUSE AGAIN!!!
var(Pointer) Texture2D MouseTexture; // Easy custom mouse texture replacement
var(Pointer) float MouseOffset; // DEFAULT IS 0.0225f!!! IT'S REALLY SMALL!!!

var(Pointer) bool DesaturateMouse; // Desaturate Mouse to allow custom coloring instead, don't activate this if your mouse texture a solid color by default!
var(Pointer) bool UseCrosshair; // Use Crosshair instead of a mouse, Mouseoffset is 0 if this is enabled
var(Pointer) Color MouseColor, MouseClickColor <EditCondition=DesaturateMouse>; // Change colors of the mouse in those stats! REQUIRES DESATURATEDMOUSE!

final function Print(coerce string msg)
{
    local WorldInfo wi;

    //if(!ALLOW_PRINT_DEBUG) return;

    wi = class'WorldInfo'.static.GetWorldInfo();
    if (wi == None) return;

    msg = "[" $ Class $ "]" @ msg;

    if(wi.GetALocalPlayerController() != None)
        wi.GetALocalPlayerController().TeamMessage(None, msg, 'Event', 6);
    else
        wi.Game.Broadcast(wi, msg);
}

event Activated()
{
	local Hat_PlayerController pc;
    local SS_HUDPAI_WorldInteraction wi;
    local Object o;

    if(InputLinks[0].bHasImpulse)
    {
        foreach Targets(o)
        {
            pc = Hat_PlayerController(GetController(Actor(o)));
            wi = SS_HUDPAI_WorldInteraction(GetHUD(pc.MyHUD));
            wi.InteractRange = InteractRange;
            wi.bCustomMouse = bCustomMouse;
            if(MouseMaterial != None)
                wi.InitCustomMouse(MouseMaterial);
            if(MouseTexture != None)
                wi.SetNewMouseTexture(MouseTexture);
            wi.CustomMousePositionOffset = UseCrosshair ? 0.0f : MouseOffset;
            wi.UpdateCustomMouseColors(DesaturateMouse, MouseColor, MouseClickColor);
            wi.ToggleCrosshair(UseCrosshair);
        }
        OutputLinks[0].bHasImpulse = true;
    }
}

function Hat_HUDElement GetHUD(HUD myHUD)
{
    local Hat_HUD h;
    h = Hat_HUD(myHUD);
    return h.GetHUD(class'SS_HUDPAI_WorldInteraction', true);
}

event CheckForErrors(out Array<string> ErrorMessages)
{
	if (Targets.Length == 0) ErrorMessages.AddItem("No player(s) specified, add a player!");
    if(InteractRange < 0 && InteractRange != -1) ErrorMessages.AddItem("Interact cannot be set below 0! Note: -1 = infinity");
	Super.CheckForErrors(ErrorMessages);
}

defaultproperties
{
    ObjName="Modify Interact HUD";
	ObjCategory="HUD";
    
    InputLinks(0)=(LinkDesc="In");
    OutputLinks(0)=(LinkDesc="Out");
    VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Mouse",PropertyName=bCustomMouse);
    VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="Offset",PropertyName=MouseOffset);

    bCallHandler = false;

    bCustomMouse = true;
    MouseOffset = 0.0225f;
    InteractRange = -1;
    MouseColor = (R = 19, G = 74, B = 255, A = 255);
    MouseClickColor = (R = 0, G = 51, B = 255, A = 255);
}