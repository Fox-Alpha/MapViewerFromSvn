MapViewerDialog = {}
local MapViewerDialog_mt = Class(MapViewerDialog)

function MapViewerDialog:new()
	local self = {}
	self = setmetatable(self, MapViewerDialog_mt)
	
	self.mode = 1;
	self.numberOfModes = 6;
	self.dialogIsActive = false;
	
	self.plyname = {};
	self.plyname.name = "";

	
	----
	--	Daten Tables
	----
	self.Player = {};
	self.Map = {};
	self.Vehicle = {};
	----
	
	return self
end
function MapViewerDialog:onOpen(element)
	g_currentMission.isPlayerFrozen = true;
	InputBinding.setShowMouseCursor(true);
	self.dialogIsActive = true;
	self:updateDialog();
end

function MapViewerDialog:onClose(element)
	g_currentMission.isPlayerFrozen = false
	InputBinding.setShowMouseCursor(false)
	self.dialogIsActive = false;
end

function MapViewerDialog:setTitle(text)
  if self.titleElement ~= nil then
    self.titleElement:setText(text)
  end
end

function MapViewerDialog:setText(text)
	if self.textElement ~= nil then
		self.textElement:setText(text)
	end
end

function MapViewerDialog:onCreateTitle(element)
	self.titleElement = element
end

function MapViewerDialog:onCreateText(element)
	self.textElement = element
end

function MapViewerDialog:onBackClick()
  g_gui:showGui("")
end

function MapViewerDialog:setMapImageFilename(filename)
	-- print(string.format("setMapImageFilename(): %s", tostring(filename)));
	if filename ~= nil and filename ~= "" then
		self.mv_Main:setImageFilename(filename);
	end;
	-- print(string.format("setMapImageFilename(): %s", tostring(self.mv_Main.overlay)));
	-- print(string.format("setMapImageFilename(): %s", tostring(self.mv_Main.imageFilename)));
end;

function MapViewerDialog:modeSelectionOnCreate(element)
	self.modeSelectionElement = element
	self.modeSelectionElement.wrap = true
	local tempTable = {}
	for i = 1, self.numberOfModes do
		table.insert(tempTable, g_i18n:getText("MV_Mode" .. tostring(i) .. "Name"))
	end
	element:setTexts(tempTable)
	element:setState(1)
end

function InGameMenu:modeSelectionOnClick(state)
	self.mode = state
	self:updateGUI()
end

function MapViewerDialog:update(dt)
	if InputBinding.hasEvent(InputBinding.MENU, true) or InputBinding.hasEvent(InputBinding.MENU_CANCEL, true) then
		InputBinding.hasEvent(InputBinding.MENU, true)
		InputBinding.hasEvent(InputBinding.MENU_CANCEL, true)
		self:onBackClick()
	end
end

function MapViewerDialog:updateGUI()
	-- TODO: bei wechsel des Overlays, GUI Elemente anpassen
end

function MapViewerDialog:updateDialog()
	self:updateFocusLinkageSystem()
end

function MapViewerDialog:updateFocusLinkageSystem()
	if g_gui.currentGuiName == "MapViewerDialog" then
		-- local buttonBack = FocusManager:getElementById("3")
		-- FocusManager:linkElements(buttonBack, FocusManager.LEFT, buttonBuy)
	end
end

----
--
----
function MapViewerDialog:draw()
	-- Nur wenn Dialog geöffnet ist
	if self.dialogIsActive then
		-- Darstellen der Spieler Position/en
		self:renderPlayer();
		self:renderVehicle();
	end;
end;
----

----------------------------------
--	Inizialisierung der Daten	--
----------------------------------

----
--	Inizialisierung der Daten für die Spieler
----
function MapViewerDialog:initPlayer(_player)
	if type(_player) == "table" and table.count(_player) > 0 then
		self.Player = _player;
		return true;
	else
		return false;
	end;
end;
----

----
--	Inizialisierung der Daten für die Karte
----
function MapViewerDialog:initMap(_map)
	if type(_map) == "table" and table.count(_map) > 0 then
		self.Map = _map;
		-- TODO: Prüfen ob der Dateiname existiert und falls möglich übergebenes Overlay aus Map nutzen
		self:setMapImageFilename(self.Map.file);
		return true;
	else
		return false;
	end;
end;
----

----
--	Inizialisierung der Daten für die Vehicle
----
function MapViewerDialog:initVehicle(_vehicle)
	if type(_vehicle) == "table" and table.count(_vehicle) > 0 then
		self.Vehicle = _vehicle;
		-- TODO: Einzelne unter Tabellen auf Daten prüfen
		return true;
	else
		return false;
	end;
end;
----

----------------------------------------------------------
--	Rendern der einzelnen Overlays und weiterer Daten	--
----------------------------------------------------------

----
-- Rendern der Spielerposition/en
----
function MapViewerDialog:renderPlayer()
	local mplayer = {};
	for key, value in pairs (g_currentMission.players) do
		mplayer.player = value;
		if mplayer.player.isControlled == false then
			posX = mplayer.player.lastXPos;
			posY = mplayer.player.lastYPos;
			posZ = posY;
		else
			posX, posY, posZ = getWorldTranslation(mplayer.player.rootNode);
		end;

		mplayer.xPos = ((((self.Map.mapDimensionX/2)+posX)/self.Map.mapDimensionX)*self.Map.width);--self.bigmap.player.xPosPDA+0.008;
		mplayer.yPos = ((((self.Map.mapDimensionY/2)-posZ)/self.Map.mapDimensionY)*self.Map.height);--self.bigmap.player.yPosPDA+0.003;
		setTextColor(0, 1, 0, 1);

		-- lokaler Spieler
		if mplayer.player.rootNode == self.activePlayerNode and mplayer.player.isControlled then
			if self.Player.ArrowOverlayId ~= nil and self.Player.ArrowOverlayId ~= 0 then
				renderOverlay(self.Player.ArrowOverlayId, 
								mplayer.xPos-self.Player.width/2, mplayer.yPos-self.Player.height/2,
								self.Player.width, self.Player.height);
			end;
			renderText(mplayer.xPos +self.Player.width/2, mplayer.yPos-self.Player.height/2, 0.015, mplayer.player.controllerName);
			-- renderText(0.020, 0.060, 0.015, string.format("Koordinaten : x%.1f / y%.1f",mplayer.xPos*1000,mplayer.yPos*1000));
		-- Andere Mitspieler
		elseif mplayer.player.isControlled then
			if self.Player.mpArrowOverlayId ~=nil and self.Player.mpArrowOverlayId ~= 0 then
				renderOverlay(self.Player.mpArrowOverlayId, 
								mplayer.xPos-self.Player.width/2, mplayer.yPos-self.Player.height/2, 
								self.Player.width, self.Player.height);
			end;
			renderText(mplayer.xPos +self.Player.width/2, mplayer.yPos-self.Player.height/2, 0.015, mplayer.player.controllerName);
		end;
		setTextColor(1, 1, 1, 0);
	end;
end;
----

----
-- Rendern der Vehicle Positionen
-- Steerables
--	Mit Courseplay wenn Panel aktiv
--	Unbrauchbare Fahrzeuge
-- Attachments
-- Milchtruck
----
--	Step1: Fahrzeuge
--	Step2: Attachments
--	Step3: Milchtruck
--	Step4: brocken Fz.
----
function MapViewerDialog:renderVehicle()
	self.plyname.name = g_currentMission.player.controllerName;
	for i=1, table.getn(g_currentMission.steerables) do
		if not g_currentMission.steerables[i].isBroken then
			self.currentVehicle = g_currentMission.steerables[i];
			self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
			self.buttonX = ((((self.Map.mapDimensionX/2)+self.posX)/self.Map.mapDimensionX)*self.Map.width);
			self.buttonZ = ((((self.Map.mapDimensionY/2)-self.posZ)/self.Map.mapDimensionY)*self.Map.height);
			
			----
			-- Auslesen der Kurse wenn CoursePlay vorhanden ist
			----
			-- if self.useCoursePlay then
				-- if SpecializationUtil.hasSpecialization(courseplay, self.currentVehicle.specializations) and self.showCP then
					-- if self.bigmap.IconCourseplay.Icon.OverlayId ~= nil and self.bigmap.IconCourseplay.Icon.OverlayId ~= 0 then
						-- for w=1, table.getn(g_currentMission.steerables[i].Waypoints) do
							-- local wx = g_currentMission.steerables[i].Waypoints[w].cx;
							-- local wz = g_currentMission.steerables[i].Waypoints[w].cz;
							-- wx = ((((self.bigmap.mapDimensionX/2)+wx)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
							-- wz = ((((self.bigmap.mapDimensionY/2)-wz)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);

							-- renderOverlay(self.bigmap.IconCourseplay.Icon.OverlayId,
										-- wx-self.bigmap.IconCourseplay.width/2, 
										-- wz-self.bigmap.IconCourseplay.height/2,
										-- self.bigmap.IconCourseplay.width,
										-- self.bigmap.IconCourseplay.height);
						-- end;
						-- setOverlayColor(self.bigmap.IconCourseplay.Icon.OverlayId, 1, 1, 1, 1);
					-- end;
				-- end;
			-- end;
			----
			
			setTextColor(0, 1, 0, 1);
			if self.currentVehicle.isControlled and self.currentVehicle.controllerName == self.plyname.name then
				if self.Vehicle.Steerable.mpOverlayId ~= nil and self.Vehicle.Steerable.mpOverlayId ~= 0 then
					renderOverlay(self.Vehicle.Steerable.mpOverlayId,
								self.buttonX-self.Vehicle.Steerable.width/2, 
								self.buttonZ-self.Vehicle.Steerable.height/2,
								self.Vehicle.Steerable.width,
								self.Vehicle.Steerable.height);
					setOverlayColor(self.Vehicle.Steerable.OverlayId, 1, 1, 1, 1);
				end;
				
				renderText(self.buttonX-0.025, self.buttonZ-self.Vehicle.Steerable.height-0.01, 0.015, string.format("%s", self.plyname.name));
				-- renderText(0.020, 0.020, 0.015, string.format("Koordinaten : x=%.1f / y=%.1f",self.buttonX * 1000,self.buttonZ * 1000));
			elseif self.currentVehicle.isControlled then
				if self.Vehicle.Steerable.mpOverlayId ~= nil and self.Vehicle.Steerable.mpOverlayId ~= 0 then
					renderOverlay(self.Vehicle.Steerable.mpOverlayId,
								self.buttonX-self.Vehicle.Steerable.width/2, 
								self.buttonZ-self.Vehicle.Steerable.height/2,
								self.Vehicle.Steerable.width,
								self.Vehicle.Steerable.height);
					setOverlayColor(self.Vehicle.Steerable.OverlayId, 1, 1, 1, 1);
				end;
				renderText(self.buttonX-0.025, self.buttonZ-self.Vehicle.Steerable.height-0.01, 0.015, string.format("%s", self.currentVehicle.controllerName));
			else
				if self.Vehicle.Steerable.OverlayId ~= nil and self.Vehicle.Steerable.OverlayId ~= 0 then
					renderOverlay(self.Vehicle.Steerable.OverlayId,
								self.buttonX-self.Vehicle.Steerable.width/2, 
								self.buttonZ-self.Vehicle.Steerable.height/2,
								self.Vehicle.Steerable.width,
								self.Vehicle.Steerable.height);
					setOverlayColor(self.Vehicle.Steerable.OverlayId, 1, 1, 1, 1);
				end;
			end;
			setTextColor(1, 1, 1,0);
		-- elseif g_currentMission.steerables[i].isBroken then
		----
		-- unbrauchbare Fahrzeuge mit weiterem Icon anzeigen
		----
			-- self.posX, self.posY, self.posZ = getWorldTranslation(g_currentMission.steerables[i].rootNode);
			-- self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
			-- self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
			-- if self.bigmap.iconIsBroken.Icon.OverlayId ~= nil and self.bigmap.iconIsBroken.Icon.OverlayId ~= 0 then
				-- renderOverlay(self.bigmap.iconIsBroken.Icon.OverlayId,
							-- self.buttonX-self.bigmap.iconIsBroken.width/2, 
							-- self.buttonZ-self.bigmap.iconIsBroken.height/2,
							-- self.bigmap.iconIsBroken.width,
							-- self.bigmap.iconIsBroken.height);
				-- setOverlayColor(self.bigmap.iconIsBroken.Icon.OverlayId, 1, 1, 1, 1);
			-- end;
		end;
	end;
	-----
	-- Darstellen der Geräte auf der Karte
	----
	for i=1, table.getn(g_currentMission.attachables) do
		self.currentVehicle = g_currentMission.attachables[i];
		self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
		self.buttonX = ((((self.Map.mapDimensionX/2)+self.posX)/self.Map.mapDimensionX)*self.Map.width);
		self.buttonZ = ((((self.Map.mapDimensionY/2)-self.posZ)/self.Map.mapDimensionY)*self.Map.height);

		if g_currentMission.attachables[i].attacherVehicle == nil or g_currentMission.attachables[i].attacherVehicle == 0 then
			if self.Vehicle.Attachments.types.overlays[g_currentMission.attachables[i].typeName] ~= nil then
				renderOverlay(self.Vehicle.Attachments.types.overlays[g_currentMission.attachables[i].typeName],
							self.buttonX-self.Vehicle.Attachments.types.width/2, 
							self.buttonZ-self.Vehicle.Attachments.types.height/2,
							self.Vehicle.Attachments.types.width,
							self.Vehicle.Attachments.typesheight);
			else
				renderOverlay(self.Vehicle.Attachments.types.overlays["other"],
							self.buttonX-self.Vehicle.Attachments.types.width/2, 
							self.buttonZ-self.Vehicle.Attachments.types.height/2,
							self.Vehicle.Attachments.types.width,
							self.Vehicle.Attachments.types.height);
			end;
		else
			renderOverlay(self.Vehicle.Attachments.Icon.front.OverlayId,
							self.buttonX-self.Vehicle.Attachments.width/2, 
							self.buttonZ-self.Vehicle.Attachments.height/2,
							self.Vehicle.Attachments.width,
							self.Vehicle.Attachments.height);
		end;
		setOverlayColor(self.Vehicle.Attachments.Icon.front.OverlayId, 1, 1, 1, 1);
	end;
	----
	
	----
	-- Milchtruck auf Karte Zeichnen
	----
	for i=1, table.getn(g_currentMission.trafficVehicles) do
		if g_currentMission.trafficVehicles[i].typeName == "milktruck" then
			self.currentVehicle = g_currentMission.trafficVehicles[i];
			if self.Vehicle.Milchtruck.OverlayId ~= nil and self.Vehicle.Milchtruck.OverlayId ~= 0 then
				self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
				self.buttonX = ((((self.Map.mapDimensionX/2)+self.posX)/self.Map.mapDimensionX)*self.Map.width);
				self.buttonZ = ((((self.Map.mapDimensionY/2)-self.posZ)/self.Map.mapDimensionY)*self.Map.height);
				
				if self.Vehicle.Milchtruck.OverlayId ~= nil then
					renderOverlay(self.Vehicle.Milchtruck.OverlayId,
								self.buttonX-self.Vehicle.Milchtruck.width/2, 
								self.buttonZ-self.Vehicle.Milchtruck.height/2,
								self.Vehicle.Milchtruck.width,
								self.Vehicle.Milchtruck.height);
				-- TODO: Milchtruckposition an Clients senden
				end;
			end;
			break;
		end;
	end;
	----
end;
----