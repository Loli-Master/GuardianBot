loadData = nil
--set bind key
function joinKey()
	bindKey(source,"b","down","joinvehicle")
end
addEventHandler("onPlayerJoin", getRootElement(), joinKey)
--load data.xml
function joinData()
	local count = 0
	local glist = {}
	local rname = getPlayerName(source)
	local xxTeam = getTeamName(getPlayerTeam(source))
	for key,val in pairs(guardList)do
		if(getElementData(val,"ownerName")==rname)then
			count=count+1
			glist[count]=key
		end
	end
	for key=1,count,1 do
		setElementData(guardList[iterator], "guardteam", xxTeam)
		exports["slothbot"]:setBotFollow(guardList[glist[key]],source)
	end
end
addEventHandler("onPlayerLogin", getRootElement(), joinData)
--add/open save files
function setAll(res)
	local resName = getResourceName(res)
	local allTeams = getElementsByType ( "team" )
	for index, theTeam in pairs(allTeams) do
		if ( getTeamFriendlyFire ( theTeam ) == true ) then
			setTeamFriendlyFire ( theTeam, false )
		end
	end	
	loadData = xmlLoadFile(":"..resName.."/data.xml")
	if(loadData)then
		local count = tonumber(xmlNodeGetValue(xmlFindChild(loadData, "count", 0)))
		local guards = xmlFindChild(loadData, "guards", 0)
		for lem=1,count,1 do
			local bots = xmlFindChild(guards, "bot"..lem, 0)
			local botX = tonumber(xmlNodeGetAttribute(bots, "posX"))
			local botY = tonumber(xmlNodeGetAttribute(bots, "posY"))
			local botZ = tonumber(xmlNodeGetAttribute(bots, "posZ"))
			local bteam = getTeamFromName(xmlNodeGetAttribute(bots, "guardteam"))
			local bowner = xmlNodeGetAttribute(bots, "ownerName")
			local task = "guarding"
			iterator = iterator + 1
			guardList[iterator] = exports["slothbot"]:spawnBot(botX, botY, botZ, 0, 163, 0, 0, bteam, 29, task)
			blipList[iterator] = createBlipAttachedTo(guardList[iterator],0,2,0,255,0,255,0,65535,getRootElement())
			markerList[iterator] = createMarkerAttachedTo(guardList[iterator],"arrow",0.3,0,255,0,0,getRootElement(),0,0,1.3)
			if(guardList[iterator])then
				setElementData(guardList[iterator], "ownerName", bowner)
			end
		end
	else
		loadData = nil
		loadData = xmlCreateFile(":"..resName.."/data.xml", "bodyguard")
		local bguard = xmlCreateChild(loadData, "count")
		local setguard = xmlCreateChild(loadData, "guards")
	end
	if(not loadData)then
		outputServerLog("bodyguard: An error occured when creating/loading data.xml , Stopping resources ...")
		stopResource(res)
	end
end
addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),setAll)
--save guards
function saveguard()
	local count = xmlFindChild(loadData, "count", 0)
	local guards = xmlFindChild(loadData, "guards", 0)
	compressTable()
	xmlNodeSetValue(count,tostring(iterator))
	xmlDestroyNode(guards)
	guards = xmlCreateChild(loadData, "guards")
	for key=1,iterator,1 do
		local bots = xmlCreateChild(guards, "bot"..key)
		local botX,botY,botZ = getElementPosition(guardList[key])
		local teamB = getElementData(guardList[key], "guardteam")
		local ownerb = getElementData(guardList[key], "ownerName")
		xmlNodeSetAttribute(bots, "posX", tostring(botX))
		xmlNodeSetAttribute(bots, "posY", tostring(botY))
		xmlNodeSetAttribute(bots, "posZ", tostring(botZ))
		xmlNodeSetAttribute(bots, "guardteam", teamB)
		xmlNodeSetAttribute(bots, "ownerName", ownerb)
		destroyElement(guardList[key])
	end
	xmlSaveFile(loadData)
	xmlUnloadFile(loadData)
end
addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),saveguard)