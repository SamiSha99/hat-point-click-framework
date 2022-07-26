Class SS_GameMod_Minigame extends GameMod;

event OnModLoaded()
{
    HookActorSpawn(class'Hat_Player', 'Hat_Player');	
}

event OnModUnloaded()
{
    //MenuFix(true);
}

event OnHookedActorSpawn(Object NewActor, Name Identifier)
{
    //SetTimer(0.01f, false, NameOf(MenuFix), self);
}

function OnPreOpenHUD(HUD InHUD, out class<Object> InHUDElement)
{
    
}

final function Print(coerce const string msg)
{
    local WorldInfo wi;
    wi = class'WorldInfo'.static.GetWorldInfo();
    if (wi != None)
    {
        if (wi.GetALocalPlayerController() != None)
            wi.GetALocalPlayerController().TeamMessage(None, msg, 'Event', 6);
        else
            wi.Game.Broadcast(wi, msg);
    }
}