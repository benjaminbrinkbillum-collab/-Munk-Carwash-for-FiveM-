if GetCurrentResourceName and GetCurrentResourceName() ~= 'Munk-Carwash' then
    print('^1[ERROR]^7 Resource folder must be named ^3Munk-Carwash^7 for this script to work!')
    return
end

-- #################################################
-- #                                               #
-- #                 Munk script                   #
-- #                                               #
-- #                                               #
-- #                                               #
-- #                                               #
-- #################################################

Config = {}

--da for Danish, en for English

Config.Locale = "en"

Config.Price         = 250 --$ and kr 
Config.PremiumPrice  = 500 --$ and kr 

Config.WashTime      = 8000
Config.NPCModel      = 'a_m_m_business_01'
Config.EnablePremium = true

Config.Locations = {
    {coords = vector3(174.9310, -1733.8514, 29.2922), heading = 185.6681},
    -- {coords = vector3(x, y, z), heading = h},
}

if IsDuplicityVersion() then
    Config.Notify = function(src, msg, type)
        TriggerClientEvent('esx:showNotification', src, msg)
    end
else
    Config.Notify = function(src, msg, type)
        if exports and exports['okokNotify'] then
            local notifyType = type or 'info'
            exports['okokNotify']:Alert('Bilvask', msg, 5000, notifyType)
        elseif ESX and ESX.ShowNotification then
            ESX.ShowNotification(msg)
        else
            AddTextEntry('munk_notify', msg)
            BeginTextCommandThefeedPost('munk_notify')
            EndTextCommandThefeedPostTicker(false, false)
        end
    end
end

Config.Text = {
    ["da"] = {
        not_in_vehicle = "Sæt dig ind i bilen og spørg mig igen.",
        not_enough_money = "Du har ikke nok penge.",
        car_clean = "Bilen er nu ren. Rigtig god dag!",
        basic_label = "Normal Vask",
        premium_label = "Premium Vask (Ekstra glans)",
        blip = "Bilvask"
    },
    ["en"] = {
        not_in_vehicle = "Sit in the vehicle and ask me again.",
        not_enough_money = "You don't have enough money.",
        car_clean = "Your car is now clean. Have a great day!",
        basic_label = "Basic Wash",
        premium_label = "Premium Wash (Extra shine)",
        blip = "Car Wash"
    }
}
