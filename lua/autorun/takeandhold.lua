AddCSLuaFile()

TAH = {}

TAH.Directions = {
    Vector(1, 0, 0),
    Vector(0, 1, 0),
    Vector(-1, 0, 0),
    Vector(-1, 0, 0),
    Vector(1, 1, 0),
    Vector(1, -1, 0),
    Vector(-1, 1, 0),
    Vector(-1, -1, 0),
}

for _, v in pairs(file.Find("tah/*", "LUA")) do
    if string.Left(v, 3) == "cl_" then
        AddCSLuaFile("tah/" .. v)
        if CLIENT then
            include("tah/" .. v)
        end
    elseif string.Left(v, 3) == "sv_" and (SERVER or game.SinglePlayer()) then
        include("tah/" .. v)
    elseif string.Left(v, 3) == "sh_" then
        include("tah/" .. v)
        AddCSLuaFile("tah/" .. v)
    end
end

for _, v in pairs(file.Find("tah/vgui/*", "LUA")) do
    AddCSLuaFile("tah/vgui/" .. v)
    if CLIENT then
        include("tah/vgui/" .. v)
    end
end