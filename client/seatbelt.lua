local velBuffer    = {}
local beltOn       = false
local wasInCar     = false
previousDamage = {}


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

local function init()
	local ped = GetPlayerPed(-1)
	local car = GetVehiclePedIsIn(ped, false)

	while math.ceil(GetEntitySpeed(cache.vehicle)) * 3.6 > 5 do
		Wait(100)
		
				
		if cache.vehicle ~= 0 then
		
			wasInCar = true
			
			if beltOn then DisableControlAction(0, 75) end
			
			currentSpeed = math.ceil(GetEntitySpeed(car))
			currentDamage = math.ceil(GetVehicleBodyHealth(car))

			for i = 1, 20 do
				previousDamage[i] = math.ceil(GetVehicleBodyHealth(cache.vehicle))
				Wait(10)
			end

			print(currentSpeed * 3.6)
			print('PREVIOU'..math.ceil(previousDamage[20]))

			if (currentSpeed * 3.6 > 40)
				and currentDamage - previousDamage[20] > 10 then
			   
				local co = GetEntityCoords(ped)
				local fw = Fwv(ped)
				SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
				SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
				Citizen.Wait(1)
				SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
			end
				
			velBuffer[2] = velBuffer[1]
			velBuffer[1] = GetEntityVelocity(cache.vehicle)
				
			if IsControlJustReleased(0, 311) then
				beltOn = not beltOn				  
				if beltOn then TriggerEvent('chatMessage', '0')
				else TriggerEvent('chatMessage', '1') end 
			end
			
		elseif wasInCar then
			wasInCar = false
			beltOn = false

		end
		Wait(100)
	end
end



CreateThread(function ()
	do while true do
	Wait(100)
		init()
		end
	end
end)
