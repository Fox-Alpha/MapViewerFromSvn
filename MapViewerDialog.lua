MapViewerDialog = {}
local MapViewerDialog_mt = Class(MapViewerDialog)
MapViewerDialog.MODE_VEHICLES = 1;
MapViewerDialog.MODE_HOTSPOTS = 2;
MapViewerDialog.MODE_TIPTRIGGERS = 3;
MapViewerDialog.MODE_POINTSOFINTEREST = 4;
MapViewerDialog.MODE_HORSESHOES = 5;
MapViewerDialog.MODE_COURSEPLAY = 6;
MapViewerDialog.MODE_CUSTOMOVERLAY = 7;

function MapViewerDialog:new()
	local self = {}
	self = setmetatable(self, MapViewerDialog_mt)
	
	self.mode = 1;
	self.prevMode = 0;
	self.numberOfModes = 6;
	self.dialogIsActive = false;
	
	self.plyname = {};
	self.plyname.name = "";
	
	self.textTable = {};
	
	----
	--	Daten Tables
	----
	self.Player = {};
	self.Map = {};
	self.Vehicle = {};
	self.HorseShoes = {};
	self.TipTrigger = {};
	----
	
	----
	-- Overlays enabled ?
	----
	self.useHorseShoes = false;
	self.useTipTrigger = false;
	self.useDefaultMap = true;
	self.useCoursePlay = false;
	self.usePoI = false;
	self.useCustomOverlay = false;
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
	print(string.format("|| Debug || modeSelectionOnCreate() ||"));
	self.modeSelectionElement = element
	self.modeSelectionElement.wrap = true
	self.textTable = {}
	for i = 1, self.numberOfModes do
		table.insert(self.textTable, g_i18n:getText("MV_Mode" .. tostring(i) .. "Name"))
	end

	--table.show(self.textTable, "Komplettes Table");
	element:setTexts(self.textTable)
	element:setState(1)
end

function MapViewerDialog:modeSelectionOnClick(state)
	print(string.format("|| Debug || modeSelectionOnClick() || mode:%s / state: %s", tostring(self.mode), tostring(state)));
	self.prevMode = self.mode;
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
	-- Alle nicht benötigten Elemente deaktivieren und nur nach Mode bedarf aktivieren
	self.OverlayDesc:setText("");
end

function MapViewerDialog:updateDialog()
	if self.mode == MapViewerDialog.MODE_VEHICLES then
		-- self.OverlayDesc:setText("Fahrzeuge und Attachments");
	end;

	if self.mode == MapViewerDialog.MODE_HOTSPOTS then
		-- self.OverlayDesc:setText("Hotspots und Feldbesitz");
	end;

	if  MapViewerDialog.MODE_TIPTRIGGERS ~= 0 and self.mode == MapViewerDialog.MODE_TIPTRIGGERS then
		-- if not self.useTipTrigger then
			-- self.textTable[MapViewerDialog.MODE_CUSTOMOVERLAY] = "";
			-- MapViewerDialog.MODE_TIPTRIGGERS = 0;
		-- end;
	end;
	
	if MapViewerDialog.MODE_POINTSOFINTEREST ~= 0 and self.mode == MapViewerDialog.MODE_POINTSOFINTEREST then
		-- if not self.usePoI then
			-- self.textTable[MapViewerDialog.MODE_CUSTOMOVERLAY] = "";
			-- MapViewerDialog.MODE_POINTSOFINTEREST = 0;
		-- end;
	end;

	if MapViewerDialog.MODE_HORSESHOES ~= 0 and self.mode == MapViewerDialog.MODE_HORSESHOES then
		-- if not self.useHoreShoes then
			-- self.textTable[MapViewerDialog.MODE_CUSTOMOVERLAY] = "";
			-- MapViewerDialog.MODE_HORSESHOES = 0;
		-- end;
	end;

	if MapViewerDialog.MODE_COURSEPLAY ~= 0 and self.mode == MapViewerDialog.MODE_COURSEPLAY then
		-- if not self.useCoursePlay then
			-- self.textTable[MapViewerDialog.MODE_CUSTOMOVERLAY] = "";
			-- MapViewerDialog.MODE_COURSEPLAY = 0;
		-- end;
	end;

	if MapViewerDialog.MODE_CUSTOMOVERLAY ~= 0 and self.mode == MapViewerDialog.MODE_CUSTOMOVERLAY then
		-- if not self.useCustomOverlay then
			-- self.textTable[MapViewerDialog.MODE_CUSTOMOVERLAY] = "";
			-- MapViewerDialog.MODE_CUSTOMOVERLAY = 0;
		-- end;
	end;
	
	-- for _,t in pairs(self.textTable) do
		-- if t == "" then
			-- table.remove(self.textTable, _);
		-- end;
	-- end;
	--table.show(textTable, "Aufgeräumtes Table");
	
	-- self.modeSelectionElement:setTexts(self.textTable);
	-- self.numberOfModes = table.count(self.textTable);
	-- self.modeSelectionElement:setState(1);
	-- self:updateFocusLinkageSystem();
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
		----
		--	Hufeisen
		----
		if self.mode == MapViewerDialog.MODE_HORSESHOES and self.useHorseShoes then
			self:renderHorseShoes();
		end;
		----
		--	Hotspots und Feldnummern
		----
		if self.mode == MapViewerDialog.MODE_HOTSPOTS then
			self:renderHotspots();
			self:renderFieldnumbers();
		end;
		----
		--	TipTriggers und Feldnummern
		----
		if self.mode == MapViewerDialog.MODE_TIPTRIGGERS and self.useTipTrigger then
			self:renderTipTrigger();
			self:renderFieldnumbers();
		end;
		----
		--	CoursePlay Kurse
		----
		if self.mode == MapViewerDialog.MODE_COURSEPLAY and self.useCoursePlay then
			self:renderCoursePlay();
		end;
		----
	end;
end;
----

----------------------------------
--	Inizialisierung der Daten	--
----------------------------------
-- TODO: Übergabe eines Wertes um ein deaktivieren einzelner Werte zu gewährleisten
----

----
--	Inizialisierung der Daten für die Karte
----
function MapViewerDialog:initMap(_map, isDefaultMap)
	if type(_map) == "table" and table.count(_map) > 0 then
		self.Map = _map;
		-- TODO: Prüfen ob der Dateiname existiert und falls möglich übergebenes Overlay aus Map nutzen
		self:setMapImageFilename(self.Map.file);
		self.useDefaultMap = isDefaultMap;
		return true;
	else
		return false;
	end;
end;
----

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

----
--	Inizialisierung der Daten für die Hufeisen
----
function MapViewerDialog:initHorseShoes(_horseshoes)
	if type(_horseshoes) == "table" and table.count(_horseshoes) > 0 then
		self.HorseShoes = _horseshoes;
		self.useHorseShoes = true;
		return true;
	elseif _horseshoes == nil or table.count(_horseshoes) == 0 or _horseshoes == false then
		self.useHorseShoes = false;
		return false;
	else
		self.useHorseShoes = false;
		return false;
	end;
end;
----

----
--	Inizialisierung der Daten für die tipTrigger
----
function MapViewerDialog:initTipTrigger(_tiptrigger)
	if type(_tiptrigger) == "table" and table.count(_tiptrigger) > 0 then
	print("tippTrigger Daten OK");
		self.TipTrigger = _tiptrigger;
		self.useTipTrigger = true;
		return true;
	elseif _tiptrigger == nil or table.count(_tiptrigger) == 0 or _tiptrigger == false then
		self.useTipTrigger = false;
		print("tippTrigger Daten NOK1");
		return false;
	else
		print("tippTrigger Daten NOK2");
		self.useTipTrigger = false;
		return false;
	end;
end;
----

----------------------------------------------------------
--	Rendern der einzelnen Overlays und weiterer Daten	--
----------------------------------------------------------

----
-- Rendern der tipTrigger
----
function MapViewerDialog:renderTipTrigger()
	-- local t, z;
	local ttX, ttY, ttZ;
	-- local countFruits;
	-- local fillType;
	-- local fruitType;
	
	-- print("renderTipTrigger()");
	
	for k,v in pairs(g_currentMission.tipTriggers) do
		-- ttX, ttY, ttZ = getWorldTranslation(g_currentMission.tipTriggers[k].rootNode)
		-- self.ttPosX = ((((self.Map.mapDimensionX/2)+self.posX)/self.Map.mapDimensionX)*self.Map.width);
		-- self.ttPosZ = ((((self.Map.mapDimensionY/2)-self.posZ)/self.Map.mapDimensionY)*self.Map.height);

		ttX, ttY, ttZ = getWorldTranslation(g_currentMission.tipTriggers[k].rootNode)
		self.ttPosX = ((((self.Map.mapDimensionX/2)+ttX)/self.Map.mapDimensionX)*self.Map.width);
		self.ttPosZ = ((((self.Map.mapDimensionY/2)-ttZ)/self.Map.mapDimensionY)*self.Map.height);
		
		renderOverlay(self.TipTrigger.Icon.OverlayId,
					self.ttPosX-self.TipTrigger.width/2, 
					self.ttPosZ-self.TipTrigger.height/2, 
					self.TipTrigger.width, 
					self.TipTrigger.height);
	end;
end;
----

----
-- Rendern der tipTrigger, integrierten Feldnummern und Feldstatus
----
function MapViewerDialog:renderFieldnumbers()
	if self.mode == MapViewerDialog.MODE_HOTSPOTS or self.mode == MapViewerDialog.MODE_TIPTRIGGERS then
		local hsPosX, hsPosY;
		for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
			self.hsWidth = g_currentMission.missionPDA.hotspots[j].width;
			self.hsHeight = g_currentMission.missionPDA.hotspots[j].height;
			----
			self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;			

			local bc = g_currentMission.missionPDA.hotspots[j].baseColor;
			
			setTextColor(1, 1, 1, 1);
			setTextAlignment(RenderText.ALIGN_CENTER);

			----
			-- Feldnummern ?
			----
			if g_currentMission.missionPDA.hotspots[j].showName then
				if self.Map.quadsize then
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+2048;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+2048;
				else
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+1024;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+1024;
				end;
				
				self.hsPosX = (hsPosX/self.Map.mapDimensionX)-(self.hsWidth/2);
				self.hsPosY = 1-(hsPosY/self.Map.mapDimensionY)-(self.hsHeight/2);

				setTextColor(bc[1], bc[2], bc[3], bc[4]);
				renderOverlay(self.hsOverlayId, self.hsPosX, self.hsPosY, self.hsWidth, self.hsHeight);
				renderText(self.hsPosX, self.hsPosY, 0.032, tostring(g_currentMission.missionPDA.hotspots[j].name));
			end;
		end;
	end;
end;

----
-- Rendern der tipTrigger, integrierten Feldnummern und Feldstatus
----
function MapViewerDialog:renderCoursePlay()
	if self.mode == MapViewerDialog.MODE_CoursePlay and self.useCoursePlay then
		local hsPosX, hsPosY;
		print("Debug: renderCoursePlay()");
		-- for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
			-- self.hsWidth = g_currentMission.missionPDA.hotspots[j].width;
			-- self.hsHeight = g_currentMission.missionPDA.hotspots[j].height;
			--
			-- self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;			

			-- local bc = g_currentMission.missionPDA.hotspots[j].baseColor;
			
			-- setTextColor(1, 1, 1, 1);
			-- setTextAlignment(RenderText.ALIGN_CENTER);

			----
			-- Feldnummern ?
			----
			-- if g_currentMission.missionPDA.hotspots[j].showName then
				-- hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+1024;
				-- hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+1024;
				
				-- self.hsPosX = (hsPosX/self.Map.mapDimensionX)-(self.hsWidth/2);
				-- self.hsPosY = 1-(hsPosY/self.Map.mapDimensionY)-(self.hsHeight/2);

				-- setTextColor(bc[1], bc[2], bc[3], bc[4]);
				-- renderOverlay(self.hsOverlayId, self.hsPosX, self.hsPosY, self.hsWidth, self.hsHeight);
				-- renderText(self.hsPosX, self.hsPosY, 0.032, tostring(g_currentMission.missionPDA.hotspots[j].name));
			-- end;
		-- end;
	end;
end;

----
-- Rendern der Hotspots, integrierten Feldnummern und Feldstatus
----
function MapViewerDialog:renderHotspots()
	-- if self.showHotSpots and self.useHotSpots then
	if self.mode == MapViewerDialog.MODE_HOTSPOTS then
		local hsPosX, hsPosY;
		for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
			self.hsWidth = g_currentMission.missionPDA.hotspots[j].width;
			self.hsHeight = g_currentMission.missionPDA.hotspots[j].height;
			----
			self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;			

			local bc = g_currentMission.missionPDA.hotspots[j].baseColor;
			
			setTextColor(1, 1, 1, 1);
			setTextAlignment(RenderText.ALIGN_CENTER);

			if not g_currentMission.missionPDA.hotspots[j].showName then
				if self.useDefaultMap then 
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+1024;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+1024;
				elseif self.Map.quadsize then
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos;
				else
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos;
				end;
				
				self.hsPosX = (hsPosX/self.Map.mapDimensionX)-(self.hsWidth/2);
				self.hsPosY = 1-(hsPosY/self.Map.mapDimensionY)-(self.hsHeight/2);

				renderOverlay(self.hsOverlayId, self.hsPosX, self.hsPosY, self.hsWidth, self.hsHeight);
				if g_i18n:hasText("MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name) then
					renderText(self.hsPosX+self.hsWidth/2, self.hsPosY-self.hsHeight/2, 0.020, tostring(g_i18n:getText("MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name)));
				else
					renderText(self.hsPosX+self.hsWidth/2, self.hsPosY-self.hsHeight/2, 0.020, tostring(g_currentMission.missionPDA.hotspots[j].name));
				end;
			end;
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(1, 1, 1, 0);

			-- if self.Debug.printHotSpots then
				-- print(string.format("Debug : HS X1 %.2f | HS Y1 %.2f | mapHS X1 %.2f | mapHS Y1 %.2f | name: %s", g_currentMission.missionPDA.hotspots[j].xMapPos, g_currentMission.missionPDA.hotspots[j].yMapPos, self.hsPosX, self.hsPosY, g_currentMission.missionPDA.hotspots[j].name));
			-- end;
		end;
		-- if self.Debug.printHotSpots then
			-- self.Debug.printHotSpots = false;
		-- end;
		-- print("-- Hotspot Loop Ende --");
	end;
end;
----

----
-- Rendern der Hufeisen
----
function MapViewerDialog:renderHorseShoes()
	----
	-- Horseshoes
	----
	local countHorseShoesFound = 0;
	if self.mode == MapViewerDialog.MODE_HORSESHOES and self.useHorseShoes then
		local HShoes = {};
		HShoes = g_currentMission.collectableHorseshoesObject.horseshoes;
		if self.HorseShoes.Icon.OverlayId ~= nil and self.HorseShoes.Icon.OverlayId ~= 0 then
			for i=1, table.getn(HShoes) do
				local bottleFound=string.byte(g_currentMission.missionStats.foundHorseshoes, i);
				if bottleFound==48 then
					self.posX, self.posY, self.posZ=getWorldTranslation(HShoes[i].horseshoeTriggerId);
					self.buttonX = ((((self.Map.mapDimensionX/2)+self.posX)/self.Map.mapDimensionX)*self.Map.width);
					self.buttonZ = ((((self.Map.mapDimensionY/2)-self.posZ)/self.Map.mapDimensionY)*self.Map.height);
					
					renderOverlay(self.HorseShoes.Icon.OverlayId,
								self.buttonX-self.HorseShoes.width/2, 
								self.buttonZ-self.HorseShoes.height/2, 
								self.HorseShoes.width, 
								self.HorseShoes.height);
				else
					countHorseShoesFound = countHorseShoesFound+1;
				end;

				-- if self.Debug.printHorseShoes then
					-- print(string.format("Debug : HS X1 %.2f | HS Y1 %.2f | mapHS X1 %.2f | mapHS Y1 %.2f | Index: %s | Count: %d", self.posX, self.posZ, self.buttonX, self.buttonZ, tostring(i), countHorseShoesFound));
				-- end;
			end;
			-- if self.Debug.printHorseShoes then
				-- self.Debug.printHorseShoes = false;
			-- end;
		else
			print(string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorHorseShoesCreateOverlay")));
			self.useHorseShoes = not self.useHorseShoes;
		end;
		self.OverlayDesc:setText(string.format("%s von %s bereits gesammelt", tostring(countHorseShoesFound), tostring(table.getn(HShoes))));
	end;
	----
end;

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
		elseif g_currentMission.steerables[i].isBroken then
		----
		-- unbrauchbare Fahrzeuge mit weiterem Icon anzeigen
		----
			self.posX, self.posY, self.posZ = getWorldTranslation(g_currentMission.steerables[i].rootNode);
			self.buttonX = ((((self.Map.mapDimensionX/2)+self.posX)/self.Map.mapDimensionX)*self.Map.width);
			self.buttonZ = ((((self.Map.mapDimensionY/2)-self.posZ)/self.Map.mapDimensionY)*self.Map.height);
			if self.Vehicle.broken.Icon.OverlayId ~= nil and self.Vehicle.broken.Icon.OverlayId ~= 0 then
				renderOverlay(self.Vehicle.broken.Icon.OverlayId,
							self.buttonX-self.Vehicle.broken.width/2, 
							self.buttonZ-self.Vehicle.broken.height/2,
							self.Vehicle.broken.width,
							self.Vehicle.broken.height);
				setOverlayColor(self.Vehicle.broken.Icon.OverlayId, 1, 1, 1, 1);
			end;
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