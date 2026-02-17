RegisterNetEvent('munk-carwash:notify', function(msg, type)
    local src = source
    Config.Notify(src, msg, type)
end)
RegisterNetEvent('munk-carwash:tryWashNotInVehicle', function()
    local src = source
    local locale = Config.Locale or 'da'
    local msg = Config.Text and Config.Text[locale] and Config.Text[locale].not_in_vehicle or 'Sit in the vehicle and ask me again.'
    Config.Notify(src, msg, 'error')
end)
local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('munk-carwash:tryWash', function(type, loc)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local locale = Config.Locale or 'da'
    local notEnoughMsg = Config.Text and Config.Text[locale] and Config.Text[locale].not_enough_money or 'You don\'t have enough money.'
    local price = type == 'premium' and Config.PremiumPrice or Config.Price
    if price > 0 and xPlayer.getMoney() < price then
        Config.Notify(src, notEnoughMsg, 'error')
        return
    end
    if price > 0 then xPlayer.removeMoney(price) end
    TriggerClientEvent('munk-carwash:startWash', src, type, loc)
end)
