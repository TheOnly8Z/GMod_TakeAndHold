TOOL.Category = "Take and Hold"
TOOL.Name = "#tool.tah_barrier.name"

TOOL.Information = {
	{name = "left", stage = 0},
	{name = "left.1", stage = 1},
	{name = "right", stage = 0},
}

if CLIENT then
	language.Add("tool.tah_barrier.name", "Barrier Tool")
	language.Add("tool.tah_barrier.desc", "Create or remove spawn areas for the map.")
	language.Add("tool.tah_barrier.left", "Start Point")
	language.Add("tool.tah_barrier.left.1", "End Point")
	language.Add("tool.tah_barrier.right", "Cancel")
end

local grid_size = 4
local function vector_grid(vec)
	vec.x = math.Round(vec.x)
	vec.x = vec.x + (vec.x % grid_size)
	vec.y = math.Round(vec.y)
	vec.y = vec.y + (vec.y % grid_size)
	-- do nothing to z (usually we want it aligned to the floor)
	return vec
end

local function resolve_barrier(vec1, vec2)

	if math.abs(vec1.x - vec2.x) <= 16 then
		vec2.x = vec1.x
	elseif math.abs(vec1.y - vec2.y) <= 16 then
		vec2.y = vec1.y
	end

	local center = vec1 + (vec2 - vec1) / 2
	local angle = (vec2 - vec1):GetNormalized():Cross(Vector(0, 0, 1)):Angle() --+ Angle(0, 90, 0)
	angle:RotateAroundAxis(Vector(0, 0, 1), 90)
	local width = math.sqrt((vec2.x - vec1.x) ^ 2 + (vec2.y - vec1.y) ^ 2) / 2
	local height = math.abs(vec2.z - vec1.z) / 2

	return center, angle, Vector(-width, -1, -height), Vector(width, 1, height)
end

function TOOL:LeftClick(tr)
	if not IsFirstTimePredicted() then return end

	if self:GetStage() == 0 then
		self:SetStage(1)
		self.Weapon:SetNWVector("StepInfo", tr.HitPos)
	else
		if SERVER then
			local pos2 = tr.HitPos
			local center, ang, mins, maxs = resolve_barrier(self.Weapon:GetNWFloat("StepInfo"), pos2)

			local barrier = ents.Create("tah_barrier")
			barrier:SetMinS(mins)
			barrier:SetMaxS(maxs)
			barrier:SetPos(center)
			barrier:SetAngles(ang)
			barrier:Spawn()
		end
		self:SetStage(0)
	end
	return true
end

function TOOL:RightClick(tr)
	if self:GetStage() == 0 then
		return false
	else
		self:SetStage(0)
		return true
	end
end

function TOOL:Reload(tr)
	if not IsFirstTimePredicted() then return end

	return false
end

function TOOL:Think()
end

if CLIENT then
	surface.CreateFont("GModToolScreen2", {
		font = "Helvetica",
		size = 40,
		weight = 900
	})

	surface.CreateFont("GModToolScreen3", {
		font = "Helvetica",
		size = 30,
		weight = 900
	})


	local mat = Material("models/debug/debugwhite")
	hook.Add("PostDrawOpaqueRenderables", "tah_barrier", function()
		local w = LocalPlayer():GetTool()
		if not w then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) then return end

		if w.Mode == "tah_barrier" and w:GetStage() == 1 then
			local t = LocalPlayer():GetEyeTrace()
			render.SetMaterial(mat)

			local center, ang, mins, maxs = resolve_barrier(wep:GetNWFloat("StepInfo"), t.HitPos)

			render.DrawLine(wep:GetNWFloat("StepInfo"), t.HitPos, color_white, true)
			render.DrawWireframeSphere(center, 4, 4, 4, color_white)
			render.DrawWireframeBox(center, ang, mins, maxs, color_white, true)
		end
	end)
end