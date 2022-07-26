Class SS_3DButton_Drag_Base extends SS_3DButton
    abstract;

var(DragSettings) float DragSmoothness <UIMin=0.0 | UIMax=100.0>; // How smooth does the drag move, lower numbers make it slow while higher make it snap to the current position.
var(DragSettings) bool bSnapToGround; // Snaps to the surface (like stairs) when dragging. Starts the check from above to below using MaxUpSnap and MaxDownSnap as limits, see the values below. If it doesn't find anything it will stay in its place like if this was set to false. IT ONLY TAKES THE FIRST HIT LOCATION, ANYTHING ELSE IS IRRELEVANT WHEN THE CHECK HAPPENS.
var(DragSettings) float MaxUpSnap <EditCondition=bSnapToGround>; // The max height to snap to from ABOVE, anything higher than that will not be snapped with.
var(DragSettings) float MaxDownSnap <EditCondition=bSnapToGround>; // The max height to snap to from BELOW, anything LOWER than that will not be snapped with.
var(DragSettings) Vector SnapOffset <EditCondition=bSnapToGround>; // After figuring out a snapping point, add this offset to it, this is good if meshes would end up floating after snapping!
var(DragSettings) bool bEnableDragDebug; // Draws on the UI to help to get an idea (only run time)
var(ButtonData) Texture2D InterestDragTexture; // Top priortiy, drag texture over anything else.

var float Range;
var Vector StartLocation;
var bool bDragged;

const DEBUG_TEXT_SIZE = 0.425f;
const DEBUG_TEXT_OFFSET = 64;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    StartLocation = Location;
    SetTickIsDisabled(!bEnabled);
}

function Tick(float d)
{
    DoDrag(d);
}

// Calculate the Mesh true location during the drag, this is feeded from the HUD.
// point => Mouse/Console Pointer on a screen, remember to deproject!
function CalculateDrag(HUD H, SS_HUDPAI_WorldInteraction wi, Vector2D point)
{
    local Vector v;
    if(!bEnabled) return;
    if(bEnableDragDebug && bSnapToGround)
    {
        v = GetCurrentDragLocation();
        DrawDebugCylinder(v + vect(0,0,1) * MaxUpSnap, v + vect(0,0,-1) * MaxDownSnap, 1, 15, 255, 0, 0, false);
    }
}

function DoDrag(float d)
{
    local Vector newLocation, endLocation;
    
    d = FMin(DragSmoothness * d, 1.0f);

    endLocation = GetCurrentDragLocation();
    if(endLocation == Location) return;
    newLocation = Location;
    newLocation = class'Hat_Math_Base'.static.VInterpolationDecelerate(newLocation, endLocation, d);

    TrySnapLocation(newLocation);
}

function Vector GetCurrentDragLocation()
{
    return Location;
}

function bool SnapToGround(out Vector NewLocation)
{
    local Vector HitLocation, HitNormal;
    
    if(Trace(HitLocation, HitNormal, NewLocation + vect(0,0,-1) * MaxDownSnap, NewLocation + vect(0,0,1) * MaxUpSnap) != None)
    {
        NewLocation = HitLocation;
        return true;
    }
    return false;
}

function TrySnapLocation(Vector newLocation)
{
    if(bSnapToGround && SnapToGround(newLocation))
        SetLocation(newLocation + SnapOffset);
    else
        SetLocation(newLocation);
}

simulated function OnToggle( SeqAct_Toggle Action )
{
	Super.OnToggle(Action);
    SetTickIsDisabled(!bEnabled);
}

defaultproperties
{
    InterestDragTexture = None;
    MaxUpSnap = 100.0f;
    MaxDownSnap = 100.0f;
    DragSmoothness = 8;

    TickIsDisabledBit[1] = false;
}