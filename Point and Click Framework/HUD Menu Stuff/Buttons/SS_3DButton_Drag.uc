Class SS_3DButton_Drag extends SS_3DButton_Drag_Base;

var Vector DragLocation;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    DragLocation = Location;
    TrySnapLocation(DragLocation);
}

function CalculateDrag(HUD H, SS_HUDPAI_WorldInteraction wi, Vector2D point)
{
    local Vector WorldOrigin, WorldDirection;
    local Vector HitLocation, HitNormal;
    local Actor a;

    Super.CalculateDrag(H, wi, point);

    H.Canvas.DeProject(point, WorldOrigin, WorldDirection);

    if(bEnableDragDebug)
    {
        wi.DrawCenterMat(H, point.X, point.Y, 64, 64, Material'SS_Minigame_Content.Material.Cross_UI');
        wi.DrawBorderedText(H.Canvas, "DragPoint = (" $ Int(point.X) $ ", " $ Int(point.Y) $ ")", point.X, point.Y - DEBUG_TEXT_OFFSET, DEBUG_TEXT_SIZE,,TextAlign_Center);
    }

    foreach TraceActors(Class'Actor', a, HitLocation, HitNormal, WorldOrigin + WorldDirection * 99999999, WorldOrigin)
    {
        if(a.IsA('Volume')) continue;
        if(a == self) continue;
        break;
    }

    DragLocation = HitLocation;
}

function Vector GetCurrentDragLocation()
{
    return DragLocation;
}