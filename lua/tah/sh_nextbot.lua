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
        action = "walk_towards_last_enemy_position",
        check = function(nextbot)
            return nextbot:HasEnemy() and nextbot:IsObjectVisible(nextbot:GetEnemy())
        end,
    },
    ["enemy_visible_recently"] = {
        action = "walk_towards_last_enemy_position",
        check = function(nextbot)
            return nextbot:HasEnemy() and (nextbot:IsObjectVisible(nextbot:GetEnemy()) or nextbot:GetObjectTimeSinceLastSeen(nextbot:GetEnemy()) <= 3)
        end,
    },
    ["enemy_lost"] = {
        check = function(nextbot)
            return nextbot:HasEnemy() and not nextbot:IsObjectVisible(nextbot:GetEnemy()) and nextbot:GetObjectTimeSinceLastSeen(nextbot:GetEnemy()) > 3
        end,
    },
    ["enemy_acquired"] = {
        check = function(nextbot)
            return nextbot:HasEnemy()
        end,
    },
    ["no_enemy"] = {
        check = function(nextbot)
            return not nextbot:HasEnemy()
        end,
    },
    ["enemy_in_melee_range"] = {
        action = "run_towards_enemy",
        check = function(nextbot)
            return nextbot:HasEnemy()
                    and nextbot:GetPos():DistToSqr(nextbot:GetEnemy():GetPos()) <= 72 * 72
        end,
    },
    ["weapon_not_owned"] = {
        action = nil,
        check = function(nextbot)
            return not nextbot:HasWeapon()
        end
    },
    ["weapon_owned"] = {
        action = "pickup_weapon",
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
            return not IsValid(wep) or wep:Clip1() >= wep:GetValue("AmmoPerShot")
        end
    },
    ["weapon_needs_reload"] = {
        action = nil,
        check = function(nextbot)
            local wep = nextbot:GetWeapon()
            return not IsValid(wep) or wep:Clip1() < wep:GetValue("ClipSize")
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
        actions = {"reload_safe"},
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
            if IsValid(nextbot:GetEnemy()) then return false end
            local navpos = navmesh.GetNearestNavArea(nextbot:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 100 + nextbot:GetForward() * 100)
            if not navpos then
                navpos = navmesh.GetNearestNavArea(nextbot:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 100)
                if not navpos then return false end
            end
            nextbot:MoveToPos(navpos:GetRandomPoint())
            coroutine.wait(math.Rand(1, 3))
            return true
        end,
    },
    ["walk_towards_last_enemy_position"] = {
        preconds = {"enemy_lost"},
        cost = 0.5,
        state = TAH_NB_GOTO,
        action = function(nextbot)
            local navpos = navmesh.GetNearestNavArea(nextbot:GetObjectLastPosition(nextbot:GetEnemy()))
            if not navpos then
                if not navpos then return false end
            end
            nextbot:MoveToPos(navpos:GetRandomPoint())
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
        preconds = {"enemy_visible"},
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
        cost = 2,
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

    ["reload_safe"] = {
        cost = function(nextbot)
            return 1
        end,
        preconds = {"weapon_owned", "weapon_needs_reload", "no_enemy"},
        state = TAH_NB_ACT,
        action = function(nextbot)
            nextbot:WeaponReload()
            return true
        end,
    },
    ["reload"] = {
        cost = function(nextbot)
            if IsValid(nextbot:GetWeapon()) then
                return Lerp(nextbot:GetWeapon():Clip1() / nextbot:GetWeapon():GetMaxClip1(), 0.1, 5)
            end
            return 10
        end,
        preconds = {"weapon_owned", "weapon_needs_reload"},
        state = TAH_NB_ACT,
        action = function(nextbot)
            nextbot:WeaponReload()
            return true
        end,
    },

    ["attack_ranged"] = {
        cost = 0.2,
        preconds = {"weapon_owned", "weapon_has_ammo", "enemy_visible_recently"},
        state = TAH_NB_ACT,
        action = function(nextbot)
            local ret = nextbot:WeaponAttack()
            if ret == false then
                return false
            elseif not nextbot:HasEnemy() or nextbot:GetEnemy():Health() <= 0 then
                return true
            else
                return nil
            end
        end,
    },
}