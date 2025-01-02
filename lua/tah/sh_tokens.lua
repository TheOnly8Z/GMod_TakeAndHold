function TAH:GetTokens(ply)
    return ply:GetNW2Int("TAH_Tokens", 0)
end

function TAH:SetTokens(ply, amt)
    ply:SetNW2Int("TAH_Tokens", amt)
end