MapViewerDialog = {}
local MapViewerDialog_mt = Class(MapViewerDialog)

function MapViewerDialog:new()
	local self = {}
	self = setmetatable(self, MapViewerDialog_mt)
	
	self.mode = 1;
	self.numberOfModes = 6;
	self.dialogIsActive = false;
	
	----
	--	Daten Tables
	----
	self.Player = {};
	self.Map = {};
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