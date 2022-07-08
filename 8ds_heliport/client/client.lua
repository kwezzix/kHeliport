ESX = nil

local playerCars = {}

khelico_deal = {
	catevehi = {},
	listecatevehi = {},
}

local derniervoituresorti = {}
local sortirvoitureacheter = {}
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle, CurrentVehicleData
local CurrentActionData, Vehicles, Categories = {}, {}, {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
if helico.blips then
        local poshelico = AddBlipForCoord(-949.9, -2946.76, 13.0)
        SetBlipSprite(poshelico, 43)
        SetBlipColour(poshelico, 4)
        SetBlipScale(poshelico, 0.90)
        SetBlipAsShortRange(poshelico, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Concessionnaire d'hélicoptère")
        EndTextCommandSetBlipName(poshelico)
end
end)

function MenuF6Concess()
    local f6concess = RageUI.CreateMenu("Concessionnaire hélicoptère", "Interactions")
    RageUI.Visible(f6concess, not RageUI.Visible(f6concess))
    while f6concess do
        Citizen.Wait(0)
            RageUI.IsVisible(f6concess, true, true, true, function()

                RageUI.Separator("↓ Facture ↓")

                RageUI.ButtonWithStyle("Facture",nil, {RightLabel = "→"}, true, function(_,_,s)
                    local player, distance = ESX.Game.GetClosestPlayer()
                    if s then
                        local raison = ""
                        local montant = 0
                        AddTextEntry("FMMC_MPM_NA", "Objet de la facture")
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Donnez le motif de la facture :", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            if result then
                                raison = result
                                result = nil
                                AddTextEntry("FMMC_MPM_NA", "Montant de la facture")
                                DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Indiquez le montant de la facture :", "", "", "", "", 30)
                                while (UpdateOnscreenKeyboard() == 0) do
                                    DisableAllControlActions(0)
                                    Wait(0)
                                end
                                if (GetOnscreenKeyboardResult()) then
                                    result = GetOnscreenKeyboardResult()
                                    if result then
                                        montant = result
                                        result = nil
                                        if player ~= -1 and distance <= 3.0 then
                                            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_helicopteredealer', ('Concessionnaire d\'hélicoptère'), montant)
                                            TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..montant.. '$ ~s~pour cette raison : ~b~' ..raison.. '', 'CHAR_BANK_FLEECA', 9)
                                        else
                                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)


                RageUI.Separator("↓ Annonce ↓")



                RageUI.ButtonWithStyle("Annonces d'ouverture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then       
                        TriggerServerEvent('KHelico:Ouvert')
                    end
                end)
        
                RageUI.ButtonWithStyle("Annonces de fermeture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then      
                        TriggerServerEvent('KHelico:Fermer')
                    end
                end)

                RageUI.ButtonWithStyle("Personnalisé", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local msg = KeyboardInput("Message", "", 100)
                        TriggerServerEvent('KHelico:Perso', msg)
                    end
                end)

                end, function() 
                end)
    
                if not RageUI.Visible(f6concess) then
                    f6concess = RMenu:DeleteType("Concessionnaire d'hélicoptère", true)
        end
    end
end


Keys.Register('F6', 'Concess', 'Ouvrir le menu Concessionnaire d\'hélicoptère', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'helicopteredealer' then
    	MenuF6Concess()
	end
end)

function CoffreConcess()
	local Coffreconcess = RageUI.CreateMenu("Concessionnaire d'hélicoptère", "Coffre")
        RageUI.Visible(Coffreconcess, not RageUI.Visible(Coffreconcess))
            while Coffreconcess do
            Citizen.Wait(0)
            RageUI.IsVisible(Coffreconcess, true, true, true, function()

                RageUI.Separator("↓ Objet ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ConcessRetirerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ConcessDeposerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                end, function()
                end)
            if not RageUI.Visible(Coffreconcess) then
            Coffreconcess = RMenu:DeleteType("Coffreconcess", true)
        end
    end
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'helicopteredealer' then  
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, helico.pos.coffre.position.x, helico.pos.coffre.position.y, helico.pos.coffre.position.z)
            if jobdist <= 10.0 and helico.marker then
                Timer = 0
                DrawMarker(20, helico.pos.coffre.position.x, helico.pos.coffre.position.y, helico.pos.coffre.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au coffre", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            CoffreConcess()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)

itemstock = {}
function ConcessRetirerobjet()
	local StockConcess = RageUI.CreateMenu("Concessionnaire d'hélicoptère", "Coffre")
	ESX.TriggerServerCallback('helico:getStockItems', function(items) 
	itemstock = items
	RageUI.Visible(StockConcess, not RageUI.Visible(StockConcess))
        while StockConcess do
		    Citizen.Wait(0)
		        RageUI.IsVisible(StockConcess, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count ~= 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", '' , 8)
                                    TriggerServerEvent('helico:getStockItem', v.name, tonumber(count))
                                    ConcessRetirerobjet()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockConcess) then
            StockConcess = RMenu:DeleteType("StockConcess", true)
        end
    end
end)
end

local PlayersItem = {}
function ConcessDeposerobjet()
    local DepositConcess = RageUI.CreateMenu("Concessionnaire d'hélicoptère", "Coffre")
    ESX.TriggerServerCallback('helico:getPlayerInventory', function(inventory)
        RageUI.Visible(DepositConcess, not RageUI.Visible(DepositConcess))
    while DepositConcess do
        Citizen.Wait(0)
            RageUI.IsVisible(DepositConcess, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                        RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local count = KeyboardInput("Combien ?", '' , 8)
                                            TriggerServerEvent('helico:putStockItems', item.name, tonumber(count))
                                            BDeposerobjet()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(DepositConcess) then
                DepositConcess = RMenu:DeleteType("DepositConcess", true)
            end
        end
    end)
end

function MenuConcess()
    local MConcess = RageUI.CreateMenu("Menu", "Concessionnaire d'hélicoptère")
    local MConcessSub = RageUI.CreateSubMenu(MConcess, "Menu", "Concessionnaire d'hélicoptère")
    local MConcessSub1 = RageUI.CreateSubMenu(MConcess, "Menu", "Concessionnaire d'hélicoptère")
    local MConcessSub2 = RageUI.CreateSubMenu(MConcess, "Menu", "Concessionnaire d'hélicoptère")
    MConcessSub2.Closed = function()
        supprimervehiculeconcess()
    end
    RageUI.Visible(MConcess, not RageUI.Visible(MConcess))
    while MConcess do
        Wait(0)
            RageUI.IsVisible(MConcess, true, true, true, function()

                RageUI.Separator("~b~"..ESX.PlayerData.job.grade_label.." - "..GetPlayerName(PlayerId()))


                RageUI.Separator("↓ Actions hélicoptères ↓")

                RageUI.ButtonWithStyle("Liste des hélicoptères", nil,  {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                end, MConcessSub)

			end, function()
			end)

            	RageUI.IsVisible(MConcessSub, true, true, true, function()
                
					for i = 1, #khelico_deal.catevehi, 1 do
                        RageUI.ButtonWithStyle("Catégorie - "..khelico_deal.catevehi[i].label, nil, {RightLabel = "→→→"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                                nomcategorie = khelico_deal.catevehi[i].label
                                categorievehi = khelico_deal.catevehi[i].name
                                ESX.TriggerServerCallback('helico:recupererlistevehicule', function(listevehi)
                                        khelico_deal.listecatevehi = listevehi
                                end, categorievehi)
                            end
                        end, MConcessSub1)
                        end
                        end, function()
                        end)

                RageUI.IsVisible(MConcessSub1, true, true, true, function()
			

                    RageUI.Separator("↓ Liste des : "..nomcategorie.." ↓")
            
                        for i2 = 1, #khelico_deal.listecatevehi, 1 do
                        RageUI.ButtonWithStyle(khelico_deal.listecatevehi[i2].name, "Pour acheter cette hélicoptère", {RightLabel = khelico_deal.listecatevehi[i2].price.."$"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                                nomvoiture = khelico_deal.listecatevehi[i2].name
                                prixvoiture = khelico_deal.listecatevehi[i2].price
                                modelevoiture = khelico_deal.listecatevehi[i2].model
                                supprimervehiculeconcess()
                                chargementvoiture(modelevoiture)
            
                                ESX.Game.SpawnVehicle(modelevoiture, {x = helico.pos.spawnvoiture.position.x, y = helico.pos.spawnvoiture.position.y, z = helico.pos.spawnvoiture.position.z}, helico.pos.spawnvoiture.position.h, function (vehicle)
                                table.insert(derniervoituresorti, vehicle)
                                FreezeEntityPosition(vehicle, true)
                                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                SetModelAsNoLongerNeeded(modelevoiture)
                                end)
                            end
                        end, MConcessSub2)
                        
                        end
                        end, function()
                        end)

                        RageUI.IsVisible(MConcessSub2, true, true, true, function()

                            RageUI.Separator("~r~↓ Vendre l'hélicoptère au joueur le plus proche ↓")

                            RageUI.ButtonWithStyle("Vendre l'hélicoptère", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                if (Selected) then    
                                        ESX.TriggerServerCallback('helico:verifsousconcess', function(suffisantsous)
                                        if suffisantsous then
                        
                                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                        if closestPlayer == -1 or closestDistance > 3.0 then
                                        ESX.ShowNotification('Il n\'y a personne autour.')
                                        else
                                        supprimervehiculeconcess()
                                        chargementvoiture(modelevoiture)
                        
                                        ESX.Game.SpawnVehicle(modelevoiture, {x = helico.pos.spawnvoiture.position.x, y = helico.pos.spawnvoiture.position.y, z = helico.pos.spawnvoiture.position.z}, helico.pos.spawnvoiture.position.h, function (vehicle)
                                        table.insert(sortirvoitureacheter, vehicle)
                                        FreezeEntityPosition(vehicle, true)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        SetModelAsNoLongerNeeded(modelevoiture)
                                        local plaque     = GeneratePlate()
                                        local vehicleProps = ESX.Game.GetVehicleProperties(sortirvoitureacheter[#sortirvoitureacheter])
                                        vehicleProps.plate = plaque
                                        SetVehicleNumberPlateText(sortirvoitureacheter[#sortirvoitureacheter], plaque)
                                        FreezeEntityPosition(sortirvoitureacheter[#sortirvoitureacheter], false)
                        
                                        TriggerServerEvent('helico:vendrevoiturejoueur', GetPlayerServerId(closestPlayer), vehicleProps, prixvoiture, nomvoiture)
                                        ESX.ShowNotification('Le véhicule '..nomvoiture..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(closestPlayer))
                                        TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                                        end)
                                        end
                                        else
                                            ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                                        end
                        
                                    end, prixvoiture)
                                        end
                                    end)

                                    RageUI.Separator("~b~↓ Acheter le véhicule avec l'argent de la societé ↓")

                                    RageUI.ButtonWithStyle("Acheter le véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                        if (Selected) then   
                                            ESX.TriggerServerCallback('helico:verifsousconcess', function(suffisantsous)
                                            if suffisantsous then
                                            supprimervehiculeconcess()
                                            chargementvoiture(modelevoiture)
					    ESX.Game.SpawnVehicle(modelevoiture, {x = helico.pos.spawnvoiture.position.x, y = helico.pos.spawnvoiture.position.y, z = helico.pos.spawnvoiture.position.z}, helico.pos.spawnvoiture.position.h, function (vehicle)                                            table.insert(sortirvoitureacheter, vehicle)
                                            FreezeEntityPosition(vehicle, true)
                                            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                            SetModelAsNoLongerNeeded(modelevoiture)
                                            local plaque     = GeneratePlate()
                                            local vehicleProps = ESX.Game.GetVehicleProperties(sortirvoitureacheter[#sortirvoitureacheter])
                                            vehicleProps.plate = plaque
                                            SetVehicleNumberPlateText(sortirvoitureacheter[#sortirvoitureacheter], plaque)
                                            FreezeEntityPosition(sortirvoitureacheter[#sortirvoitureacheter], false)
                        
                                            TriggerServerEvent('shop:vehicule', vehicleProps, prixvoiture, nomvoiture)
                                            ESX.ShowNotification('Le véhicule '..nomvoiture..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(PlayerId()))
                                            TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                                            end)
                        
                                            else
                                                ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                                            end
                            
                                        end, prixvoiture)
                                            end
                                        end)

                        end, function()
                        end)

              if not RageUI.Visible(MConcess) and not RageUI.Visible(MConcessSub) and not RageUI.Visible(MConcessSub1) and not RageUI.Visible(MConcessSub2) then
              MConcess = RMenu:DeleteType("MConcess", true)
        end
    end
end


Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'helicopteredealer' or ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'helicopteredealer' then  
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, helico.pos.menu.position.x, helico.pos.menu.position.y, helico.pos.menu.position.z)
            if jobdist <= 10.0 and helico.marker then
                Timer = 0
                DrawMarker(20, helico.pos.menu.position.x, helico.pos.menu.position.y, helico.pos.menu.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au menu", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            ESX.TriggerServerCallback('helico:recuperercategorievehicule', function(catevehi)
                                khelico_deal.catevehi = catevehi
                            end)
                            MenuConcess()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)


function MenuSerrurier()
	local MSerrurier = RageUI.CreateMenu("Menu Serrurier", "Enregistrer des clés")
    ESX.TriggerServerCallback('ddx_vehiclelock:getVehiclesnokey', function(Vehicles2)
        RageUI.Visible(MSerrurier, not RageUI.Visible(MSerrurier))
            while MSerrurier do
            Citizen.Wait(0)
            RageUI.IsVisible(MSerrurier, true, true, true, function()
                RageUI.Separator('~g~Bienvenue '..GetPlayerName(PlayerId()))
                    for i=1, #Vehicles2, 1 do
                        model = Vehicles2[i].model
                        modelname = GetDisplayNameFromVehicleModel(model)
                        Vehicles2[i].model = GetLabelText(modelname)
                    RageUI.ButtonWithStyle(Vehicles2[i].model .. ' [' .. Vehicles2[i].plate .. ']',nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('ddx_vehiclelock:registerkey', Vehicles2[i].plate, 'no')
                            MenuSerrurier()
                        end
                    end)
                end
                end, function()
                end)
            if not RageUI.Visible(MSerrurier) then
            MSerrurier = RMenu:DeleteType("MSerrurier", true)
        end
    end
end)
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, helico.pos.serrurier.position.x, helico.pos.serrurier.position.y, helico.pos.serrurier.position.z)
            if jobdist <= 10.0 and helico.marker then
                Timer = 0
                DrawMarker(20, helico.pos.serrurier.position.x, helico.pos.serrurier.position.y, helico.pos.serrurier.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyer sur ~y~[E]~s~ pour enregistrer des clés.", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            MenuSerrurier()
                            ESX.TriggerServerCallback('ddx_vehiclelock:getVehiclesnokey', function(Vehicles2)
                            end)
                    end   
                end 
        Citizen.Wait(Timer)   
    end
end)

function supprimervehiculeconcess()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

		ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniervoituresorti, 1)
	end
end

function chargementvoiture(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyString('STRING')
		AddTextComponentSubstringPlayerName('Chargement du véhicule')
		EndTextCommandBusyString(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
			DisableAllControlActions(0)
		end

		RemoveLoadingPrompt()
	end
end

function OpenCloseVehicle()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed, true)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
	end

	ESX.TriggerServerCallback('ddx_vehiclelock:mykey', function(gotkey)

		if gotkey then
			local locked = GetVehicleDoorLockStatus(vehicle)
			if locked == 1 or locked == 0 then -- if unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				ESX.ShowNotification("Vous avez ~r~fermé~s~ le véhicule.")
			elseif locked == 2 then -- if locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				ESX.ShowNotification("Vous avez ~g~ouvert~s~ le véhicule.")
			end
		else
			ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
		end
	end, GetVehicleNumberPlateText(vehicle))
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustReleased(0,303) then 
			OpenCloseVehicle()
		end
	end
end)

Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 303) then -- When you press "U"
             if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
                TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
				StopAnimTask = true
              else
                TriggerEvent("chatMessage", "", { 200, 200, 90 }, "Vous devez être sorti d'un véhicule pour l'utiliser les clés !") -- Shows this message when you are not in a vehicle in the chat
				
             end
        end
    end
end)

Citizen.CreateThread(function()
	RequestIpl('shr_int') -- Load walls and floor

	local interiorID = 7170
	LoadInterior(interiorID)
	EnableInteriorProp(interiorID, 'csr_beforeMission') -- Load large window
	RefreshInterior(interiorID)
end)
