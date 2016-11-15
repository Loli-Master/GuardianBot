--declare global variables
guardList = {}
markerList = {}
blipList = {}
iterator=0
cost=25000
--declare custom events
addEvent("checkTable",true)
--make markers
function createMarkerAttachedTo(element, mType, size, r, g, b, a, visibleTo, xOffset, yOffset, zOffset)
	mType, size, r, g, b, a, visibleTo, xOffset, yOffset, zOffset = mType or "checkpoint", size or 4, r or 0, g or 0, b or 255, a or 255, visibleTo or getRootElement(), xOffset or 0, yOffset or 0, zOffset or 0
	assert(isElement(element), "Bad argument @ 'createMarkerAttachedTo' [Expected element at argument 1, got " .. type(element) .. "]") assert(type(mType) == "string", "Bad argument @ 'createMarkerAttachedTo' [Expected string at argument 2, got " .. type(mType) .. "]") assert(type(size) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 3, got " .. type(size) .. "]") assert(type(r) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 4, got " .. type(r) .. "]")	assert(type(g) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 5, got " .. type(g) .. "]") assert(type(b) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 6, got " .. type(b) .. "]") assert(type(a) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 7, got " .. type(a) .. "]") assert(isElement(visibleTo), "Bad argument @ 'createMarkerAttachedTo' [Expected element at argument 8, got " .. type(visibleTo) .. "]") assert(type(xOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 9, got " .. type(xOffset) .. "]") assert(type(yOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 10, got " .. type(yOffset) .. "]") assert(type(zOffset) == "number", "Bad argument @ 'createMarkerAttachedTo' [Expected number at argument 11, got " .. type(zOffset) .. "]")
	local m = createMarker(0, 0, 0, mType, size, r, g, b, a, visibleTo)
	if m then if attachElements(m, element, xOffset, yOffset, zOffset) then return m end end return false
end
--make table compressed
function compressTable()
	local tempGuardTable= {}
	local tempMarkerTable= {}
	local tempBlipTable= {}
	local newkey = 0
	for key=1, iterator, 1 do
		if((not isElement(guardList[key]))or(getElementHealth(guardList[key])<=0))then
			destroyElement(blipList[key])
			destroyElement(markerList[key])
		else
			newkey = newkey + 1
			tempGuardTable[newkey]=guardList[key]
			tempMarkerTable[newkey]=markerList[key]
			tempBlipTable[newkey]=blipList[key]
		end
	end
	guardList = nil
	markerList = nil
	blipList = nil
	guardList = tempGuardTable
	markerList = tempMarkerTable
	blipList = tempBlipTable
	iterator = newkey
end
addEventHandler("checkTable",getRootElement(),compressTable)
--check every dead ped
function clearall()
	compressTable()
end
addEventHandler("onPedWasted", getRootElement(), clearall)
--make the bodyguard
function copyBot(from)
	local x,y,z = getElementPosition(from)
	local tpTeam = getPlayerTeam(from)
	local tpName = getPlayerName(from)
	if(tpTeam and(getPlayerMoney(from)>=cost))then
		local nmTeam = getTeamName(tpTeam)
		iterator = iterator + 1
		guardList[iterator] = exports["slothbot"]:spawnBot(x+5, y, z, 0, 163, 0, 0, tpTeam, 29, "following", from)
		outputChatBox("Working...", from, 0, 0, 255, true)
		triggerEvent("checkTable", from)
		if(guardList[iterator])then
			takePlayerMoney(from, cost)
			setElementData(guardList[iterator], "ownerName", tpName)
			setElementData(guardList[iterator], "guardteam", nmTeam)
			blipList[iterator] = createBlipAttachedTo(guardList[iterator],0,2,0,255,0,255,0,65535,getRootElement())
			markerList[iterator] = createMarkerAttachedTo(guardList[iterator],"arrow",0.3,0,255,0,0,getRootElement(),0,0,1.3)
			outputChatBox("Beware, "..tpName.." #ff0000 has created a bodyguard!", getRootElement(), 255, 0, 0, true)
		else
			guardList[iterator]=nil
			iterator = iterator - 1
			outputChatBox("Sorry an error occured, please pm to the creator(ilhamaryasuta)!", from, 255, 0, 0, true)
		end
	elseif(tpTeam and (getPlayerMoney(from)>=cost))then
		outputChatBox("You don't have enough money!",from, 255, 0, 0, true)
	else
		if(isGuestAccount(getPlayerAccount(from)))then
			outputChatBox("Please register/login first!", from, 255, 0, 0, true)
		else
			outputChatBox("Please join a team first!", from, 255, 0, 0, true)			
		end
	end
end
addCommandHandler("createguard", copyBot)
--count the bodyguard
function countGuard(from)
	triggerEvent("checkTable", from)
	outputChatBox("there is "..iterator.." bodyguards", from, 0, 255, 0, true)
	for gkey,gval in pairs(guardList)do
		if(isElement(gval))then
			local gHealth = getElementHealth(gval)
			local thisOwner = getElementData(gval, "ownerName")
			outputChatBox("Bodyguard "..gkey.." : "..math.floor(gHealth+0.5).." hp, Owner : "..thisOwner.."#00ff00 !", from, 0, 255, 0, true)
		else
			outputChatBox("Bodyguard "..gkey.." : Dead", from, 0, 255, 0, true)
		end
	end
end
addCommandHandler("guard", countGuard)
--clean the bodyguard data
function sweepGuard(from)
	triggerEvent("checkTable", from)
end
addCommandHandler("cleanguard", sweepGuard)