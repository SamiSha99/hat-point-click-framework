Class SS_HUDPAI_Darkness extends SS_HUDPAI_WorldInteraction;

// Deperacted due incompatiblity, will look for a better implementation
/* 
var MaterialInterface DarkInterface;
var MaterialInstanceTimeVarying DarknessMat;

var float Size, SizeWobble; // Wobble is Sin time effect to make it like the circle is not being hold properly

const PARAM_SIZE = 'Size';
const PARAM_SIZE_WOBBLE = 'SizeWobble';
const PARAM_ASPECT_RATIO = 'AspectRatio';
const PARAM_POS_X = 'PositionX';
const PARAM_POS_Y = 'PositionY';

function OnOpenHUD(HUD H, optional String command)
{
    Super.OnOpenHUD(H, command);
    InitDarknessMaterial();
}

function InitDarknessMaterial()
{
    local MaterialInstanceTimeVarying m;
    
    m = new Class'MaterialInstanceTimeVarying';
    m.SetParent(DarkInterface);
    DarknessMat = m;
    DarknessMat.SetScalarParameterValue(PARAM_SIZE_WOBBLE, SizeWobble);
    DarknessMat.SetScalarParameterValue(PARAM_SIZE, Size);
}

function bool Render(HUD H)
{
    if(!IsEnabled() || H.PlayerOwner == None) return false;
    // tbh very bad on pracitce
    ManageDarkMaterial(H);
    return Super.Render(H);
}

function ManageDarkMaterial(HUD H)
{
    local Vector2D p;
    if(DarknessMat == None) return;
    p = GetCorrectPointer(H);
    DarknessMat.SetScalarParameterValue(PARAM_ASPECT_RATIO, Clips.X/Clips.Y);
    DarknessMat.SetScalarParameterValue(PARAM_POS_X, p.x/Clips.X);
    DarknessMat.SetScalarParameterValue(PARAM_POS_Y, p.y/Clips.Y);
    DrawClippedMat(H, 0.5f, 0.5f, Clips.X, Clips.Y, DarknessMat);
}

defaultproperties
{
    DarkInterface = Material'SS_Minigame_Content.Material.DarkHUD';
    Size = 0.25f;
    SizeWobble = 0.05f;
}
*/