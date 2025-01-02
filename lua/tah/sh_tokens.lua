function TAH:GetTokens(ply)
    return ply:GetNW2Int("TAH_Tokens", 0)
end

if SERVER then
    util.AddNetworkString("tah_token")
    function TAH:SetTokens(ply, amt)
        ply:SetNW2Int("TAH_Tokens", amt)
    end

    function TAH:AddTokens(ply, amt)
        if amt == 0 then return end
        net.Start("tah_token")
            net.WriteInt(amt, 16)
        net.Send(ply)
        ply:SetNW2Int("TAH_Tokens", ply:GetNW2Int("TAH_Tokens", 0) + amt)
    end
elseif CLIENT then
    net.Receive("tah_token", function()
        local amt = net.ReadInt(16)
        if amt > 0 then
            notification.AddLegacy("You received " .. amt .. " tokens.", NOTIFY_GENERIC, 5)
        else
            notification.AddLegacy("You spent " .. amt .. " tokens.", NOTIFY_GENERIC, 5)
        end
    end)
end