-- invalid state?
TAH_NB_NONE = 0

-- Play animation while moving somewher
TAH_NB_GOTO = 1

-- Play animation without moving somewhere
TAH_NB_ACT = 2

-- Driven by external entity (?)
TAH_NB_USE = 3

TAH.NB_PreConds = {
    ["enemy_visible"] = {
        check = function(nextbot)
            return IsValid(nextbot:GetEnemy()) and nextbot:IsAbleToSee(nextbot:GetEnemy(), false)
        end,
    },
    ["enemy_acquired"] = {
        check = function(nextbot)
            return IsValid(nextbot:GetEnemy())
        end,
    },
    ["enemy_in_melee_range"] = {
        action = "run_towards_enemy",
        check = function(nextbot)
            return IsValid(nextbot:GetEnemy())
                    and nextbot:GetPos():DistToSqr(nextbot:GetEnemy():GetPos()) <= 72 * 72
        end,
    },
    ["weapon_not_owned"] = {
        action = nil, -- TODO maybe try pickup weapon nearby
        check = function(nextbot)
            return not nextbot:HasWeapon()
        end
    },
    ["weapon_owned"] = {
        action = nil, -- TODO maybe try pickup weapon nearby
        check = function(nextbot)
            return nextbot:HasWeapon()
        end
    },
    ["weapon_nearby"] = {
        action = "walk_towards_weapon",
        check = function(nextbot)
            local wep = nextbot:GetFoundWeapon()
            return IsValid(wep) and wep:GetPos():DistToSqr(nextbot:GetPos()) <= 64 * 64
        end
    },
    ["weapon_found"] = {
        action = nil,
        check = function(nextbot)
            local wep = nextbot:GetFoundWeapon()
            return IsValid(wep) and not IsValid(wep:GetOwner())
        end
    },
    ["weapon_has_ammo"] = {
        action = "reload",
        check = function(nextbot)
            local wep = nextbot:GetWeapon()
            return IsValid(wep) and wep:Clip1() >= wep:GetValue("AmmoPerShot")
        end
    },
    ["weapon_needs_reload"] = {
        action = nil,
        check = function(nextbot)
            local wep = nextbot:GetWeapon()
            return IsValid(wep) and wep:Clip1() < wep:GetValue("ClipSize")
        end
    },
}

TAH.NB_Goals = {
    ["patrol"] = {
        priority = 1,
        retry = 0,
        actions = {"walk_random"}
    },
    ["keep_loaded"] = {
        priority = 1.5,
        retry = 0,
        actions = {"pickup_weapon", "reload"},
    },
    ["kill_enemy"] = {
        priority = 2,
        retry = 0,
        actions = {"attack_melee", "attack_ranged"},
    }
}

TAH.NB_Actions = {
    ["walk_random"] = {
        preconds = {},
        cost = 0.5,
        state = TAH_NB_GOTO,
        action = function(nextbot)
            nextbot:FindEnemy()
            if IsValid(nextbot:GetEnemy()) then return false end
            nextbot:MoveToPos(nextbot:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 200)
            if not nextbot:HasWeapon() then
                nextbot:FindWeapon()
            end
            return true
        end,
    },
    ["walk_towards_weapon"] = {
        preconds = {"weapon_not_owned", "weapon_found"},
        cost = 1,
        state = TAH_NB_GOTO,
        action = function(nextbot)
            local status = nextbot:MoveToPos(nextbot:GetFoundWeapon():GetPos())
            return status == "ok"
        end,
    },
    ["pickup_weapon"] = {
        preconds = {"weapon_not_owned", "weapon_nearby"},
        cost = 0.1,
        state = TAH_NB_GOTO,
        action = function(nextbot)
            nextbot:PickupWeapon(nextbot:GetFoundWeapon())
        end,
    },
    ["run_towards_enemy"] = {
        preconds = {"enemy_acquired"},
        state = TAH_NB_GOTO,
        cost = function(nextbot)
            if IsValid(nextbot:GetEnemy()) then
                return Lerp(nextbot:GetPos():DistToSqr(nextbot:GetEnemy():GetPos()) / 1000000, 0.1, 10)
            else
                return 10
            end
        end,
        action = function(nextbot)
            nextbot:ChaseEnemy({tolerance = 48, timeout = 5, stopinrange = true})
            return true
        end,
    },
    ["attack_melee"] = {
        cost = 0.5,
        preconds = {"enemy_visible", "enemy_in_melee_range"},
        state = TAH_NB_GOTO,
        action = function(nextbot)
            nextbot:ChaseEnemy({lookahead = 0, tolerance = 0, timeout = 0.5})
            nextbot:MeleeAttack()
            if not IsValid(nextbot:GetEnemy()) or nextbot:GetEnemy():Health() <= 0 then
                return true
            elseif nextbot:GetPos():Distance(nextbot:GetEnemy():GetPos()) >= 256 then
                return false
            else
                return nil
            end
        end,
    },

    ["reload"] = {
        cost = 2,
        preconds = {"weapon_owned", "weapon_needs_reload"},
        state = TAH_NB_ACT,
        action = function(nextbot)
            nextbot:WeaponReload()
            return true
        end,
    },

    ["attack_ranged"] = {
        cost = 0.5,
        preconds = {"weapon_has_ammo", "enemy_visible"},
        state = TAH_NB_ACT,
        action = function(nextbot)
            local ret = nextbot:WeaponAttack()
            if ret == false then
                return false
            elseif not IsValid(nextbot:GetEnemy()) or nextbot:GetEnemy():Health() <= 0 then
                return true
            else
                return nil
            end
        end,
    },
}