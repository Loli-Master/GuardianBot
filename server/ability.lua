function mergeGuard(playerSource, commandName)
	local stat = isPedInVehicle(playerSource)
	if(stat)then
		local veh = getPedOccupiedVehicle(playerSource)
		local count = 0
		local err = 0
		local sl = 1
		local maxsl = getVehicleMaxPassengers(veh)
		local glist = {}
		for key,val in pairs(guardList)do
			if(getElementData(val,"ownerName")==getPlayerName(playerSource))then
				count=count+1
				glist[count]=key
			end
		end
		for key=1,count,1 do
			for j=sl,maxsl,1 do
				local apa = warpPedIntoVehicle(guardList[glist[key]],veh,j)
				if(apa)then
					break
				end
			end
			if(isPedInVehicle(guardList[glist[key]]))then
				sl=sl+1
			else
				err = err+1
			end
		end
		if(err>0)then
			outputChatBox("There is/are "..err.." bodyguard(s) on foot",playerSource,255,0,0,true)
		end
	else
		local count2 = 0
		local glist2 = {}
		for key,val in pairs(guardList)do
			if(getElementData(val,"ownerName")==getPlayerName(playerSource))and(isPedInVehicle(val))then
				count2=count2+1
				glist2[count2]=key
			end
		end
		for key=1,count2,1 do
			removePedFromVehicle(guardList[glist2[key]])
			exports["slothbot"]:setBotFollow(guardList[glist2[key]],playerSource)
		end
	end
end
addCommandHandler("joinvehicle",mergeGuard)