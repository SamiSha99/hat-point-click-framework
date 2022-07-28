# Point and Click Framework v1.0.0
A framework made for modding puporses that allows modders to create point and click interactivity between the player and the world around them. The system is entirely built upon "Hat_HUD" a system found in the game with the addition of interactivity through actors and Kismet functionality.

The implementation is quick and simple and allows a lot of customizability through changing the mouse look, colors when Un/Hovering and size.

The system interacts through "point and click" with "3D buttons" that the player can drop in the scene and the rest is done through Kismet.

# Documentation
This section provides documentation for the many features this framework provides:

## How to setup
Any of the HUD classes such as `SS_HUDPAI_FP_Interact` and `SS_HUDPAI_WorldInteraction` should called through "OpenHUD" found in Kismet and the system should work as intended from this point, the mouse will appear on the player's screen and they can "click".

It is worth noting that "Set Camera Target" node in Kismet has great synergy with the system as you can essentially create point and click interaction for all your needs.

## `SS_HUDPAI_Base`
The main essential class that is running everything in the background, please note that this should never be directly opened through the "OpenHUD" in Kismet as this class is designed to be [abstract](https://en.wikipedia.org/wiki/Abstract_type) and should be instead extended from and use that extended class instead.

## `SS_HUDPAI_WorldInteraction`
A basic class meant to interact with the world through the camera, recommended to use "Set Camera Target" after opening the HUD, as it will keep the player in the middle screen which doesn't look good on paper.

## `SS_HUDPAI_FP_Interact`
A first person only HUD that runs ONLY when the player is in first person in two different conditions:
1) The player is zoomed to the max and went into first person mode, then the HUD will activate, going out will only "disable" it but it is still running in the background.
2) The player has `SS_CamMode_FirstPerson` which was added through a "Camera Mode" Kismet node, this camera mode makes the player permanently first person until removed through "Camera Mode".

```uc
function bool IsFirstPerson(HUD H)
{
    local Hat_PlayerCamera pc;
    local Hat_CamMode cm;

    if(Hat_PawnHiding(H.PlayerOwner.Pawn).IsFirstPerson()) return true;
    
    pc = Hat_PlayerCamera(Hat_PlayerController(H.PlayerOwner).PlayerCamera);
    foreach pc.CameraModes(cm) if(cm.IsA('SS_CamMode_FirstPerson')) return true;

    return false;
}
```
## Global and Local Alteration

### **Global**
Simply put, `SS_PointerManager` is an actor that can be dropped in the scene that will globally modify the rules of any PAI HUD that gets activated, you do not need to set this for clarity but if you want to directly alter something specific this is useful without the need of extending a class to alter their `defaultproperties`.

This is first thing checked whenever ANY HUD extending `SS_HUDPAI_Base` gets activated.

```uc
function OnOpenHUD(HUD H, optional String command)
{
    Super.OnOpenHUD(H, command);
    AdjustToGlobal();
    ControlChangeWatchDog(H);
    if(bCustomMouse || bGamepad) SetCustomMouse(H, true);
    PointerPosition = IsGamePad(H) ? vect2d(0.5f, 0.5f) : vect2d(0.0f, 0.0f);
}

function bool AdjustToGlobal()
{
    Global_PointManager = GetGlobalManager();
    if(Global_PointManager == None) return false;

    Greyscaled = Global_PointManager.DesaturateMouse;
    MouseColor = Global_PointManager.MouseColor;
    MouseClickColor = Global_PointManager.MouseClickColor;
    GamePadSpeedMultipier = Global_PointManager.GamePadSpeedMultipier; 
    CustomMousePositionOffset = Global_PointManager.CustomMousePositionOffset;
    return true;
}
```

### **Local**
Using `SS_SeqAct_ModifyInteractHUD`(Kismet name: `Modify Interact HUD`) you can modify the HUD temporarly for the currently run one by referencing the player that has a PAI HUD running in their HUD list, you can directly modify a lot of the content similarly to the Global variation.

## Coloring and Custom Mouse
Currently can be done through using `SS_SeqAct_ModifyInteractHUD`(Kismet name: `Modify Interact HUD`) by putting the right inputs, this will be changed to allow for a global alterations, otherwise, extend one of the classes and replace the variable `MouseTexture` with the new Texture you want.

## Buttons

Essentially the _Interact_ part of the _Pointing_ and then _Interacting_ resulting the designated result we want to go for.

To put it short, drag them to the scene, adjust the mesh to whatever you want and then create "On Interaction" event in Kismet, everytime you click on the button it will send an event to that Interaction event in Kismet, and you do the rest from that point.

### Draggers
Essentially WIP still but they serve the ability to drag buttons in the scene, you can somewhat do some support wiht it but currently it is limited and serve mostly decoration or to work with other buttons that can be "clicked" (basically none draggers, think of like opening a shelf and then click to grab something).

### `SS_3DButton_Drag_Base`
An abstract class designed to setup dragger buttons as whole.

### `SS_3DButton_Drag`
A basic drag button that can be dragged anywhere on the map and released.

### `SS_3DButton_Drag_Directional`
A drag button that limited to a direction with a range of how much can be dragged (think of [abacus](https://en.wikipedia.org/wiki/Abacus), [here's one if you still have no idea what I'm saying here](https://i.imgur.com/6SJet85.png)).

### `SS_3DButton_Drag_Volume`
Similarly to `SS_3DButton_Drag` but limited through a Volume only.

## Console Support
This framework has full console support, meaning joysticks will work properly in moving the mouse around the screen to interact with anything visible.
