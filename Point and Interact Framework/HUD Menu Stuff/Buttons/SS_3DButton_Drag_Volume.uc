Class SS_3DButton_Drag_Volume extends SS_3DButton_Drag;

var(Volume) PhysicsVolume PhysicsVolumeZone; // The zone to limit into! You cannot drag beyond this volume! REQUIRES PHYSICAL VOLUME!

function PostBeginPlay()
{
    local Vector HitLocation;
    Super.PostBeginPlay();
    DragLocation = Location;
    if(PhysicsVolumeZone == None || InsideVolume(DragLocation)) return;
    HitLocation = GetNearestPVZPoint(DragLocation);
    DragLocation = HitLocation;
    TrySnapLocation(DragLocation);
}

function CalculateDrag(HUD H, SS_HUDPAI_WorldInteraction wi, Vector2D point)
{
    local Vector HitLocation;

    Super.CalculateDrag(H, wi, point);

    if(PhysicsVolumeZone == None || InsideVolume(DragLocation)) return;

    HitLocation = GetNearestPVZPoint(DragLocation);
    DragLocation = HitLocation;
}

function Vector GetNearestPVZPoint(Vector point)
{
    local PhysicsVolume v;
    local Vector HitNormal, VZLoc, HitLocation;

    point.Z = PhysicsVolumeZone.Location.Z;
    VZLoc = PhysicsVolumeZone.Location;
    //VZLoc.Z = Location.Z;
    foreach TraceActors(Class'PhysicsVolume', v, HitLocation, HitNormal, VZLoc, point)
    {
        if(v != PhysicsVolumeZone) continue;
        return HitLocation;
    }

    return vect(0,0,0);
}

function bool InsideVolume(Vector point)
{
    local Volume v;

    foreach OverlappingActors(class'Volume', v, 1, point, false)
	{
        if(v != PhysicsVolumeZone) continue;
        return true;
    }
    return false;
}

function Vector GetCurrentDragLocation()
{
    return DragLocation;
}