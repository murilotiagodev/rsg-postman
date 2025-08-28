local RSGCore = exports['rsg-core']:GetCoreObject()

-- ========= ox_lib notifications (fallback minimal în chat) =========
local function Notify(payload)
    -- payload: { title?, description, type?, duration?, position? }
    local t = payload or {}
    t.title = t.title or 'Postman'
    t.type = t.type or 'inform'        -- success | inform | warning | error
    t.duration = t.duration or 4000
    t.position = t.position or 'top-right'

    if lib and lib.notify then
        return lib.notify(t)
    else
        local txt = (t.title and (t.title .. ': ') or '') .. (t.description or '')
        TriggerEvent('chat:addMessage', { args = { '^3Postman', txt } })
    end
end

-- Server -> client notifications go through here
RegisterNetEvent('rsg-postman:notify', function(t)
    Notify(t)
end)
-- ==================================================================

-- ========== Waypoint helpers (RedM-safe) ==========
local function SetWaypointSafe(coords)
    if type(SetNewWaypoint) == 'function' then
        SetNewWaypoint(coords.x + 0.0, coords.y + 0.0)
        return true
    end
    if type(StartGpsMultiRoute) == 'function'
    and type(AddPointToGpsMultiRoute) == 'function'
    and type(SetGpsMultiRouteRender) == 'function'
    and type(ClearGpsMultiRoute) == 'function' then
        ClearGpsMultiRoute()
        StartGpsMultiRoute(6, true, true)
        AddPointToGpsMultiRoute(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
        SetGpsMultiRouteRender(true)
        return true
    end
    return false
end

local function ClearWaypointSafe()
    if type(IsWaypointActive) == 'function' and IsWaypointActive() and type(SetWaypointOff) == 'function' then
        SetWaypointOff()
    end
    if type(ClearGpsMultiRoute) == 'function' then
        ClearGpsMultiRoute()
    end
end
-- ================================================

-- ========= Handover animation =========
local function PlayHandoverAnim()
    local ped = PlayerPedId()
    local scene = CreateAnimScene('script@beat@town@townRobbery@handover_money', 64, 0, false, true)
    if not DoesAnimSceneExist(scene) then return end

    local p = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    local origin = vector3(p.x + fwd.x * 1.0, p.y + fwd.y * 1.0, p.z)
    local rot = GetEntityRotation(ped, 2)
    SetAnimSceneOrigin(scene, origin.x, origin.y, origin.z, rot.x, rot.y, rot.z - 175.0, 2)
    SetAnimSceneEntity(scene, "pedPlayer", ped, 0)

    local objectModel = `s_herbalpouch01x`
    local prop = 0
    RequestModel(objectModel)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(objectModel) and GetGameTimer() < timeout do Wait(0) end
    if HasModelLoaded(objectModel) then
        prop = CreateObject(objectModel, origin.x, origin.y, origin.z, true, true, false, false, true)
        SetEntityVisible(prop, false)
        SetAnimSceneEntity(scene, "objPouch", prop, 0)
    end

    LoadAnimScene(scene)
    Wait(100)
    StartAnimScene(scene)
    Wait(250)
    if prop ~= 0 then SetEntityVisible(prop, true) end

    Wait(2800)

    if prop ~= 0 then
        SetEntityAsMissionEntity(prop, true, true)
        DeleteObject(prop)
    end
    if DoesAnimSceneExist(scene) then
        Citizen.InvokeNative(0x84EEDB2C6E650000, scene) -- _DELETE_ANIM_SCENE
    end
end
-- =====================================

-- ========= State =========
local delivering, deliveryBlip, currentDelivery, packagesToDeliver =
      false,       nil,        nil,               0
-- ========================

-- ========= Helpers =========
local function DrawTxt3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFontForCurrentCommand(6)
        SetTextCentre(true)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), _x, _y)
    end
end

local function clearNav()
    if deliveryBlip then RemoveBlip(deliveryBlip) deliveryBlip = nil end
    ClearWaypointSafe()
end
-- ==========================

-- ========= Spawn Postman NPC + ox_target + blip =========
CreateThread(function()
    local npc = Config.PostmanNPC
    local model = joaat(npc.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end

    -- z - 1.0 + fade-in + place on ground
    local ped = CreatePed(model, npc.coords.x, npc.coords.y, npc.coords.z - 1.0, npc.coords.w, false, false, 0, 0)
    SetEntityAlpha(ped, 0, false)
    SetRandomOutfitVariation(ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeTargetted(ped, false)
    PlaceEntityOnGroundProperly(ped, true)

    for a = 0, 255, 51 do
        Wait(50)
        SetEntityAlpha(ped, a, false)
    end

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'postman_open_menu',
            icon = 'far fa-envelope',
            label = 'Open Post Office',
            distance = 3.0,
            onSelect = function()
                TriggerEvent('rsg-postman:openMenu')
            end
        }
    })

    local npcBlip = BlipAddForCoords(1664425300, npc.coords.x, npc.coords.y, npc.coords.z)
    SetBlipSprite(npcBlip, `blip_post_office`)
    SetBlipScale(npcBlip, 0.8)
    SetBlipName(npcBlip, 'Postman')
    BlipAddModifier(npcBlip, joaat('BLIP_MODIFIER_MP_COLOR_6'))
end)
-- ========================================================

-- ========= Meniu ox_lib =========
RegisterNetEvent('rsg-postman:openMenu', function()
    if not lib or not lib.registerContext then
        Notify({ description = '^1ox_lib not loaded. Put @ox_lib/init.lua before client.lua and ensure ox_lib is started first.', type = 'error' })
        return
    end

    local options = {}
    local max = Config.MaxPackages or 50
    local step = 5
    for i = step, max, step do
        options[#options+1] = {
            title = ("Take %d packages"):format(i),
            description = ("Pick up %d packages for delivery"):format(i),
            icon = 'fa-solid fa-box',
            event = 'rsg-postman:client:startJob',
            args = { amount = i }
        }
    end

    options[#options+1] = {
        title = "Stop Deliveries",
        description = "Return all remaining packages and cancel deliveries",
        icon = "fa-solid fa-ban",
        event = "rsg-postman:client:stopJob"
    }

    lib.registerContext({
        id = 'postman_menu',
        title = 'Post Office',
        position = 'top-right',
        options = options
    })
    lib.showContext('postman_menu')
end)

-- Start job
RegisterNetEvent('rsg-postman:client:startJob', function(data)
    local amount
    if type(data) == 'table' then
        amount = data.amount or data.value or data[1]
    else
        amount = data
    end
    amount = tonumber(amount) or 5
    TriggerServerEvent('rsg-postman:startJob', amount)
end)

-- Stop job (progress bar + animation + server)
RegisterNetEvent('rsg-postman:client:stopJob', function()
    if lib and lib.progressBar then
        local ok = lib.progressBar({
            duration = 3500,
            label = 'Returning remaining packages...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true }
        })
        if not ok then
            Notify({ description = "Cancelled.", type = "error" })
            return
        end
    end

    -- Animation before returning items
    PlayHandoverAnim()

    TriggerServerEvent('rsg-postman:stopJob')

    delivering = false
    currentDelivery = nil
    packagesToDeliver = 0
    clearNav()
    Notify({ description = "You have stopped all deliveries.", type = "error" })
end)

-- Receive delivery (blip + waypoint)
RegisterNetEvent('rsg-postman:setDelivery', function(location, amount)
    delivering = true
    currentDelivery = location
    packagesToDeliver = amount

    if deliveryBlip then RemoveBlip(deliveryBlip) end
    deliveryBlip = BlipAddForCoords(1664425300, location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(deliveryBlip, `blip_post_office`)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipName(deliveryBlip, 'Package Delivery')
    BlipAddModifier(deliveryBlip, joaat('BLIP_MODIFIER_MP_COLOR_6'))

    ClearWaypointSafe()
    SetWaypointSafe(location.coords)

    Notify({ description = ('Deliver %d packages to %s'):format(amount, location.name), type = 'success' })
end)

-- Delivery loop (E) + progress bar + animation
CreateThread(function()
    while true do
        Wait(0)
        if delivering and currentDelivery then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            if #(coords - currentDelivery.coords) < 3.0 then
                DrawTxt3D(currentDelivery.coords.x, currentDelivery.coords.y, currentDelivery.coords.z, "[E] Deliver packages")
                if IsControlJustPressed(0, 0xCEFD9220) then
                    local ok = true
                    if lib and lib.progressBar then
                        ok = lib.progressBar({
                            duration = 3000,
                            label = 'Handing over packages...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, car = true, mouse = false, combat = true }
                        })
                    end
                    if not ok then
                        Notify({ description = "Delivery cancelled.", type = "error" })
                    else
                        -- Animation before confirming the delivery
                        PlayHandoverAnim()

                        TriggerServerEvent('rsg-postman:completeDelivery', packagesToDeliver)
                        delivering = false
                        currentDelivery = nil
                        packagesToDeliver = 0
                        clearNav()
                    end
                end
            end
        end
    end
end)

-- Cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    clearNav()
end)
