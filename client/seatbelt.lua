local velBuffer      = {}
local seatbelt       = false
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

RegisterCommand('+seatbelt', function ()

	if not seatbelt then
		seatbelt = true
	elseif seatbelt then
		seatbelt = false
	end

	SendNUIMessage({
	action = 'setSeatbelt',
	data = seatbelt
})	  
	
end)

RegisterKeyMapping('+seatbelt', 'Toggle Seatbelt', 'keyboard', 'B')


local function init()
	local ped = GetPlayerPed(-1)
	local car = GetVehiclePedIsIn(ped, false)
	local co = GetEntityCoords(ped)
	local fw = Fwv(ped)

	while GetVehiclePedIsIn(ped, false) > 0 and GetEntitySpeed(cache.vehicle) * 3.6 > 15 do
		Wait(1)

			if seatbelt then DisableControlAction(0, 75) end
			
			currentSpeed = GetEntitySpeed(cache.vehicle) * 3.6
			currentDamage = math.ceil(GetVehicleBodyHealth(cache.vehicle))

			for i = 1, 2 do
				Wait(200)
				previousDamage[i] = math.ceil(GetVehicleBodyHealth(cache.vehicle))
				velBuffer[i] = GetEntityVelocity(cache.vehicle)
			end

			 print(currentDamage - previousDamage[2])

			if currentSpeed > 40
				and currentDamage - previousDamage[2] > 10
				and not seatbelt
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
	 while true do
		Wait(1)
		init()
		end
end)
