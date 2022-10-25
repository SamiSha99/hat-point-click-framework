Class SS_HUDElement_BetterSubtitles extends Hat_HUDElement;

var String Text;
var Font Font;
var Vector2D Position;
var float Scale, ShadowAlpha, BorderWidth, VerticalSize, BorderQuality;
var bool Shadow;
var TextAlign Alignment;
var Color TextColor, BorderColor;

var bool bFadeOut, bShuttingDown;
var float Opacity, FadeSpeed, LifeTime, CurrentDuration;
var SS_SeqAct_SubtitleManager KismetSubtitle;

function OnOpenHUD(HUD H, optional String command)
{
    Text = command;
}

function bool Render(HUD H)
{
    local float x, y, s;

	if(!Super.Render(H)) return false;
    
    H.Canvas.SetDrawColor(TextColor.R, TextColor.G, TextColor.B, TextColor.A * Opacity);
    
    H.Canvas.Font = (Font != None ? Font : Class'Hat_FontInfo'.static.GetDefaultFont("abcdefghijkmnlopqrstuvwxyzABCDEFGHIJKMNLOPQRSTUVWXYZ"));

    x = H.Canvas.ClipX * Position.X;
    y = H.Canvas.ClipY * Position.Y;
    s = FMin(H.Canvas.ClipY,H.Canvas.ClipX)/1080.0f * Scale;

    DrawBorderedText(H.Canvas, Text, x, y, s, Shadow, Alignment, ShadowAlpha, BorderWidth, BorderColor, VerticalSize, BorderQuality);

    return true;
}

function bool Tick(HUD H, float d)
{
    if(!Super.Tick(H,d)) return false;
    
    CurrentDuration += d;

    if(Lifetime > 0)
    {
        LifeTime = FMax(LifeTime - d, 0.0f);
        if(LifeTime <= 0 && KismetSubtitle != None)
            KismetSubtitle.PrepareToDestroy();
    }

    if(FadeSpeed > 0)
        Opacity = FClamp(Opacity + (bFadeOut ? -1.0f : 1.0f) * (1.0f/FadeSpeed) * d, 0.0f, 1.0f);
    else
        Opacity = bFadeOut ? 0 : 1;

    if(bShuttingDown && bFadeOut && Opacity <= 0)
    {
        if(KismetSubtitle != None)
            SetTimer(H, 0.01f, false, 'OnExpiring', KismetSubtitle);
        CloseHUD(H, Class);
    }
    return true;
}

defaultproperties
{
    Font = None;
    Position = (X = 0.5f, Y = 0.8f);
    Scale = 1.0f;
    Shadow = false;
    ShadowAlpha = 0.5f;
    Alignment = TextAlign_Center;
    VerticalSize = -1;
    BorderWidth = 4;
    BorderQuality = 1;
    TextColor = (R = 255, G = 255, B = 255, A = 255);
    
    CurrentDuration = 0;
}
