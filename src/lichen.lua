----------------------------------------------------------------------------------------------------

require "Mode"
require "Mode-Draw"
require "Mode-VSP"

require "UI"

----------------------------------------------------------------------------------------------------

assets = {}
options = {}

function setup()
    assets.cursors = {
        default = vx.Image("res/ui/default-cursor.png"),
        pencil = vx.Image("res/ui/tool-pencil.png"),
        hand = vx.Image("res/ui/tool-hand.png")
    }
    assets.fonts = {
        system = vx.Font(0),
        default = vx.Font("res/font/console.png"),
        tiny = vx.Font("res/font/5x5.png")
    }
    assets.fonts.default:EnableVariableWidth()
    assets.icons = {
        options = vx.Image("res/ui/icon-options.png")
    }
    
    options = {
        grid = true,
        gridsize = 16,
        tilehilite = true
    }
    
    UI.setup()
    Mode.build_all()
end

----------------------------------------------------------------------------------------------------

function start()
    v3.HookMapLoad(lichenHook_mapLoad)
    v3.HookRetrace(lichenHook_render)
    
    Mode.list.Draw:start()
    
    v3.Map("tmp/oworld.map")
end

----------------------------------------------------------------------------------------------------

function lichenHook_mapLoad()
    print("Map loaded -- " .. vx.map.filename)
    vx.camera:TargetNothing()
    
    vx.map.tilecount = math.floor(vx.map.tileset.height / 16) -- floor() shouldn't be necessary, but just in case
    vx.map.renderlist = v3.curmap.rstring:Explode(",", true)
    table.insert(vx.map.renderlist, 'O')
    table.insert(vx.map.renderlist, 'Z')
end

function lichenHook_render()
    if Mode.current and Mode.current.render then Mode.current:render() end
    UI.render()
end

