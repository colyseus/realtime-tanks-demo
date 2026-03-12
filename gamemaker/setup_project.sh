#!/bin/bash
# =============================================================================
# GameMaker Project Generator for TankBattle
# Generates all .yy metadata files and copies Kenney sprite assets
# =============================================================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/TankBattle" && pwd)"
KENNEY_DIR="$(cd "$(dirname "$0")/../kenney_top-down-tanks/PNG" && pwd)"

echo "Project dir: $PROJECT_DIR"
echo "Kenney dir: $KENNEY_DIR"

# Generate unique GUIDs using uuidgen
next_guid() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

# =============================================================================
# Sprite Setup: copy PNGs and generate .yy files
# =============================================================================

create_sprite() {
    local name="$1"
    local src_png="$2"
    local origin_x="$3"
    local origin_y="$4"
    local width="$5"
    local height="$6"

    local spr_dir="$PROJECT_DIR/sprites/$name"
    mkdir -p "$spr_dir"

    local frame_guid=$(next_guid)
    local layer_guid=$(next_guid)
    local sprite_guid=$(next_guid)

    # Copy PNG as frame
    cp "$src_png" "$spr_dir/$frame_guid.png"

    cat > "$spr_dir/$name.yy" <<EOYY
{
  "\$GMSprite":"",
  "%Name":"$name",
  "bboxMode":0,
  "bbox_bottom":$((height - 1)),
  "bbox_left":0,
  "bbox_right":$((width - 1)),
  "bbox_top":0,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {"$GMSpriteFrame":"","%Name":"$frame_guid","name":"$frame_guid","resourceType":"GMSpriteFrame","resourceVersion":"2.0"}
  ],
  "gridX":0,
  "gridY":0,
  "height":$height,
  "HTile":false,
  "layers":[
    {"$GMImageLayer":"","%Name":"$layer_guid","blendMode":0,"displayName":"default","isLocked":false,"name":"$layer_guid","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true}
  ],
  "name":"$name",
  "nineSlice":null,
  "origin":9,
  "parent":{"name":"Sprites","path":"folders/Sprites.yy"},
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "\$GMSequence":"",
    "%Name":"$name",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{"$KeyframeStore<MessageEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"2.0"},
    "eventStubScript":null,
    "eventToFunction":{},
    "length":1.0,
    "lockOrigin":false,
    "moments":{"$KeyframeStore<MomentsEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"2.0"},
    "name":"$name",
    "playback":1,
    "playbackSpeed":15.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[{"$Keyframe<SpriteFrameKeyframe>":"","Channels":{"0":{"$SpriteFrameKeyframe":"","Id":{"name":"$frame_guid","path":"sprites/$name/$name.yy"},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0"}},"Disabled":false,"id":"$sprite_guid","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false}],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0"},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0}
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":$origin_x,
    "yorigin":$origin_y
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{"name":"Default","path":"texturegroups/Default"},
  "type":0,
  "VTile":false,
  "width":$width
}
EOYY
    echo "  Created sprite: $name ($width x $height)"
}

create_animated_sprite() {
    local name="$1"
    shift
    local origin_x="$1"
    shift
    local origin_y="$1"
    shift
    local width="$1"
    shift
    local height="$1"
    shift
    # Remaining args are source PNGs

    local spr_dir="$PROJECT_DIR/sprites/$name"
    mkdir -p "$spr_dir"

    local frames_json=""
    local keyframes_json=""
    local frame_idx=0

    for src_png in "$@"; do
        local frame_guid=$(next_guid)
        local kf_guid=$(next_guid)
        cp "$src_png" "$spr_dir/$frame_guid.png"

        if [ $frame_idx -gt 0 ]; then
            frames_json="$frames_json,"
            keyframes_json="$keyframes_json,"
        fi
        frames_json="$frames_json{\"\\$GMSpriteFrame\":\"\",\"%Name\":\"$frame_guid\",\"name\":\"$frame_guid\",\"resourceType\":\"GMSpriteFrame\",\"resourceVersion\":\"2.0\"}"
        keyframes_json="$keyframes_json{\"\\$Keyframe<SpriteFrameKeyframe>\":\"\",\"Channels\":{\"0\":{\"\\$SpriteFrameKeyframe\":\"\",\"Id\":{\"name\":\"$frame_guid\",\"path\":\"sprites/$name/$name.yy\"},\"resourceType\":\"SpriteFrameKeyframe\",\"resourceVersion\":\"2.0\"}},\"Disabled\":false,\"id\":\"$kf_guid\",\"IsCreationKey\":false,\"Key\":$frame_idx.0,\"Length\":1.0,\"resourceType\":\"Keyframe<SpriteFrameKeyframe>\",\"resourceVersion\":\"2.0\",\"Stretch\":false}"
        frame_idx=$((frame_idx + 1))
    done

    local layer_guid=$(next_guid)

    cat > "$spr_dir/$name.yy" <<EOYY
{
  "\$GMSprite":"",
  "%Name":"$name",
  "bboxMode":0,
  "bbox_bottom":$((height - 1)),
  "bbox_left":0,
  "bbox_right":$((width - 1)),
  "bbox_top":0,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[$frames_json],
  "gridX":0,
  "gridY":0,
  "height":$height,
  "HTile":false,
  "layers":[
    {"\\$GMImageLayer":"","%Name":"$layer_guid","blendMode":0,"displayName":"default","isLocked":false,"name":"$layer_guid","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true}
  ],
  "name":"$name",
  "nineSlice":null,
  "origin":9,
  "parent":{"name":"Sprites","path":"folders/Sprites.yy"},
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "\\$GMSequence":"",
    "%Name":"$name",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{"\\$KeyframeStore<MessageEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"2.0"},
    "eventStubScript":null,
    "eventToFunction":{},
    "length":$frame_idx.0,
    "lockOrigin":false,
    "moments":{"\\$KeyframeStore<MomentsEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"2.0"},
    "name":"$name",
    "playback":1,
    "playbackSpeed":10.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"\\$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"\\$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[$keyframes_json],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0"},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0}
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":$origin_x,
    "yorigin":$origin_y
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{"name":"Default","path":"texturegroups/Default"},
  "type":0,
  "VTile":false,
  "width":$width
}
EOYY
    echo "  Created animated sprite: $name ($width x $height, $frame_idx frames)"
}

echo ""
echo "=== Creating Sprites ==="

# Tank bodies (75x70, origin center)
create_sprite "spr_tank_body_red"    "$KENNEY_DIR/Tanks/tankRed.png"    37 35 75 70
create_sprite "spr_tank_body_blue"   "$KENNEY_DIR/Tanks/tankBlue.png"   37 35 75 70
create_sprite "spr_tank_body_green"  "$KENNEY_DIR/Tanks/tankGreen.png"  37 35 75 70
create_sprite "spr_tank_body_yellow" "$KENNEY_DIR/Tanks/tankBeige.png"  37 35 75 70

# Barrels (16x50, origin at bottom-center for pivot)
create_sprite "spr_barrel_red"    "$KENNEY_DIR/Tanks/barrelRed.png"    8 40 16 50
create_sprite "spr_barrel_blue"   "$KENNEY_DIR/Tanks/barrelBlue.png"   8 40 16 50
create_sprite "spr_barrel_green"  "$KENNEY_DIR/Tanks/barrelGreen.png"  8 40 16 50
create_sprite "spr_barrel_yellow" "$KENNEY_DIR/Tanks/barrelBeige.png"  8 40 16 50

# Bullets (12x26, origin center)
create_sprite "spr_bullet"         "$KENNEY_DIR/Bullets/bulletSilver.png"      6 13 12 26
create_sprite "spr_bullet_special" "$KENNEY_DIR/Bullets/bulletYellowSilver.png" 6 13 12 26
create_sprite "spr_bullet_red"     "$KENNEY_DIR/Bullets/bulletRed.png"         6 13 12 26
create_sprite "spr_bullet_blue"    "$KENNEY_DIR/Bullets/bulletBlue.png"        6 13 12 26
create_sprite "spr_bullet_green"   "$KENNEY_DIR/Bullets/bulletGreen.png"       6 13 12 26
create_sprite "spr_bullet_yellow"  "$KENNEY_DIR/Bullets/bulletYellow.png"      6 13 12 26

# Environment
create_sprite "spr_sand"       "$KENNEY_DIR/Environment/sand.png"      64 64 128 128
create_sprite "spr_tree_small" "$KENNEY_DIR/Environment/treeSmall.png" 43 43 87 87
create_sprite "spr_tree_large" "$KENNEY_DIR/Environment/treeLarge.png" 43 43 87 87

# Obstacles
create_sprite "spr_sandbag"          "$KENNEY_DIR/Obstacles/sandbagBeige.png"  33 22 66 44
create_sprite "spr_barrel_obstacle"  "$KENNEY_DIR/Obstacles/barrelGrey_up.png" 24 24 48 48
create_sprite "spr_oil"             "$KENNEY_DIR/Obstacles/oil.png"            24 24 48 48

# Smoke (animated, 6 frames, 87x87, origin center)
create_animated_sprite "spr_smoke" 43 43 87 87 \
    "$KENNEY_DIR/Smoke/smokeGrey0.png" \
    "$KENNEY_DIR/Smoke/smokeGrey1.png" \
    "$KENNEY_DIR/Smoke/smokeGrey2.png" \
    "$KENNEY_DIR/Smoke/smokeGrey3.png" \
    "$KENNEY_DIR/Smoke/smokeGrey4.png" \
    "$KENNEY_DIR/Smoke/smokeGrey5.png"

# Explosion smoke (animated, 6 frames)
create_animated_sprite "spr_explosion" 43 43 87 87 \
    "$KENNEY_DIR/Smoke/smokeOrange0.png" \
    "$KENNEY_DIR/Smoke/smokeOrange1.png" \
    "$KENNEY_DIR/Smoke/smokeOrange2.png" \
    "$KENNEY_DIR/Smoke/smokeOrange3.png" \
    "$KENNEY_DIR/Smoke/smokeOrange4.png" \
    "$KENNEY_DIR/Smoke/smokeOrange5.png"

# =============================================================================
# Object .yy files
# =============================================================================

echo ""
echo "=== Creating Object definitions ==="

create_object() {
    local name="$1"
    local sprite="$2"
    shift 2
    # Remaining args are event entries

    local obj_dir="$PROJECT_DIR/objects/$name"
    mkdir -p "$obj_dir"

    local obj_guid=$(next_guid)

    local sprite_ref="null"
    if [ "$sprite" != "none" ]; then
        sprite_ref="{\"name\":\"$sprite\",\"path\":\"sprites/$sprite/$sprite.yy\"}"
    fi

    local events_json=""
    local first=true
    for event_spec in "$@"; do
        # event_spec format: "eventType:eventNum"
        local etype=$(echo "$event_spec" | cut -d: -f1)
        local enum=$(echo "$event_spec" | cut -d: -f2)
        local ev_guid=$(next_guid)
        if [ "$first" = true ]; then first=false; else events_json="$events_json,"; fi
        events_json="$events_json{\"\\$GMEvent\":\"\",\"%Name\":\"\",\"collisionObjectId\":null,\"eventNum\":$enum,\"eventType\":$etype,\"isDnD\":false,\"name\":\"\",\"resourceType\":\"GMEvent\",\"resourceVersion\":\"2.0\"}"
    done

    cat > "$obj_dir/$name.yy" <<EOYY
{
  "\$GMObject":"",
  "%Name":"$name",
  "eventList":[$events_json],
  "managed":true,
  "name":"$name",
  "overriddenProperties":[],
  "parent":{"name":"Objects","path":"folders/Objects.yy"},
  "parentObjectId":null,
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":1,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":1,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":$sprite_ref,
  "spriteMaskId":null,
  "visible":true
}
EOYY
    echo "  Created object: $name"
}

# Event types: 0=Create, 2=Destroy, 3=Step, 4=Collision, 7=Draw, 8=DrawGUI, 12=CleanUp
# obj_game: Create(0:0), Step(3:0), DrawGUI(8:0), CleanUp(12:0)
create_object "obj_game" "none" "0:0" "3:0" "8:0" "12:0"

# obj_tank: Create(0:0), Step(3:0), Draw(7:0)
create_object "obj_tank" "spr_tank_body_red" "0:0" "3:0" "7:0"

# obj_bullet: Create(0:0), Step(3:0), Draw(7:0)
create_object "obj_bullet" "spr_bullet" "0:0" "3:0" "7:0"

# obj_block: Create(0:0), Draw(7:0)
create_object "obj_block" "none" "0:0" "7:0"

# obj_pickable: Create(0:0), Step(3:0), Draw(7:0)
create_object "obj_pickable" "none" "0:0" "3:0" "7:0"

# obj_smoke: Create(0:0), Step(3:0), Draw(7:0)
create_object "obj_smoke" "spr_smoke" "0:0" "3:0" "7:0"

# obj_background: Create(0:0), Draw(7:0)
create_object "obj_background" "none" "0:0" "7:0"

# =============================================================================
# Script .yy files
# =============================================================================

echo ""
echo "=== Creating Script definitions ==="

for script_name in scr_constants scr_network scr_utils; do
    script_dir="$PROJECT_DIR/scripts/$script_name"
    cat > "$script_dir/$script_name.yy" <<EOYY
{
  "\$GMScript":"",
  "%Name":"$script_name",
  "isDnD":false,
  "isCompatibility":false,
  "name":"$script_name",
  "parent":{"name":"Scripts","path":"folders/Scripts.yy"},
  "resourceType":"GMScript",
  "resourceVersion":"2.0"
}
EOYY
    echo "  Created script: $script_name"
done

# =============================================================================
# Room .yy file
# =============================================================================

echo ""
echo "=== Creating Room ==="

ROOM_DIR="$PROJECT_DIR/rooms/rm_game"
mkdir -p "$ROOM_DIR"

cat > "$ROOM_DIR/rm_game.yy" <<'EOYY'
{
  "$GMRoom":"",
  "%Name":"rm_game",
  "creationCodeFile":"",
  "inheritCode":false,
  "inheritCreationOrder":false,
  "inheritLayers":false,
  "instanceCreationOrder":[
    {"name":"inst_game","path":"rooms/rm_game/rm_game.yy"},
    {"name":"inst_bg","path":"rooms/rm_game/rm_game.yy"}
  ],
  "isDnd":false,
  "layers":[
    {
      "$GMRInstanceLayer":"",
      "%Name":"Effects",
      "depth":100,
      "effectEnabled":true,
      "effectType":null,
      "gridX":32,
      "gridY":32,
      "hierarchyFrozen":false,
      "inheritLayerDepth":false,
      "inheritLayerSettings":false,
      "inheritSubLayers":true,
      "inheritVisibility":true,
      "instances":[],
      "layers":[],
      "name":"Effects",
      "properties":[],
      "resourceType":"GMRInstanceLayer",
      "resourceVersion":"2.0",
      "userdefinedDepth":false,
      "visible":true
    },
    {
      "$GMRInstanceLayer":"",
      "%Name":"Instances",
      "depth":200,
      "effectEnabled":true,
      "effectType":null,
      "gridX":32,
      "gridY":32,
      "hierarchyFrozen":false,
      "inheritLayerDepth":false,
      "inheritLayerSettings":false,
      "inheritSubLayers":true,
      "inheritVisibility":true,
      "instances":[
        {"$GMRInstance":"","%Name":"inst_game","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_game","objectId":{"name":"obj_game","path":"objects/obj_game/obj_game.yy"},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0,"y":0},
        {"$GMRInstance":"","%Name":"inst_bg","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_bg","objectId":{"name":"obj_background","path":"objects/obj_background/obj_background.yy"},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0,"y":0}
      ],
      "layers":[],
      "name":"Instances",
      "properties":[],
      "resourceType":"GMRInstanceLayer",
      "resourceVersion":"2.0",
      "userdefinedDepth":false,
      "visible":true
    },
    {
      "$GMRBackgroundLayer":"",
      "%Name":"Background",
      "animationFPS":15.0,
      "animationSpeedType":0,
      "colour":4280821032,
      "depth":300,
      "effectEnabled":true,
      "effectType":null,
      "gridX":32,
      "gridY":32,
      "hierarchyFrozen":false,
      "hspeed":0.0,
      "htiled":false,
      "inheritLayerDepth":false,
      "inheritLayerSettings":false,
      "inheritSubLayers":true,
      "inheritVisibility":true,
      "layers":[],
      "name":"Background",
      "properties":[],
      "resourceType":"GMRBackgroundLayer",
      "resourceVersion":"2.0",
      "spriteId":null,
      "stretch":false,
      "userdefinedAnimFPS":false,
      "userdefinedDepth":false,
      "visible":true,
      "vspeed":0.0,
      "vtiled":false,
      "x":0,
      "y":0
    }
  ],
  "name":"rm_game",
  "parent":{"name":"Rooms","path":"folders/Rooms.yy"},
  "parentRoom":null,
  "physicsSettings":{
    "inheritPhysicsSettings":false,
    "PhysicsWorld":false,
    "PhysicsWorldGravityX":0.0,
    "PhysicsWorldGravityY":10.0,
    "PhysicsWorldPixToMetres":0.1
  },
  "resourceType":"GMRoom",
  "resourceVersion":"2.0",
  "roomSettings":{
    "Height":1536,
    "Width":1536,
    "inheritRoomSettings":false,
    "persistent":false
  },
  "sequenceId":null,
  "views":[
    {"hborder":32,"hport":540,"hspeed":-1,"hview":704,"inherit":false,"objectId":null,"vborder":32,"visible":true,"vspeed":-1,"wport":960,"wview":704,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0},
    {"hborder":32,"hport":768,"hspeed":-1,"hview":768,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1024,"wview":1024,"xport":0,"xview":0,"yport":0,"yview":0}
  ],
  "viewSettings":{
    "clearDisplayBuffer":true,
    "clearViewBackground":false,
    "enableViews":true,
    "inheritViewSettings":false
  },
  "volumes":[
    {"$GMRoomVolume":"","%Name":"","colour":4294967295,"depth":-1.0,"enabled":true,"height":1536.0,"name":"","resourceType":"GMRoomVolume","resourceVersion":"2.0","width":1536.0,"x":0.0,"y":0.0}
  ]
}
EOYY

echo "  Created room: rm_game (1536x1536, view 704x704 → 960x540 port)"

# =============================================================================
# Main project .yyp file
# =============================================================================

echo ""
echo "=== Creating Project File ==="

# Collect all resources
RESOURCES=""
add_resource() {
    local name="$1"
    local path="$2"
    if [ -n "$RESOURCES" ]; then RESOURCES="$RESOURCES,"; fi
    RESOURCES="$RESOURCES
    {\"id\":{\"name\":\"$name\",\"path\":\"$path\"}}"
}

# Sprites
for spr in spr_tank_body_red spr_tank_body_blue spr_tank_body_green spr_tank_body_yellow \
           spr_barrel_red spr_barrel_blue spr_barrel_green spr_barrel_yellow \
           spr_bullet spr_bullet_special spr_bullet_red spr_bullet_blue spr_bullet_green spr_bullet_yellow \
           spr_sand spr_tree_small spr_tree_large spr_sandbag spr_barrel_obstacle spr_oil \
           spr_smoke spr_explosion; do
    add_resource "$spr" "sprites/$spr/$spr.yy"
done

# Objects
for obj in obj_game obj_tank obj_bullet obj_block obj_pickable obj_smoke obj_background; do
    add_resource "$obj" "objects/$obj/$obj.yy"
done

# Scripts
for scr in scr_constants scr_network scr_utils; do
    add_resource "$scr" "scripts/$scr/$scr.yy"
done

# Room
add_resource "rm_game" "rooms/rm_game/rm_game.yy"

cat > "$PROJECT_DIR/TankBattle.yyp" <<EOYY
{
  "\$GMProject":"",
  "%Name":"TankBattle",
  "AudioGroups":[
    {"\\$GMAudioGroup":"","%Name":"audiogroup_default","name":"audiogroup_default","resourceType":"GMAudioGroup","resourceVersion":"2.0","targets":-1}
  ],
  "configs":{
    "children":[],
    "name":"Default"
  },
  "defaultScriptType":1,
  "Folders":[
    {"\\$GMFolder":"","%Name":"Sprites","folderPath":"folders/Sprites.yy","name":"Sprites","resourceType":"GMFolder","resourceVersion":"2.0"},
    {"\\$GMFolder":"","%Name":"Objects","folderPath":"folders/Objects.yy","name":"Objects","resourceType":"GMFolder","resourceVersion":"2.0"},
    {"\\$GMFolder":"","%Name":"Scripts","folderPath":"folders/Scripts.yy","name":"Scripts","resourceType":"GMFolder","resourceVersion":"2.0"},
    {"\\$GMFolder":"","%Name":"Rooms","folderPath":"folders/Rooms.yy","name":"Rooms","resourceType":"GMFolder","resourceVersion":"2.0"}
  ],
  "IncludedFiles":[],
  "isEcma":false,
  "LibraryEmitters":[],
  "MetaData":{
    "IDE_Version":"2024.8.1.171"
  },
  "name":"TankBattle",
  "resources":[$RESOURCES
  ],
  "RoomOrderNodes":[
    {"roomId":{"name":"rm_game","path":"rooms/rm_game/rm_game.yy"}}
  ],
  "templateType":null,
  "TextureGroups":[
    {"\\$GMTextureGroup":"","%Name":"Default","autocrop":true,"border":2,"compressFormat":"bz2","directory":"","groupParent":null,"isScaled":true,"loadType":"default","mipsToGenerate":0,"name":"Default","resourceType":"GMTextureGroup","resourceVersion":"2.0","targets":-1}
  ]
}
EOYY

echo "  Created: TankBattle.yyp"
echo ""
echo "=== Done! ==="
echo "Open TankBattle.yyp in GameMaker to start the project."
echo ""
echo "NOTE: If the project doesn't open perfectly, create a new project in"
echo "GameMaker IDE and import the sprites/objects/scripts manually."
echo "The GML code files are in objects/ and scripts/ directories."
