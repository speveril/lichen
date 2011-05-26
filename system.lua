package.path = package.path .. ";src/?.lua;src/lib/?.lua;src/lib/?/init.lua" -- set up our import paths in /src
require "vx" -- the vx library
require "lichen" -- the core editor scripts

function autoexec()
    -- misc. set up
    vx.SetAppName('Lichen Map Editor')
    vx.SetResolution(320, 240)
    
    -- do loading
    lichen.setup()
    
    -- start the editor proper
    lichen.start()
end
