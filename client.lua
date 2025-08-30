local RSGCore = exports['rsg-core']:GetCoreObject()

-- ========= ox_lib notificações (fallback no chat) =========
local function Notify(payload)
    -- payload: { title?, description, type?, duration?, position? }
    local t = payload or {}
    t.title = t.title or 'Carteiro'
    t.type = t.type or 'inform'        -- success | inform | warning | error
    t.duration = t.duration or 4000
    t.position = t.position or 'top-right'

    if lib and lib.notify then
        return lib.notify(t)
    else
        local txt = (t.title and (t.title .. ': ') or '') .. (t.description or '')
        TriggerEvent('chat:addMessage', { args = { '^3Carteiro', txt } })
    end
end

-- Server -> client notifications
RegisterNetEvent('rsg-postman:notify', function(t)
    Notify(t)
end)
-- ==================================================================

-- ========= Helpers de Waypoint =========
-- ... (sem textos visíveis, deixei igual)
-- ================================================

-- ========= Animação de Entrega =========
-- ... (sem textos visíveis, deixei igual)
-- =====================================

-- ========= Estado =========
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

-- ========= NPC Carteiro + ox_target + blip =========
CreateThread(function()
    local npc = Config.PostmanNPC
    local model = joaat(npc.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end

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
            label = 'Abrir Correios',
            distance = 3.0,
            onSelect = function()
                TriggerEvent('rsg-postman:openMenu')
            end
        }
    })

    local npcBlip = BlipAddForCoords(1664425300, npc.coords.x, npc.coords.y, npc.coords.z)
    SetBlipSprite(npcBlip, `blip_post_office`)
    SetBlipScale(npcBlip, 0.8)
    SetBlipName(npcBlip, 'Carteiro')
    BlipAddModifier(npcBlip, joaat('BLIP_MODIFIER_MP_COLOR_6'))
end)
-- ========================================================

-- ========= Menu ox_lib =========
RegisterNetEvent('rsg-postman:openMenu', function()
    if not lib or not lib.registerContext then
        Notify({ description = '^1ox_lib não carregado. Coloque @ox_lib/init.lua antes de client.lua e certifique-se que ox_lib inicia primeiro.', type = 'error' })
        return
    end

    local options = {}
    local max = Config.MaxPackages or 50
    local step = 5
    for i = step, max, step do
        options[#options+1] = {
            title = ("Pegar %d pacotes"):format(i),
            description = ("Coletar %d pacotes para entrega"):format(i),
            icon = 'fa-solid fa-box',
            event = 'rsg-postman:client:startJob',
            args = { amount = i }
        }
    end

    options[#options+1] = {
        title = "Encerrar Entregas",
        description = "Devolver todos os pacotes restantes e cancelar entregas",
        icon = "fa-solid fa-ban",
        event = "rsg-postman:client:stopJob"
    }

    lib.registerContext({
        id = 'postman_menu',
        title = 'Correios',
        position = 'top-right',
        options = options
    })
    lib.showContext('postman_menu')
end)

-- Iniciar trabalho
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

-- Parar trabalho
RegisterNetEvent('rsg-postman:client:stopJob', function()
    if lib and lib.progressBar then
        local ok = lib.progressBar({
            duration = 3500,
            label = 'Devolvendo pacotes restantes...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true }
        })
        if not ok then
            Notify({ description = "Cancelado.", type = "error" })
            return
        end
    end

    PlayHandoverAnim()
    TriggerServerEvent('rsg-postman:stopJob')

    delivering = false
    currentDelivery = nil
    packagesToDeliver = 0
    clearNav()
    Notify({ description = "Você encerrou todas as entregas.", type = "error" })
end)

-- Receber entrega
RegisterNetEvent('rsg-postman:setDelivery', function(location, amount)
    delivering = true
    currentDelivery = location
    packagesToDeliver = amount

    if deliveryBlip then RemoveBlip(deliveryBlip) end
    deliveryBlip = BlipAddForCoords(1664425300, location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(deliveryBlip, `blip_post_office`)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipName(deliveryBlip, 'Entrega de Pacotes')
    BlipAddModifier(deliveryBlip, joaat('BLIP_MODIFIER_MP_COLOR_6'))

    ClearWaypointSafe()
    SetWaypointSafe(location.coords)

    Notify({ description = ('Entregue %d pacotes em %s'):format(amount, location.name), type = 'success' })
end)

-- Loop de entrega (E)
CreateThread(function()
    while true do
        Wait(0)
        if delivering and currentDelivery then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            if #(coords - currentDelivery.coords) < 3.0 then
                DrawTxt3D(currentDelivery.coords.x, currentDelivery.coords.y, currentDelivery.coords.z, "[E] Entregar pacotes")
                if IsControlJustPressed(0, 0xCEFD9220) then
                    local ok = true
                    if lib and lib.progressBar then
                        ok = lib.progressBar({
                            duration = 3000,
                            label = 'Entregando pacotes...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, car = true, mouse = false, combat = true }
                        })
                    end
                    if not ok then
                        Notify({ description = "Entrega cancelada.", type = "error" })
                    else
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
