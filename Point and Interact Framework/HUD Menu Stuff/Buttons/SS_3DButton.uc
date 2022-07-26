Class SS_3DButton extends Hat_DynamicStaticActor;

var(ButtonData) Texture2D InterestTexture; // Replaces the mouse with this texture when hovering on an ENABLED BUTTON!
var(ButtonData) bool bEnabled; // Should it start enabled?
var(ButtonData) String RemoteEventName; // Allow buttons to also call remote events from Kismet! (NOTE: You can already interact with them through "On Interaction")
var(ButtonData) String EnabledMsg; // Pop up a message when interacting while enabled.
var(ButtonData) String DisabledMsg; // Pop up a message when interacting while disabled.
var(ButtonData) Vector2D Trans2D; // Position offset between -1 to 1 on the X/Y axis.
var(ButtonData) Vector2D Scale2D; // The Width/Height of the Button, see the one below for more info!
var(ButtonData) bool Squared; // If squared, it will take the Y Scale (Height) as the value of the above!

var bool Hovered, HoveredOnce;

final function Print(const string msg)
{
    local WorldInfo wi;

	wi = class'WorldInfo'.static.GetWorldInfo();
    if (wi != None)
    {
        if (wi.GetALocalPlayerController() != None)
            wi.GetALocalPlayerController().TeamMessage(None, "[DEBUG" @ Class.Name $ "]" @ msg, 'Event', 6);
        else
            wi.Game.Broadcast(wi, "[DEBUG" @ Class.Name $ "]" @ msg);
    }
}

function OnHover(Pawn p, bool hover)
{
    if(Hovered == hover) return;
    Hovered = hover;
    class'Hat_SeqEvent_OnInteraction'.static.CallInteractionEvent(self, p, hover ? "hover" : "unhover");
}

function OnInteractingWithButton(Pawn p)
{
    class'Hat_SeqEvent_OnInteraction'.static.CallInteractionEvent(self, p);
}

simulated function OnToggle( SeqAct_Toggle Action )
{
	if (Action.InputLinks[0].bHasImpulse) bEnabled = true;
    if (Action.InputLinks[1].bHasImpulse) bEnabled = false;
    if (Action.InputLinks[2].bHasImpulse) bEnabled = !bEnabled;
}

defaultproperties
{
    Begin Object Name=StaticMeshComponent0
		StaticMesh = StaticMesh'HatInTime_MafiaHQ_Vincent.models.NoCrabBucket';
		LightEnvironment= None;
		bUsePrecomputedShadows = true;
		CastShadow = false;
		bCastStaticShadow = false;
		MaxDrawDistance = 10000;
        Rotation=(Pitch=0,Yaw=0,Roll=0)
	End Object

    TickOptimize = TickOptimize_None;
	IgnoreActorCollisionWhenHidden = true;
	IgnoreTickWhenHidden = true;
	bNoDelete=false;
	bWorldGeometry = false;
	SkipForSceneCaptures = true;
    CollisionType = COLLIDE_BlockAll;
	bStatic=false
	bMovable=true
    
    Scale2D = (X = 0.1f, Y = 0.1f);

    Physics = PHYS_Interpolating;
    SupportedEvents.Add(class'Hat_SeqEvent_OnInteraction');
    bEnabled = true;
    
    TickIsDisabledBit[1] = false;
}