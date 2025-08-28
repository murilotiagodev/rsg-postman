local RSGCore = exports['rsg-core']:GetCoreObject()

-- ===== Helpers (RSG inventory only) =====
local function GiveItem(Player, item, amount, metadata)
    metadata = metadata or {}
    return Player.Functions.AddItem(item, amount, false, metadata) == true
end

local function RemoveItem(Player, item, amount)
    return Player.Functions.RemoveItem(item, amount) == true
end

local function Notify(src, description, ntype, duration)
    TriggerClientEvent('rsg-postman:notify', src, {
        title = 'Postman',
        description = description,
        type = ntype or 'inform',
        duration = duration or 4000
    })
end
-- =======================================

-- ===== START JOB =====
RegisterNetEvent('rsg-postman:startJob', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    amount = tonumber(amount) or 1
    local max = Config.MaxPackages or 50
    if amount > max then amount = max end
    if amount < 1 then amount = 1 end

    local itemName = Config.PackageItem or 'package'

    -- verifică itemul în RSGCore.Shared.Items (pentru rsg-inventory)
    if not (RSGCore.Shared and RSGCore.Shared.Items and RSGCore.Shared.Items[itemName]) then
        Notify(src, ("Item '%s' is not defined in RSGCore.Shared.Items."):format(itemName), "error")
        print(('[rsg-postman] ERROR: item %s missing in RSGCore.Shared.Items'):format(itemName))
        return
    end

    if not GiveItem(Player, itemName, amount) then
        Notify(src, "No inventory space or item undefined.", "error")
        print(('[rsg-postman] AddItem FAILED for %d (%dx %s)'):format(src, amount, itemName))
        return
    end

    -- anim ItemBox (rsg-inventory)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], 'add')

    -- setează câte pachete mai are
    Player.Functions.SetMetaData("postman_packages", amount)

    -- prima destinație
    local locs = Config.DeliveryLocations or {}
    if #locs == 0 then
        Notify(src, "No delivery locations configured.", "error")
        return
    end

    local location = locs[math.random(1, #locs)]
    local minPer = Config.MinPackagesPerDelivery or 1
    local maxPer = Config.MaxPackagesPerDelivery or 5
    if maxPer < minPer then maxPer = minPer end
    local deliverNow = math.random(minPer, maxPer)
    if deliverNow > amount then deliverNow = amount end

    TriggerClientEvent('rsg-postman:setDelivery', src, location, deliverNow)
    Notify(src, ("You received %d %s. First delivery assigned."):format(amount, itemName), "success")
end)

-- ===== COMPLETE DELIVERY =====
RegisterNetEvent('rsg-postman:completeDelivery', function(delivered)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    delivered = tonumber(delivered) or 1
    if delivered < 1 then return end

    local itemName = Config.PackageItem or 'package'
    local packagesLeft = Player.PlayerData.metadata["postman_packages"] or 0

    if packagesLeft <= 0 then
        Notify(src, "You have no packages left.", "error")
        return
    end
    if delivered > packagesLeft then delivered = packagesLeft end

    -- verifică în inventar dacă are destule
    local invItem = Player.Functions.GetItemByName(itemName)
    local have = invItem and invItem.amount or 0
    if have < delivered then
        Notify(src, "Not enough packages on you.", "error")
        return
    end

    -- scoate pachetele livrate
    RemoveItem(Player, itemName, delivered)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], 'remove')

    -- plătește
    local payPer = Config.PayPerPackage or 5
    local pay = delivered * payPer
    Player.Functions.AddMoney('cash', pay, "postman-job")
    Notify(src, ("You received $%d for %d packages."):format(pay, delivered), "success")

    -- update meta și următoarea rută
    packagesLeft = packagesLeft - delivered
    Player.Functions.SetMetaData("postman_packages", packagesLeft)

    if packagesLeft > 0 then
        local delay = Config.NextDeliveryDelay or 3000
        CreateThread(function()
            Wait(delay + 0)
            local locs = Config.DeliveryLocations or {}
            if #locs == 0 then
                Notify(src, "No delivery locations configured.", "error")
                return
            end
            local location = locs[math.random(1, #locs)]
            local minPer = Config.MinPackagesPerDelivery or 1
            local maxPer = Config.MaxPackagesPerDelivery or 5
            if maxPer < minPer then maxPer = minPer end
            local deliverNow = math.random(minPer, maxPer)
            if deliverNow > packagesLeft then deliverNow = packagesLeft end
            TriggerClientEvent('rsg-postman:setDelivery', src, location, deliverNow)
            Notify(src, "Next delivery assigned.", "inform")
        end)
    else
        Notify(src, "All deliveries completed. Good job!", "success")
    end
end)

-- ===== STOP JOB (return all) =====
RegisterNetEvent('rsg-postman:stopJob', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local itemName = Config.PackageItem or 'package'
    local packagesLeft = Player.PlayerData.metadata["postman_packages"] or 0

    if packagesLeft > 0 then
        local invItem = Player.Functions.GetItemByName(itemName)
        if invItem and invItem.amount > 0 then
            RemoveItem(Player, itemName, invItem.amount)
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], 'remove')
        end
    end

    Player.Functions.SetMetaData("postman_packages", 0)
    Notify(src, "You returned all undelivered packages.", "inform")
end)
