Class SS_3DButton_Drag_Directional extends SS_3DButton_Drag_Base
    placeable;

var(DragSpecial) float DragRange; // The range this button can be dragged in.
var(DragSpecial) float StartRange <UIMin=0.0 | UIMax=1.0>;// 0 = Start Location, 1 = End location, use this for variety of starting points.
var(DragSpecial) Vector DragDirection; // The direction, going between -1 to 1, pro tip: think of end values (1 and -1) like up, down, left, right! THIS GETS NORMALIZED, KEEP IT BETWEEN -1 AND 1!!!!
function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(StartRange <= 0) return;
    Range -= StartRange;
    TrySnapLocation(GetCurrentDragLocation());
}

function CalculateDrag(HUD H, SS_HUDPAI_WorldInteraction wi, Vector2D point)
{
    local Vector DragStart, DragEnd, DragPoint;
    local float ClosestPoint, LongestRange, DragStartRange, DragEndRange;

    Super.CalculateDrag(H, wi, point);

    // Get Start, End and point between the two lines
    DragStart = H.Canvas.Project(StartLocation);
    DragEnd = H.Canvas.Project(StartLocation + Normal(DragDirection) * DragRange);
    PointDistToLine(vect(1,0,0) * point.X + vect(0,1,0) * point.Y, Normal(DragEnd - DragStart), DragStart, DragPoint);

    // Get relevant ranges
    LongestRange = VSize2D(DragEnd - DragStart); // End to Start
    DragStartRange =  VSize2D(DragPoint - DragStart); // Drag to Start
    DragEndRange = VSize2D(DragEnd - DragPoint); // End to Drag
    
    if(bEnableDragDebug)
    {
        wi.DrawCenterMat(H, DragStart.X, DragStart.Y, 64, 64, Material'SS_PAI_Content.Material.Cross_UI');
        wi.DrawBorderedText(H.Canvas, "DragStart = (" $ Int(DragStart.X) $ ", " $ Int(DragStart.Y) $ ")", DragStart.X, DragStart.Y - DEBUG_TEXT_OFFSET, DEBUG_TEXT_SIZE,,TextAlign_Center);
        wi.DrawCenterMat(H, DragEnd.X, DragEnd.Y, 64, 64, Material'SS_PAI_Content.Material.Cross_UI');
        wi.DrawBorderedText(H.Canvas, "DragEnd = (" $ Int(DragEnd.X) $ ", " $ Int(DragEnd.Y) $ ")", DragEnd.X, DragEnd.Y - DEBUG_TEXT_OFFSET, DEBUG_TEXT_SIZE,,TextAlign_Center);
        wi.DrawCenterMat(H, DragPoint.X, DragPoint.Y, 64, 64, Material'SS_PAI_Content.Material.Cross_UI');
        wi.DrawBorderedText(H.Canvas, "DragPoint = (" $ Int(DragPoint.X) $ ", " $ Int(DragPoint.Y) $ ")", DragPoint.X, DragPoint.Y + DEBUG_TEXT_OFFSET, DEBUG_TEXT_SIZE,,TextAlign_Center);
    }
    
    // Snap to edges, otherwise set drag to correct range
    if(LongestRange < DragStartRange && DragEndRange < DragStartRange)
        ClosestPoint = 0;
    else if (LongestRange < DragEndRange)
        ClosestPoint = LongestRange;
    else
        ClosestPoint = DragEndRange;

    // Finalize the range, and let this button handle the rest from the Tick() function, Range is 0 - 1
    Range = FClamp(ClosestPoint / LongestRange, 0.0f, 1.0f);
}

function Vector GetCurrentDragLocation()
{
    return StartLocation + Normal(DragDirection) * Lerp(0.0f, DragRange, 1.0f - Range);
}

defaultproperties
{
    DragRange = 150.0f;
    Range = 1.0f;
    DragDirection = (X = 1);
}