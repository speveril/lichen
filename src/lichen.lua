----------------------------------------------------------------------------------------------------

require "Mode"
require "Mode-Draw"
require "Mode-VSP"

require "Dialog"
require "Dialog-File"

require "UI"
require "tile_library"
require "console"

----------------------------------------------------------------------------------------------------

lichen = {
    current_map = "",
    current_vsp = "",
    load_type = nil,
    
    TYPE_NEW = 1,
    TYPE_LOAD = 2
}

-- this stuff should migrate into lichen
assets = {}
options = {}

function lichen.setup()
    assets.cursors = {
        default = vx.Image("res/ui/default-cursor.png"),
        pencil = vx.Image("res/ui/tool-pencil.png"),
        hand = vx.Image("res/ui/tool-hand.png")
    }
    assets.fonts = {
        system = vx.Font(0),
        default = vx.Font("res/font/console.png"),
        tiny = vx.Font("res/font/5x5.png"),
        tinydark = vx.Font("res/font/5x5_dark.png")
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

function lichen.start()
    v3.HookMapLoad(lichen.hooks.mapLoad)
    v3.HookRetrace(lichen.hooks.render)
    
    Mode.list.Draw:start()
    
    --lichen.newMap(25, 25)
    --lichen.loadMap("tmp/oworld.map")
    lichen.newMap(25, 25)
end

----------------------------------------------------------------------------------------------------

function lichen.newMap(width, height)
    lichen.load_type = lichen.TYPE_NEW
    lichen.newmap = { w = width, h = height }
    v3.Map("res/map/empty.map")
end

----------------------------------------------------------------------------------------------------

function lichen.saveMap(filename, vspname)
    if not filename then filename = lichen.current_map end
    if not vspname then vspname = lichen.current_vsp end
    
    local pathchunks = filename:Explode("[\\/]")
    pathchunks[#pathchunks] = vspname
    local vsppath = table.concat(pathchunks, "/")
    
    local f = vx.File(filename, vx.FileMode.Write)
    v3.FileWriteMap(f.file_handle)
    
    f = vx.File(vsppath, vx.FileMode.Write)
    v3.FileWriteVSP(f.file_handle)
end

----------------------------------------------------------------------------------------------------

function lichen.loadMap(filename)
    lichen.load_type = lichen.TYPE_LOAD
    v3.Map(filename)
end

----------------------------------------------------------------------------------------------------

lichen.hooks = {
    mapLoad = function()
        if lichen.load_type == lichen.TYPE_NEW then
            v3.ResizeLayer(0, lichen.newmap.w, lichen.newmap.h, 0, 0)
            v3.ResizeLayer(1, lichen.newmap.w, lichen.newmap.h, 0, 0)
        end
        
        print("Map loaded -- " .. vx.map.filename)
        print("VSP loaded -- " .. vx.map.vspname)
        
        lichen.current_map = vx.map.filename
        lichen.current_vsp = vx.map.vspname
        
        vx.camera:TargetNothing()
        
        vx.map.tilecount = math.floor(vx.map.tileset.height / 16) -- floor() shouldn't be necessary, but just in case
        vx.map.renderlist = v3.curmap.rstring:Explode(",", true)
        table.insert(vx.map.renderlist, 'O')
        table.insert(vx.map.renderlist, 'Z')
    end,
    
    render = function()
        if Mode.current and Mode.current.render then Mode.current:render() end
        UI.render()
    end
}

----------------------------------------------------------------------------------------------------

function mouseIsIn(x1, y1, x2, y2)
    if vx.mouse.x >= x1 and vx.mouse.x <= x2 and vx.mouse.y >= y1 and vx.mouse.y <= y2 then
        return true
    else
        return false
    end
end

