local velBuffer      = {}
local previousDamage = {}

IsCar = function(veh)
		    local vc = GetVehicleClass(veh)
		    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
        end	

Fwv = function (entity)
		    local hr = GetEntityHeading(entity) + 90.0
		    if hr < 0.0 then hr = 360.0 + hr end
		    hr = hr * 0.0174533
		    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
      end

RegisterCommand('seatbelt', function ()

	local seatbelt = LocalPlayer.state.seatbelt

	if GetVehiclePedIsIn(GetPlayerPed(-1), false) > 0 then
		if not seatbelt then
			Wait(1500)
			LocalPlayer.state:set('seatbelt', true, true)
		elseif seatbelt then
			Wait(1500)
			LocalPlayer.state:set('seatbelt', false, true)
		end
		print(LocalPlayer.state.seatbelt)
		SendNUIMessage({
			action = 'setSeatbelt',
			data = LocalPlayer.state.seatbelt
		})
	end	  
	
end)
RegisterKeyMapping('seatbelt', 'Toggle Seatbelt', 'keyboard', 'B')

local function init()
	local ped = GetPlayerPed(-1)
	local co = GetEntityCoords(ped)
	local fw = Fwv(ped)

	while GetEntitySpeed(cache.vehicle) * 3.6 > 15 do
		Wait(1)
			
			currentSpeed = GetEntitySpeed(cache.vehicle) * 3.6
			currentDamage = math.ceil(GetVehicleBodyHealth(cache.vehicle))

			for i = 1, 2 do
				Wait(200)
				previousDamage[i] = math.ceil(GetVehicleBodyHealth(cache.vehicle))
				velBuffer[i] = GetEntityVelocity(cache.vehicle)
			end			

			if currentDamage - previousDamage[2] > 20 then
				SetVehicleEngineOn(cache.vehicle, false, true, false)
			end
			if math.ceil(GetVehicleBodyHealth(cache.vehicle)) < 700 then
				SetVehicleUndriveable(cache.vehicle, true)
			end
			print(LocalPlayer.state.seatbelt)
			if currentSpeed > 40
				and currentDamage - previousDamage[2] > 10
				and not LocalPlayer.state.seatbelt
				then
				
				co = GetEntityCoords(ped)
				fw = Fwv(ped)
				SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
				SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
				Wait(1)
				SetPedToRagdoll(ped, 1e3, 1e3, 0, false, false, false)
			end
	end
end

CreateThread(function ()
	 repeat
		if not IsPedInAnyVehicle(PlayerPedId(), false) then
			LocalPlayer.state:set('seatbelt', false, true) --when player is not in vehicle set to false
			SendNUIMessage({
				action = 'setSeatbelt',
				data = LocalPlayer.state.seatbelt
			})
		end
		print(LocalPlayer.state.seatbelt)
		init()
		Wait(1000)
	 until GetVehiclePedIsIn(ped, false) > 0
end)
