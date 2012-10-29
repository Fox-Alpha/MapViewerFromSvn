----
-- mein Mapviewer, anzeigen der PDA Map auf dem Bildschirm
----
-- $Rev$:     Revision der letzten Änderung
-- $Author$:  Author der letzten Änderung
-- $Date$:    Date der letzten Änderung
-- $URL$
----
-- Mein Mapviewer, anzeigen der PDA Map auf dem Bildschirm
----
-- myapp = {};
mapviewer={};
mapviewer.moddir=g_currentModDirectory;
mapviewer.modName = g_currentModName;
-- source(mapviewer.moddir.."MapViewerTeleportEvent.lua");


----
-- Globale ToDo's :
----
-- GetNoNil aus den Aufrufen von getText entfernen oder gegen eigene Funktion ersetzten
-- Übersetzungen prüfen
-- Panel position anpassen wenn am Bildschirmrand (Oben und rechts)
-- DONE: Kapazitäten gegen 0 prüfen, Zeile bei 0 ausblenden (Ballentransporthänger, Häcksler)
-- DONE: Panelanzeige auf rootNode testen
-- DONE: Michtruck auf Karte mit anzeigen, eigenes Symbol mit Farbe weiss g_currentMission.trafficVehicles[]   rootNode, ["typeName"] = "milktruck";, 
-- Tastenhilfe
-- Alle renderOverlay() auf gültigkeit Prüfen
-- Alle Spieler auf PDA anzeigen, Position des Spielernamens auf PDA korrigieren
-- Globale Tastenbelegung korriigieren.Zwei m<l InputBinding in Moddesc
----
-- Testen:
----
-- DONE: Client Teleport im MP Modus
-- Bei Fahrzeugen mit fillKapazität und nicht Combine
-- 
----
-- Übersetzungen :
----
-- Selbstfahrspritze ist selfpropeleredsprayer / de fehlt || Filtype fehlt
-- typ Implement, dann Typ=Name, Optional Typ vergleichen (Gewicht, Schild, Ballengabel, Palettengabel)
-- saat in Maschine, Ausgewählte Saat !
-- Miststreuer ist manuresprayder
-- Ladewagen (Gras) ist foragewagon
-- Güllefass ist Sprayer_animated
-- Hecksler und Maisgebiss ist cutter_animated
-- Mähwerk ist mower
-- Ballensammler ist Name=automatic Baleloader, Typ baleLoader
-- Schaufel Name=shovel
-- Palletengabel angehängt ist Implement
-- Type combine_cilyndered
-- cultivator_animated muss grubber
----

----
-- Hauptfunktion zum Laden des Mods
----
function mapviewer:loadMap(name)
	-- print(string.format("|| %s || Starting ... ||", g_i18n:getText("mapviewtxt")));
	local userXMLPath = Utils.getFilename("mapviewer.xml", mapviewer.moddir);
	self.xmlFile = loadXMLFile("xmlFile", userXMLPath);
	
	-- dofile = myapp.import;

	self.mapvieweractive=false;
	self.maplegende = false;
	self.activePlayerNode=0;
	self.mvInit = false;
	self.showFNum = false;
	self.showPoi = false;
    self.showCP = false;
    self.showBottles = false;
    self.showInfoPanel = false;
	self.showHotSpots = false;
    
    self.useBottles = true;
    self.useLegend = true;
	self.useTeleport = false;
	
	self.setNewPlyPosition = false;
    
	self.numOverlay = 0;

	self.mapPath = 0;
	self.useDefaultMap = false;
	self.mapName = "";
    
    self.courseplay = true;
	
	self.printInfo = false;
	
	self.x=0;
	self.y=0;
	self.z=0;
	self.length=0;
	self.dX=0;
	self.dZ=0;
	self.l_PosY = 0;
	self.TEntfernung=0;
	self.TRichtung=0;
	self.playerRotY=0;
	self.plyname = {};
	self.bigmap ={};
	self.mouseX = 0;
	self.mouseY = 0;
	
	self.debug = {};
	self.debug.printHotSpots = false;
	
	
	----
	-- Debug Modus
	----
	self.Debug = false;
	----
	
	self.mv_Error = false;
	
	----
	-- Workaround um in den Steerable den Namen als .name einzubinden
	----
	local aNameSearch = {"vehicle.typeDesc", "vehicle.name." .. g_languageShort, "vehicle.name.en", "vehicle.name", "vehicle#type"};
	
	if Steerable.load ~= nil then
		local orgSteerableLoad = Steerable.load
		
		Steerable.load = function(self,xmlFile)
			orgSteerableLoad(self,xmlFile)
			
			for nIndex,sXMLPath in pairs(aNameSearch) do 
				self.name = getXMLString(xmlFile, sXMLPath);
				if self.name ~= nil then break; end;
			end;
			if self.name == nil then self.name = g_i18n:getText("UNKNOWN") end;
			self.name = Utils.getXMLI18N(xmlFile, "vehicle.typeDesc", "", "TypeDescription"); --, instance.customEnvironment);
			-- print(tostring(self.name));
			-- if g_i18n:hasText(self.name) then
				-- self.name = g_i18n:getText(self.name);
			-- end;
		end;
	end;
	
	if Attachable.load ~= nil then
		local orgAttachableLoad = Attachable.load
		
		Attachable.load = function(self,xmlFile)
			orgAttachableLoad(self,xmlFile)
			
			for nIndex,sXMLPath in pairs(aNameSearch) do 
				self.name = getXMLString(xmlFile, sXMLPath);
				if self.name ~= nil then break; end;
			end;
			if self.name == nil then self.name = g_i18n:getText("UNKNOWN") end;
			-- print(tostring(self.name));
			-- if g_i18n:hasText(self.name) then
				-- self.name = g_i18n:getText(self.name);
			-- end;
			self.name = Utils.getXMLI18N(xmlFile, "vehicle.typeDesc", "", "TypeDescription"); --, instance.customEnvironment);
			-- print(tostring(self.name));
		end
	end;
	----
end;
----

----
-- Grundwerte des Mods setzen
-- Laden und erstellen der Overlays, usw.
----
function mapviewer:InitMapViewer()
    print(string.format("|| %s || Starting ... ||", g_i18n:getText("mapviewtxt")));
    
	----
	-- Initialisierung beginnen
	----
	
	print(string.format("|| %s || Initialising ... ||", g_i18n:getText("mapviewtxt")));
	
	self.bigmap.OverlayId = {};
    self.bigmap.PoI = {};
    self.bigmap.FNum = {};

	-- self.bigmap.mapDimensionX = 2048;
	-- self.bigmap.mapDimensionY = 2048;
	self.bigmap.mapWidth = 1;
	self.bigmap.mapHeight = 1;
	self.bigmap.mapPosX = 0.5-(self.bigmap.mapWidth/2);
	self.bigmap.mapPosY = 0.5-(self.bigmap.mapHeight/2);
	self.bigmap.mapTransp = 1;
	
	--
	-- Wenn keine vorgegebene Datei als Karte verwendet werden soll
	--
	self.mapPath = g_currentMission.missionInfo.map.baseDirectory;

    --
    -- Prüfen ob es sich um die Standard Karte handelt
    --
	self.mapName = g_currentMission.missionInfo.map.title;
	self.mapZipName = self:getModName(g_currentMission.missionInfo.map.baseDirectory);
    if self.mapPath == "" and g_currentMission.missionInfo.map.title == "Karte 1" then
        self.mapPath = getAppBasePath() .. "data/maps/map01/";
        self.useDefaultMap = true;
    else
        self.mapPath = self.mapPath .. "map01/"
    end;
	----


	----
	-- Globale Kartengröße verwnenden
	-----
	-- self.testOverlay = {File= "", OverlayId=0};
	-- package.path = package.path .. ";" ..self.moddir.. "\\?.lua";
	-- self.ImageSize = require ("imagesize");
	----
	-- TODO: getFile() in Imagesize Funktionen testen
	----
	-- local demSizeX, demSizeY, fileType;
	-- self.testOverlay.File = Utils.getFilename("map01_dem.png", self.mapPath);
	-- demSizeX, demSizeY, fileType = self.ImageSize.imgsize(Utils.getFilename("map01_dem.png", self.mapPath));	
	-- print(string.format("demX %s || demY %s || Type %s || Pfad : %s", tostring(demSizeX), tostring(demSizeY), tostring(fileType), tostring(self.testOverlay.File)));
	if g_currentMission.terrainSize ~= 2050 then	
		g_currentMission.missionPDA.worldSizeX = 4096;
		g_currentMission.missionPDA.worldSizeZ = 4096;
		g_currentMission.missionPDA.worldCenterOffsetX = g_currentMission.missionPDA.worldSizeX*0.5;
		g_currentMission.missionPDA.worldCenterOffsetZ = g_currentMission.missionPDA.worldSizeZ*0.5;
	end;
	
	
    self.bigmap.mapDimensionX = g_currentMission.missionPDA.worldSizeX;
    self.bigmap.mapDimensionY = g_currentMission.missionPDA.worldSizeZ;
	
	----
	-- Mapgroesse printen
	----
	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), string.format(g_i18n:getText("MV_InfoMapsize"), self.bigmap.mapDimensionX, self.bigmap.mapDimensionY)));
	----

	-----
    self.bigmap.PoI.width = 1;
    self.bigmap.PoI.height = 1;
    self.bigmap.FNum.width = 1;
    self.bigmap.FNum.height = 1;
	
	
	----
	-- Mapname printen
	----
	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), string.format(g_i18n:getText("MV_MapName"), g_currentMission.missionInfo.map.title)));
	----
	
    ----
	-- Prüfen auf lokale PDA Datei
	----
	local bl, lf = self:checkLocalPDAFile();
	
	if bl and lf ~= nil then
		self.bigmap.file = lf;
	else
		self.bigmap.file = Utils.getNoNil(Utils.getFilename("pda_map.png", self.mapPath), Utils.getFilename("pda_map.dds", self.mapPath));
	end;
    self.bigmap.OverlayId.ovid = createImageOverlay(self.bigmap.file);
	if self.bigmap.OverlayId.ovid == nil or self.bigmap.OverlayId.ovid == 0 then
		print(string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMV")));
	end;
	----

	----
	-- Startwert der Transparenz
	----
	self.bigmap.mapTransp = 1;
	----
	
	if self.Debug then
		print("Debug: ");
		print(string.format("self.useMapFile: %s", tostring(self.useMapFile)));
		print(string.format("self.bigmap.file: %s", self.bigmap.file));
		print(string.format("self.bigmap.OverlayId.ovid: %d", self.bigmap.OverlayId.ovid));
		print("LoadMap()");
		print(string.format("Map Pfad : %s", self.mapPath));

		print(string.format("Overlay  : %d", self.bigmap.OverlayId.ovid));
	end;
		
	----
	-- Point of Interest verwenden
	----
	self.usePoi = true;

    self.bigmap.PoI.OverlayId = nil;
    if self.useDefaultMap then
        self.bigmap.PoI.file = Utils.getFilename("PoI_Karte_1.png", self.moddir .. "gfx/");
    else
         self.bigmap.PoI.file = Utils.getFilename("MV_PoI.png", self.mapPath);
    end
    self.bigmap.PoI.poiPosX = 0.5-(self.bigmap.PoI.width/2);
    self.bigmap.PoI.poiPosY = 0.5-(self.bigmap.PoI.height/2);
	----
	
	----
	-- Fieldnumbers verwenden
	----
	self.useFNum = true;
	if self.useFNum then
		self.bigmap.FNum.OverlayId = nil
		if self.useDefaultMap then
			self.bigmap.FNum.file = Utils.getFilename("fn_Karte_1.png", self.moddir .. "gfx/");
		else
            self.bigmap.FNum.file = Utils.getFilename("MV_Feldnummern.png", self.mapPath);
        end;
		self.bigmap.FNum.FNumPosX = 0.5-(self.bigmap.FNum.width/2);
		self.bigmap.FNum.FNumPosY = 0.5-(self.bigmap.FNum.height/2);
	end;
	----
    
	----
	-- Array für Fahrzeugicons
	----
	self.bigmap.IconSteerable = {};
	self.bigmap.IconSteerable.file = "";
	self.bigmap.IconSteerable.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconSteerable#file"), "icons/tractor.dds"), self.moddir);
	self.bigmap.IconSteerable.filemp = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconSteerableCtrl#file"), "icons/tractorctrl.dds"), self.moddir);
	self.bigmap.IconSteerable.OverlayId = createImageOverlay(self.bigmap.IconSteerable.file);
	self.bigmap.IconSteerable.mpOverlayId = createImageOverlay(self.bigmap.IconSteerable.filemp);
	self.bigmap.IconSteerable.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconSteerable#width"), 0.0078125);
	self.bigmap.IconSteerable.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconSteerable#height"), 0.0078125);
	----

	----
	-- Arrayx für Milchtruck
	----
	self.bigmap.IconMilchtruck = {}; --file, OverlayId, width, height
	self.bigmap.IconMilchtruck.file = "";
	self.bigmap.IconMilchtruck.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.IconMilktruck#file"), "icons/milktruck.dds"), self.moddir);
	self.bigmap.IconMilchtruck.OverlayId = createImageOverlay(self.bigmap.IconMilchtruck.file);
	self.bigmap.IconMilchtruck.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.IconMilchtruck#width"), 0.0078125);
	self.bigmap.IconMilchtruck.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.IconMilchtruck#height"), 0.0078125);
	----
    
	--Array für Geräteicons
	self.bigmap.IconAttachments = {};
	self.bigmap.IconAttachments.Icon = {front = {file = "", OverlayId = nil},rear={file = "", OverlayId = nil}};
	self.bigmap.IconAttachments.Icon.front.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachmentFront#file"), "icons/feldgeraet.dds"), self.moddir);
	self.bigmap.IconAttachments.Icon.rear.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachmentRear#file"), "icons/feldgeraet.dds"), self.moddir);
	self.bigmap.IconAttachments.Icon.front.OverlayId = createImageOverlay(self.bigmap.IconAttachments.Icon.front.file);
	self.bigmap.IconAttachments.Icon.rear.OverlayId = createImageOverlay(self.bigmap.IconAttachments.Icon.rear.file);
	self.bigmap.IconAttachments.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconAttachmentFront#width"), 0.0078125);
	self.bigmap.IconAttachments.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconAttachmentFront#height"), 0.0078125);
	----
    
	--Array für Infopanel
	self.bigmap.InfoPanel = {};
	self.bigmap.InfoPanel.top = {};
	self.bigmap.InfoPanel.top = {file = "", OverlayId = nil, width = 0.15, height= 0.0078125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.top.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelTop#file"), "panel/Info_Panel_top.dds"), self.moddir);
	self.bigmap.InfoPanel.top.OverlayId = createImageOverlay(self.bigmap.InfoPanel.top.file);
	self.bigmap.InfoPanel.background = {};
	self.bigmap.InfoPanel.background = {file = "", OverlayId = nil, width = 0.15, height= 0.125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.background.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBackground#file"), "panel/Info_Panel_bg.dds"), self.moddir);
	self.bigmap.InfoPanel.background.OverlayId = createImageOverlay(self.bigmap.InfoPanel.background.file);
	self.bigmap.InfoPanel.bottom = {};
	self.bigmap.InfoPanel.bottom = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.bottom.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBottom#file"), "panel/Info_Panel_bt.dds"), self.moddir);
	self.bigmap.InfoPanel.bottom.OverlayId = createImageOverlay(self.bigmap.InfoPanel.bottom.file);
	-- Informationen die angezeigt werden
	self.bigmap.InfoPanel.Info = {Type = "", Ply= "", Tank = 0, Fruit = ""};
	self.bigmap.InfoPanel.vehicleIndex = 0;
	self.bigmap.InfoPanel.isVehicle = false;
	self.bigmap.InfoPanel.lastVehicle = {};
	
	-- Buttons im Panel
	-- self.bigmap.InfoPanel.buttons =	{};
	-- self.bigmap.InfoPanel.buttons =	{switch = {file = "", OverlayId = nil}, close = {file = "", OverlayId = nil}};
		-- Switch Button
		-- self.bigmap.InfoPanel.buttons.switch.file =	Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.InfoPanesl.Buttons.ButtonSwitch#file"), ".png"), self.moddir);
		-- self.bigmap.InfoPanel.buttons.switch.OverlayID = createImageOverlay(self.bigmap.InfoPanel.buttons.switch.file);
		-- self.bigmap.InfoPanel.buttons.switch.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.InfoPanesl.Buttons.ButtonSwitch#width"), 0.0078125);
		-- self.bigmap.InfoPanel.buttons.switch.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.InfoPanesl.Buttons.ButtonSwitch#height"), 0.0078125);
		-- self.bigmap.InfoPanel.buttons.switch.x = 0;
		-- self.bigmap.InfoPanel.buttons.switch.y = 0;
		--
		-- Close Button
		-- self.bigmap.InfoPanel.buttons.close.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.InfoPanesl.Buttons.ButtonClose#file"), ".png"), self.moddir);	
		-- self.bigmap.InfoPanel.buttons.close.OverlayID =	createImageOverlay(self.bigmap.InfoPanel.buttons.close.file);
		-- self.bigmap.InfoPanel.buttons.close.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.InfoPanesl.Buttons.ButtonClose#width"), 0.0078125);
		-- self.bigmap.InfoPanel.buttons.close.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.InfoPanesl.Buttons.ButtonClose#height"), 0.0078125);
		-- self.bigmap.InfoPanel.buttons.close.x = 0;
		-- self.bigmap.InfoPanel.buttons.close.y = 0;
		----
	-- Ende Infopanel Buttons
	----
	
    ----
    -- Tabelle für Typen
    ----
    self.bigmap.vehicleTypes = {};
    self.bigmap.vehicleTypes.names = {"tractor", "combine", "other"};
    self.bigmap.vehicleTypes.icons = {}
    for at=1, table.getn(self.bigmap.vehicleTypes.names) do
        table.insert(self.bigmap.vehicleTypes.icons, getXMLString(self.xmlFile, "mapviewer.map.icons.iconSteerable" .. self.bigmap.vehicleTypes.names[at] .."#file"));
    end;
    self.bigmap.vehicleTypes.width = 0.01;
    self.bigmap.vehicleTypes.height = 0.01;
    
    self.bigmap.attachmentsTypes = {};
    self.bigmap.attachmentsTypes.names = {"cutter", "trailer", "sowingMachine", "plough", "sprayer", "baler", "baleLoader", "cultivator", "tedder", "windrower", "shovel", "mower", "cultivator_animated", "selfPropelledSprayer", "cutter_animated", "sprayer_animated", "manureSpreader", "forageWagon", "other"};
    self.bigmap.attachmentsTypes.icons = {}
    self.bigmap.attachmentsTypes.overlays = {}
    
    for at=1, table.getn(self.bigmap.attachmentsTypes.names) do
        local tempIcon = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachment" .. self.bigmap.attachmentsTypes.names[at] .."#file"), "icons/feldgeraet.dds"), self.moddir);
        table.insert(self.bigmap.attachmentsTypes.icons,tempIcon); 
        --getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachment" .. self.bigmap.attachmentsTypes.names[at] .."#file"));
        self.bigmap.attachmentsTypes.overlays[self.bigmap.attachmentsTypes.names[at]] = createImageOverlay(self.bigmap.attachmentsTypes.icons[at]);
    end;
    self.bigmap.attachmentsTypes.width = 0.01;
    self.bigmap.attachmentsTypes.height = 0.01;
    ----

	--Array für CourseplayIcon
	self.bigmap.IconCourseplay = {};
	self.bigmap.IconCourseplay.Icon = {};
    self.bigmap.IconCourseplay.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#file"), "icons/courseplay.dds"), self.moddir);
	self.bigmap.IconCourseplay.Icon.OverlayId = createImageOverlay(self.bigmap.IconCourseplay.Icon.file);
	self.bigmap.IconCourseplay.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#width"), 0.0078125);
	self.bigmap.IconCourseplay.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#height"), 0.0078125);
	----

	--Array für isBrokenIcon
	self.bigmap.iconIsBroken = {};
	self.bigmap.iconIsBroken.Icon = {};
    self.bigmap.iconIsBroken.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconIsBroken#file"), "icons/IsBroken.dds"), self.moddir);
	self.bigmap.iconIsBroken.Icon.OverlayId = createImageOverlay(self.bigmap.iconIsBroken.Icon.file);
	self.bigmap.iconIsBroken.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#width"), 0.0078125);
	self.bigmap.iconIsBroken.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#height"), 0.0078125);
	----

	--Array für Bottle anzeige
    self.useBottles = true;
	self.bigmap.iconBottle = {};
	self.bigmap.iconBottle.Icon = {};
    self.bigmap.iconBottle.Icon.OverlayId = nil;
    self.bigmap.iconBottle.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconBottle#file"), "icons/Bottle.dds"), self.moddir);
	self.bigmap.iconBottle.Icon.OverlayId = createImageOverlay(self.bigmap.iconBottle.Icon.file);
    if self.bigmap.iconBottle.Icon.OverlayId == nil or self.bigmap.iconBottle.Icon.OverlayId == 0 then
        self.useBottles = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitBottles")));
    end;
	self.bigmap.iconBottle.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconBottle#width"), 0.0078125);
	self.bigmap.iconBottle.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconBottle#height"), 0.0156250);
	----
    
	--Array für Spielerinfos
	self.bigmap.player = {}; --
	self.bigmap.player.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconPlayer#file"), "icons/eigenerspieler.dds"), self.moddir);
	self.bigmap.player.filemp = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconMPPlayer#file"), "icons/mpspieler.dds"), self.moddir);
	self.bigmap.player.ArrowOverlayId = createImageOverlay(self.bigmap.player.file);
	self.bigmap.player.mpArrowOverlayId = createImageOverlay(self.bigmap.player.filemp);
	self.bigmap.player.name = ""; 
	self.bigmap.player.xPos	= 0;
	self.bigmap.player.xPosPDA	= g_currentMission.missionPDA.pdaMapPosX;
	self.bigmap.player.yPos = 0;
	self.bigmap.player.yPosPDA = g_currentMission.missionPDA.pdaMapPosX;	
	self.bigmap.player.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconPlayer#width"), 0.0078125);
	self.bigmap.player.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconPlayer#height"), 0.0078125);
	----

	----
	-- Map Legende
	----
	self.bigmap.Legende = {};
	self.bigmap.Legende.OverlayId = nil
	self.bigmap.Legende.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.legende#file"), "gfx/background.dds"), self.moddir);
	self.bigmap.Legende.OverlayId = createImageOverlay(self.bigmap.Legende.file);
    if self.bigmap.Legende.OverlayId == nil or self.bigmap.Legende.OverlayId == 0 then
        self.useLegend = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitLegend")));
    end;
	self.bigmap.Legende.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#width"), 0.15);
	self.bigmap.Legende.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#height"), 0.125);
	self.bigmap.Legende.legPosX = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#posX"), 0.0244);
	self.bigmap.Legende.legPosY = 1-Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#posY"), 0.15);
	self.bigmap.Legende.Content = {};
		----
		-- Text und Icon in Content einfügen
		----
		local _lx, _ly, _tx, _ty;
		_tx = self.bigmap.Legende.legPosX + 0.029297;
		-- _lx = _tx + 0.007324;
		_lx = self.bigmap.Legende.legPosX + 0.007324;
		_ly = 1-0.02441 - 0.007324 - 0.015625;
		_ty = _ly;
		--self.bigmap.Legende.Content, {l_PosX, l_PosY, OverlayID, l_Txt, Txt, TxtSize}
		--Eigener Spieler Icon
		table.insert(self.bigmap.Legende.Content, {l_PosX = _lx, l_PosY = _ly, 		 OverlayID = createImageOverlay(self.bigmap.player.file), l_Txt = _tx, Txt = g_i18n:getText("MV_LegendeLocalPlayer"), TxtSize = 0.016});
		--Andere Spieler Icon
		table.insert(self.bigmap.Legende.Content, {l_PosX = _lx, l_PosY = _ly - 0.020, OverlayID = createImageOverlay(self.bigmap.player.filemp), l_Txt = _tx, Txt = g_i18n:getText("MV_LegendeOtherPlayer"), TxtSize = 0.016});
		--Spieler auf Fahrzeug
		table.insert(self.bigmap.Legende.Content, {l_PosX = _lx, l_PosY = _ly - 0.040, OverlayID = createImageOverlay(self.bigmap.IconSteerable.filemp), l_Txt = _tx, Txt = g_i18n:getText("MV_LegendeControledVehicle"), TxtSize = 0.016});
		--Leere Fahrzeug
		table.insert(self.bigmap.Legende.Content, {l_PosX = _lx, l_PosY = _ly - 0.060, OverlayID = createImageOverlay(self.bigmap.IconSteerable.file), l_Txt = _tx, Txt = g_i18n:getText("MV_LegendeEmptyVehicle"), TxtSize = 0.016});
		--Anbaugeräte, Anhänger
		table.insert(self.bigmap.Legende.Content, {l_PosX = _lx, l_PosY = _ly - 0.080, OverlayID = createImageOverlay(self.bigmap.IconAttachments.Icon.front.file), l_Txt = _tx, Txt = g_i18n:getText("MV_LegendeAttachments"), TxtSize = 0.016});
		----	
	----

    ----
	-- Nur Laden und speichern, wenn Singleplayer oder nicht client im Multiplayer
	-- print("Nur Laden und speichern, wenn Singleplayer oder nicht client im Multiplayer");
	----
	-- print("isClient : " .. tostring(g_currentMission.missionDynamicInfo.isClient));
	-- print("isMultiplayer : " .. tostring(g_currentMission.missionDynamicInfo.isMultiplayer));
	-- print("getIsServer() : " .. tostring(g_currentMission:getIsServer()));
	----
	-- if g_currentMission:getIsServer() then
		-- print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_LoadOptions")));
		-- local path = getUserProfileAppPath() .. "savegame" .. g_careerScreen.selectedIndex .. "/mapviewer.xml";

		-- if mapviewer:file_exists(path) then
			-- mapviewer:LoadFromFile();
		-- else
			-- mapviewer:SaveToFile();
		-- end;
		-- print(string.format("|| %s || %s complete ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_LoadOptions")));
	-- end;
	----
	
	----
	-- Checken ob es lokale Fnum und Poi Dateien gibt
	----
	-- Lokale PoI Datei
	----
	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_CheckForLocaleOverlay")));
	local bpoi, lfpoi;
	bpoi, lfpoi = self:checkLocalPoIFile();
	if bpoi and lfpoi ~= nil then
        self.bigmap.PoI.file = lfpoi;
    end
	
    self.bigmap.PoI.OverlayId = createImageOverlay(self.bigmap.PoI.file);
    if self.bigmap.PoI.OverlayId == nil or self.bigmap.PoI.OverlayId == 0 then
        self.usePoi = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitPoI")));
	else
		self.usePoi = true;
    end;
	
	if self.usePoi then
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_MapPoISuccess")));
	end;
	----
	-- Lokale Fnum Datei
	----
	local bfnum, lfnum;
	bfnum, lfnum = self:checkLocalFnumFile();
	if bfnum and lfnum ~= nil then
		self.bigmap.FNum.file = lfnum;
	end;
	
	self.bigmap.FNum.OverlayId = createImageOverlay(self.bigmap.FNum.file);
	if self.bigmap.FNum.OverlayId == nil or self.bigmap.FNum.OverlayId == 0 then
		self.useFNum = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitFNum")));
	else
		self.useFNum = true;
	end;

	if self.useFNum then
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_MapFNumSuccess")));
	end;
	
	print(string.format("|| %s || %s complete ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_CheckForLocaleOverlay")));
	----
	
	----
	-- Hotspots printen
	----
	-- print(table.show(g_currentMission.missionPDA.hotspots, "Hotspots"));
	----
	
	----
	-- Initialisierung abgeschlossen
	print(string.format("|| %s || Initializing Complete ||", g_i18n:getText("mapviewtxt")));
	----

	self.mvInit = true;
end;
----

----
-- Namen der Datei eines Mods ermitteln
-- Ermittelt aus dem Pfad den Namen ohne Dateiendung
----
function mapviewer:getModName(s)
	local temp;
	local PathToModDir;
	
	PathToModDir = string.gsub(self.moddir, self.modName.."/", "");

	s = string.gsub(s, PathToModDir, "");
	s = string.gsub(s, "/", "");
	temp = s;
	
	return temp;
end;
----

----
-- Prüfen ob lokale Dateien für PDA, Poi und Feldnummern vorhanden sind
----
function mapviewer:checkLocalPDAFile()
	local fileName;
	local temp;
	local isLocal = false;
	local PathToModDir;
	local mapName;
	
	fileName = "mv_pda_";
	PathToModDir = string.gsub(self.moddir, self.modName.."/", "");

	if g_currentMission.missionInfo.map.baseDirectory == "" then	--Standard Karte
		temp = string.gsub(g_currentMission.missionInfo.map.title, " ", "_");
	else	-- Name der Map zip
		-- mapName = string.gsub(g_currentMission.missionInfo.map.baseDirectory, PathToModDir, "");
		-- mapName = string.gsub(mapName, "/", "");
		temp = self:getModName(g_currentMission.missionInfo.map.baseDirectory);
	end;
	fileName = fileName .. temp;
	fileName = string.lower(fileName);
	
	-- if self:file_exists(PathToModDir..fileName..".png") then
		fileName = PathToModDir..fileName..".png";
		isLocal = true;
	-- elseif self:file_exists(PathToModDir..fileName..".dds") then
		-- fileName = PathToModDir..fileName..".dds";
		-- isLocal = true;
	-- else
		-- fileName = nil;
	-- end; 

	return isLocal, fileName or nil;
end;
----
function mapviewer:checkLocalFnumFile()
	local fileName;
	local temp;
	local isLocal = false;
	local PathToModDir;
	local mapName;
	
	fileName = "mv_fnum_";
	PathToModDir = string.gsub(self.moddir, self.modName.."/", "");

	if g_currentMission.missionInfo.map.baseDirectory == "" then	--Standard Karte
		temp = string.gsub(g_currentMission.missionInfo.map.title, " ", "_");
	else	-- Name der Map zip
		-- mapName = string.gsub(g_currentMission.missionInfo.map.baseDirectory, PathToModDir, "");
		-- mapName = string.gsub(mapName, "/", "");
		-- temp = mapName;
		temp = self:getModName(g_currentMission.missionInfo.map.baseDirectory);
	end;
	fileName = fileName .. temp;
	fileName = string.lower(fileName);
	
	-- if self:file_exists(PathToModDir..fileName..".png") then
		fileName = PathToModDir..fileName..".png";
		isLocal = true;
	-- elseif self:file_exists(PathToModDir..fileName..".dds") then
		-- fileName = PathToModDir..fileName..".dds";
		-- isLocal = true;
	-- else
		-- fileName = nil;
	-- end; 

	return isLocal, fileName or nil;
end;
----
function mapviewer:checkLocalPoIFile()
	local fileName;
	local temp;
	local isLocal = false;
	local PathToModDir;
	local mapName;
	
	fileName = "mv_poi_";
	PathToModDir = string.gsub(self.moddir, self.modName.."/", "");

	if g_currentMission.missionInfo.map.baseDirectory == "" then	--Standard Karte
		temp = string.gsub(g_currentMission.missionInfo.map.title, " ", "_");
	else	-- Name der Map zip
		-- mapName = string.gsub(g_currentMission.missionInfo.map.baseDirectory, PathToModDir, "");
		-- mapName = string.gsub(mapName, "/", "");
		-- temp = mapName;
		temp = self:getModName(g_currentMission.missionInfo.map.baseDirectory);
	end;
	fileName = fileName .. temp;
	fileName = string.lower(fileName);
	
	-- if self:file_exists(PathToModDir..fileName..".png") then
		fileName = PathToModDir..fileName..".png";
		isLocal = true;
	-- elseif self:file_exists(PathToModDir..fileName..".dds") then
		-- fileName = PathToModDir..fileName..".dds";
		-- isLocal = true;
	-- else
		-- fileName = nil;
	-- end; 

	return isLocal, fileName or nil;
end;
----

----
-- Speichern der Einstellungen im Savegame Ordner
----
function mapviewer:SaveToFile(mv_old)
    local path = getUserProfileAppPath() .. "savegame" .. g_careerScreen.selectedIndex .. "/";
    local mvxml = nil;

	return;	
end;

function mapviewer:oldSaveToFile(mv_old)
    if not mapviewer:file_exists(path .. "MapViewer.xml") or mv_old then
        -- XML Datei im Savegame Ordner erstellen
        mvxml = createXMLFile("MapViewerXML", path .. "MapViewer.xml", "MapViewer");
    else
        mvxml = loadXMLFile("MapViewerXML", path .. "MapViewer.xml"); 
    end;
    
    -- Einstellungen in XML speichern
    if mvxml ~= nil then
        -- int
        setXMLInt(mvxml, "mapviewer.map.mapSize#DimX", self.bigmap.mapDimensionX);
        setXMLInt(mvxml, "mapviewer.map.mapSize#DimY", self.bigmap.mapDimensionY);
        
        setXMLInt(mvxml, "mapviewer.overlay#Index", self.numOverlay);
        -- Float
        setXMLFloat(mvxml, "mapviewer.map#transparenz", self.bigmap.mapTransp);
        -- string
		setXMLString(mvxml, "mapviewer#ver", "v0.60");
		setXMLString(mvxml, "mapviewer#mapName", self.mapZipName);
        -- bool
        setXMLBool(mvxml, "mapviewer.map.default#use", self.useDefaultMap);
        
        setXMLBool(mvxml, "mapviewer.overlay.legende#use", self.useLegend);
        setXMLBool(mvxml, "mapviewer.overlay.legende#show", self.maplegende);
        
        setXMLBool(mvxml, "mapviewer.overlay.fnum#use", self.useFNum);
        setXMLBool(mvxml, "mapviewer.overlay.fnum#show", self.showFNum);

        setXMLBool(mvxml, "mapviewer.overlay.poi#use", self.usePoi);
        setXMLBool(mvxml, "mapviewer.overlay.poi#show", self.showPoi);

        setXMLBool(mvxml, "mapviewer.overlay.bottles#use", self.useBottles);
        setXMLBool(mvxml, "mapviewer.overlay.bottles#show", self.showBottles);

        -- self.courseplay = true;
        setXMLBool(mvxml, "mapviewer.overlay.courseplay#show", self.showCP);

        setXMLBool(mvxml, "mapviewer.debug#use", self.Debug);
        
        saveXMLFile(mvxml);
   else
        print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorSaveOptions"));
    end;    
end;
----

----
-- Laden der gespeicherten Einstellungen
----
function mapviewer:LoadFromFile()
    local path = getUserProfileAppPath() .. "savegame" .. g_careerScreen.selectedIndex .. "/";
    local mvxml = nil; 
	local mv_ver = "v0.60"
	
	return;
end;
function mapviewer:oldLoadFromFile()
    mvxml = loadXMLFile("MapViewerXML", path .. "MapViewer.xml"); 
    
    if mvxml ~= nil then
		----
		-- ToDo: Auslesen der MV Version und Vergleichen
		-- Bei alten Versionen mit neuester ersetzen
		----
		if Utils.getNoNil(getXMLString(mvxml, "mapviewer#ver"), "MV_OLD") == mv_ver and getXMLString(mvxml, "mapviewer#mapName") ~= nil and getXMLString(mvxml, "mapviewer#mapName") == self.mapZipName then
		----
			-- int
			-- self.bigmap.mapDimensionX = getXMLInt(mvxml, "mapviewer.map.mapSize#DimX");
			-- self.bigmap.mapDimensionY = getXMLInt(mvxml, "mapviewer.map.mapSize#DimY");
			
			self.numOverlay = getXMLInt(mvxml, "mapviewer.overlay#Index");
			-- Float
			self.bigmap.mapTransp = getXMLFloat(mvxml, "mapviewer.map#transparenz");
			-- string
			-- bool
			self.useDefaultMap = getXMLBool(mvxml, "mapviewer.map.default#use");
			
			self.useLegend = getXMLBool(mvxml, "mapviewer.overlay.legende#use");
			self.maplegende = getXMLBool(mvxml, "mapviewer.overlay.legende#show");
			
			self.useFNum = getXMLBool(mvxml, "mapviewer.overlay.fnum#use");
			self.showFNum = getXMLBool(mvxml, "mapviewer.overlay.fnum#show");

			self.usePoi = getXMLBool(mvxml, "mapviewer.overlay.poi#use");
			self.showPoi = getXMLBool(mvxml, "mapviewer.overlay.poi#show");

			self.useBottles = getXMLBool(mvxml, "mapviewer.overlay.bottles#use");
			self.showBottles = getXMLBool(mvxml, "mapviewer.overlay.bottles#show");

			-- self.courseplay = true;
			self.showCP = getXMLBool(mvxml, "mapviewer.overlay.courseplay#show");

			self.Debug = getXMLBool(mvxml, "mapviewer.debug#use");
			
			saveXMLFile(mvxml);
		else
			self:SaveToFile(true);
			print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorLoadOptionsOldXML"));
		end;
    else
        print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorLoadOptions"));
    end;
end;
----

----
--
----
function mapviewer:deleteMap()
end;
----

----
-- Auf Tastendruck reagieren
----
function mapviewer:keyEvent(unicode, sym, modifier, isDown)
    ----
	-- Taste um den Debugmodus zu aktivieren
	-- ALT+d
    ----
	if isDown and sym == Input.KEY_d and bitAND(modifier, Input.MOD_ALT) > 0  then
		-- print("---- MapViwer Debug aktiviert ----");
		-- print(table.show(g_currentMission,  "g_CurrentMission"));
		self.debug.printHotSpots = true;
	end;
	----
	
	----
	-- Tasten Modofizierer für Teleport
	----
	-- if isDown and bitAND(modifier, Input.MOD_ALT) > 0  then
	-- if bitAND(modifier, Input.MOD_ALT) > 0 then 
		-- print("---- ALT Taste ist gedrückt ----");
		-- self.useTeleport= not self.useTeleport;
	-- else
	    -- self.useTeleport = false;
	-- end;
    ----
end;
----

----
-- Auf Mausevents reagieren
----
function mapviewer:mouseEvent(posX, posY, isDown, isUp, button)
	--Infopanel an Mousepos anzeigen
	local vehicle;
	local panelX, panelY, panelZ;
	if self.mapvieweractive and self.bigmap.mapTransp >= 1.0 then
		if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_LEFT) and not Input.isMouseButtonPressed(Input.MOUSE_BUTTON_RIGHT) then
			self.mouseX = posX;
			self.mouseY = posY;
			
			self.bigmap.InfoPanel.lastVehicle = nil;
			self.bigmap.InfoPanel.Info = nil;
			self.bigmap.InfoPanel.vehicleIndex = nil;
			self.bigmap.InfoPanel.isVehicle = nil;
			
			if not self.useTeleport then
				self.bigmap.InfoPanel.vehicleIndex, self.bigmap.InfoPanel.isVehicle, self.bigmap.InfoPanel.lastVehicle = self:vehicleInMouseRange();
				-- print(self:vehicleInMouseRange());
				if self.bigmap.InfoPanel.lastVehicle ~= nil and type(self.bigmap.InfoPanel.lastVehicle) == "table" and self.bigmap.InfoPanel.vehicleIndex > 0 then
					-- print(string.format("vehicleInMouseRange() - Fahrzeug in der Nähe : %d / isVehicle : %s", self.bigmap.InfoPanel.vehicleIndex, tostring(self.bigmap.InfoPanel.isVehicle), tostring(self.bigmap.InfoPanel.lastVehicle.name)));
					self.showInfoPanel = true;
					panelX, panelY, panelZ = getWorldTranslation(self.bigmap.InfoPanel.lastVehicle.rootNode);
					self.bigmap.InfoPanel.background.Pos.x = posX-0.0078125-0.0078125;
					self.bigmap.InfoPanel.background.Pos.y = posY;
					-- print(string.format("VehiclePos : %.3f, %.3f, %.3f || Node : %d ", panelX, panelY, panelZ, self.bigmap.InfoPanel.lastVehicle.rootNode));
					self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle);
					-- print(table.show(self.bigmap.InfoPanel.Info, "vehicleInfo."));
					-- print(table.show(self.bigmap.InfoPanel.lastVehicle, "vehicle."));
					-- print("mouseEvent() - showPanel = " .. tostring(self.showInfoPanel));
				else
					self.showInfoPanel = false;
					-- print("mouseEvent() - showPanel = " .. tostring(self.showInfoPanel));
				end;
			else
				----
				-- Teleportieren
				----
				local tpX, tpY, tpZ;
				
				-- print("isClient : " .. tostring(g_currentMission.missionDynamicInfo.isClient));
				-- print("isMultiplayer : " .. tostring(g_currentMission.missionDynamicInfo.isMultiplayer));
				-- print("getIsServer() : " .. tostring(g_currentMission:getIsServer()));

				tpX = self.mouseX/self.bigmap.mapWidth*self.bigmap.mapDimensionX-(self.bigmap.mapDimensionX/2);
				tpZ = -self.mouseY/self.bigmap.mapHeight*self.bigmap.mapDimensionY+(self.bigmap.mapDimensionY/2);
				tpY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tpX, 0, tpZ) + 10;
				if g_currentMission.player.isControlled then
					if g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission:getIsServer() then
						-- print("ServerMessage an alle Senden. Multiplayer = JA und Spieler ist Server");
						g_server:broadcastEvent(PlayerTeleportEvent:new(tpX, tpY, tpZ), nil, nil, self);
					-- elseif isMultiplayer and g_currentMission.missionDynamicInfo.isClient ~= nil and g_currentMission.missionDynamicInfo.isClient then
					elseif g_currentMission.missionDynamicInfo.isMultiplayer and not g_currentMission:getIsServer() then
						-- print("ServerMessage an Server Senden. Multiplayer = JA und Spieler ist Client");	
						g_client:getServerConnection():sendEvent(PlayerTeleportEvent:new(tpX, tpY, tpZ));
					end;
					-- else
						-- print("keine ServerMessage Senden. Multiplayer = NEIN und Locales Spiel");
						setTranslation(g_currentMission.player.rootNode, tpX, tpY, tpZ);
					-- end;
				end;
				----
			end;
		end;
		if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_RIGHT) and not Input.isMouseButtonPressed(Input.MOUSE_BUTTON_LEFT) then
			self.showInfoPanel = false;
		end;
	end;
	----
end;
----

----
-- Fahrzeug in der Nähe des Mausklicks finden
----
function mapviewer:vehicleInMouseRange()

	local oldIndex = nil;
	local index = nil;
	local nearestDistance = 0.005;
	local isVehicle = true;
	local currV = nil;
	local tmpDistance = 0.006;
	local distance = 0.006;
	local sDistance = 0.006
	local aDistance = 0.006;
	local vDistance = 0.006;

	-- print("--vehicleInMouseRange()--");
	-- print("--Steerables--");
	for j=1, table.getn(g_currentMission.steerables) do

		local currS = g_currentMission.steerables[j];
		local posX1, posY1, posZ1 = getWorldTranslation(currS.rootNode);
		local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth); -- +self.bigmap.mapPosX;
		local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight); -- +self.bigmap.mapPosY;
		tmpDistance = Utils.vector2Length(self.mouseX-distancePosX, self.mouseY-distancePosZ);
		-- print(string.format("VehiclePos : %.3f, %.3f, %.3f || X-Y auf Karte : %.3f, %.3f || Maus X-Y : %.3f, %.3f || Distanz: %.3f || Node: %d || Index : %d", 
										-- posX1, posY1, posZ1, distancePosX, distancePosZ, self.mouseX, self.mouseY, tmpDistance, currS.rootNode, j));

		if tmpDistance < nearestDistance then
			sDistance = tmpDistance;
			if sDistance < distance then 
				distance = sDistance;
				index = j;
				isVehicle = true;
				currV = currS;
			end;
		end;
		-- print(string.format("Distanzen : %.3f, %.3f, %.3f ", tmpDistance, sDistance, distance));
	end;
	
	tmpDistance = 0.006;
	aDistance = 0.006;
	vDistance = 0.006;
	--Attachables
	-- print("--Attachables--");
	for a=1, table.getn(g_currentMission.attachables) do
		if g_currentMission.attachables[a].attacherVehicle == nil or g_currentMission.attachables[a].attacherVehicle == 0 then
			local currA = g_currentMission.attachables[a];
			local posX1, posY1, posZ1 = getWorldTranslation(currA.rootNode);
			local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth); -- +self.bigmap.mapPosX;
			local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight); -- +self.bigmap.mapPosY;
			tmpDistance = Utils.vector2Length(self.mouseX-distancePosX, self.mouseY-distancePosZ);
			-- print(string.format("VehiclePos : %.3f, %.3f, %.3f || X-Y auf Karte : %.3f, %.3f || Maus X-Y : %.3f, %.3f || Distanz: %.3f || Node: %d || Index : %d", 
											-- posX1, posY1, posZ1, distancePosX, distancePosZ, self.mouseX, self.mouseY, tmpDistance, currA.rootNode, a));

			if tmpDistance < nearestDistance then
				aDistance = tmpDistance;
				if aDistance < distance then 
					distance = aDistance;
					index = a;
					isVehicle = false;
					currV = currA;
				end;
			end;
			-- print(string.format("Distanzen : %.3f, %.3f, %.3f ", tmpDistance, aDistance, distance));
		end;
	end;
	-- print("--vehicleInMouseRange()--");
	-- print("vehicleInMouseRange() - showPanel = " .. tostring(self.showInfoPanel));
	-- print("vehicleInMouseRange() - index = " .. tostring(index));
	-- print("vehicleInMouseRange() - isVehicle = " .. tostring(isVehicle));
	-- print("vehicleInMouseRange() - showPanel = " .. tostring(currV ~= nil));
	-- print("--ENDE--");
	return index, isVehicle, currV;	
end;
----

----
-- Ermitteln ob Attachments vorhanden sind
----
function getVehicleAttachmentsFruitTypes(object)
	local fruits = {};
	local Attaches = {}; --name, fillLevel, fillType, capacity, fillName
	local FruitNames;
	local oImplements = {};
	local o, f, c;
	
	if table.getn(object.attachedImplements) > 0 then
		for a=1, table.getn(object.attachedImplements) do
			table.insert(oImplements, object.attachedImplements[a].object);
		end;
		for z=1, table.getn(oImplements) do
			getImplements(oImplements[z], oImplements);
		end;

		for a=1, table.getn(oImplements) do
			if SpecializationUtil.hasSpecialization(Fillable, oImplements[a].specializations) then
				if oImplements[a].fillLevel ~= nil then
					if g_i18n:hasText(Fillable.fillTypeIntToName[oImplements[a].currentFillType]) then	
						o = Utils.getNoNil(g_i18n:getText(Fillable.fillTypeIntToName[oImplements[a].currentFillType]), g_i18n:getText("MV_Unknown"));
					else
						o = Utils.getNoNil(Fillable.fillTypeIntToName[oImplements[a].currentFillType], g_i18n:getText("MV_Unknown"));
					end;
					--name, fillLevel, fillType, capacity, fillName
					table.insert(Attaches, {Name=oImplements[a].name, fillLevel=oImplements[a].fillLevel, capacity=oImplements[a].capacity, FillType=oImplements[a].currentFillType, fillName=o});
				end;
			else
			----
			-- Alle nicht befüllbaren Implements
			----
			table.insert(Attaches, {Name=oImplements[a].name, fillLevel=nil, capacity=nil, FillType=nil, fillName=nil});
			----
			end;
		end;
		
		for i=1, table.getn(Attaches) do
			if table.getn(fruits) > 0 then
				for y=1, table.getn(fruits) do
					if fruits[y] == Attaches[i].fillName then 
						break;
					else
						table.insert(fruits, Attaches[i].fillName);
					end;
				end
			else
				table.insert(fruits, Attaches[i].fillName);
			end;
		end;
		Fruitnames = table.concat(fruits, " | ");
		-- print("----");
		-- print(table.show(Attaches, "Attaches : getVehicleAttachmentsFruitTypes()"));
		-- print("----");
		return Fruitnames, Attaches;
	end;
	return nil;
end;

function getImplements(object, o)
	if table.getn(object.attachedImplements) > 0 then
		for a=1, table.getn(object.attachedImplements) do
			table.insert(o, object.attachedImplements[a].object);
		end;
		return true;
	end;
	return false;
end;
----

----
-- Ermitteln der Vehicle Informationen
----
function mapviewer:GetVehicleInfo(vehicle)
	----
	-- TODO's
	----
	-- getNoNil aufrufe entfernen
	-- getText aufrufe durch eigene Funktion ersetzen
	----
	local vehicleInfo = {}; --{Type = "", Ply= "", Tank = 0, Fruit = ""};
	local percent = 0;
	local fruitNames;
	local attachList = {};	--name, fillLevel, fillType, capacity, fillName
	
	if vehicle ~= nil and type(vehicle) == "table" then
		-- Zeile [1] = VehicleName
		table.insert(vehicleInfo, vehicle.name);
		
		----
		-- Zeile [2] Spieler oder Gerätetyp
		----
		if self.bigmap.InfoPanel.isVehicle then
			----
			-- Text für Spieler erstellen
			----
			if vehicle.isControlled then
				local tmp;
				tmp = g_i18n:getText("MV_Player") .. string.sub(Utils.getNoNil(vehicle.controllerName, g_i18n:getText("MV_EmptyPlayer")), 0, 20);
				if vehicle.isHired then 
					tmp = tmp .. " [H]"; 
				end;
				table.insert(vehicleInfo, tmp); 
			elseif not vehicle.isControlled and vehicle.isHired then 
				tmp = g_i18n:getText("MV_Player") .. string.sub(Utils.getNoNil(vehicle.controllerName, g_i18n:getText("MV_HiredVehicle")), 0, 20);
				table.insert(vehicleInfo, tmp); 
			end;			
			----
			
			----
			-- Zeile [3] : Akteuellen Treibstofftank anzeigen
			----
			-- Eventl. mit Ist und Kann Anzeige erweitern
			tmp = string.format("%s %.2f %%", g_i18n:getText("MV_VehicleFuel"), (vehicle.fuelFillLevel / vehicle.fuelCapacity * 100));
			table.insert(vehicleInfo, tmp);
			----
		else -- Zeile [2] : Wenn kein Fahrzeug, Typ statt Spieler anzeigen
			if g_i18n:hasText("MV_AttachType"..vehicle.typeName) then
				table.insert(vehicleInfo, "Typ : " .. string.sub(Utils.getNoNil( g_i18n:getText("MV_AttachType"..vehicle.typeName), g_i18n:getText("MV_Unknown")),0,25));
			else
				table.insert(vehicleInfo, "Typ : " .. string.sub(vehicle.typeName, 0, 25)); 
			end;
		end;
				
		----
		-- Füllstand, Ladungsname
		-- Alle Fillable 
		----
		-- Wenn Befüllbar ODER Steuerbar ODER Combine
		----
		if (SpecializationUtil.hasSpecialization(Fillable, vehicle.specializations) or SpecializationUtil.hasSpecialization(Steerable, vehicle.specializations)) or SpecializationUtil.hasSpecialization(Combine, vehicle.specializations) then
			local f, c, p;
			local nIndex,oImplement, attFruits, temp;

			----
			-- Füllstand ermitteln neu
			----
			if not SpecializationUtil.hasSpecialization(Combine, vehicle.specializations) then
				----
				-- Füllstände aller Teile ermitteln, bei Fahrzeugen ohne Combine
				----
				if vehicle:getAttachedTrailersFillLevelAndCapacity() then
					----
					-- Gesamt Füllstand
					----
					f, c = vehicle:getAttachedTrailersFillLevelAndCapacity();
					if f ~= nil and c ~= nil and c > 0 then
						p = f / c * 100;
						table.insert(vehicleInfo, string.format("%s %d / %d | %.2f%%", g_i18n:getText("MV_FillLevel"), f, c, p));	--Gesamt Füllstand
					end;
					----
				end;
				----
			else 
				----
				-- Füllstand bei Combine ermitteln
				----
				-- if vehicle:getFruitTypeAndFillLevelToUnload() then
				if vehicle.grainTankCapacity ~= nil and vehicle.grainTankCapacity > 0 then
					-- fruitType, f, useGrainTank = vehicle:getFruitTypeAndFillLevelToUnload();
					fruitType = vehicle.currentGrainTankFruitType; 
					fruitFillLevel = vehicle.grainTankFillLevel; 
					f = fruitFillLevel;
					useGrainTank = true;
					-- print(string.format("Fruittype %s, FillLevel % s, useGrainTank %s",tostring(fruitType), tostring(f), tostring(useGrainTank)));
					if useGrainTank and f ~= nil then
						c = vehicle.grainTankCapacity;
						if c > 0 then
							p = f / c * 100;
							table.insert(vehicleInfo, string.format("%s %d / %d | %.2f%%", g_i18n:getText("MV_FillLevel"), f, c, p));
						end;
						--print(string.format("Combine - Füllstand / Kapazität : %.2f / %.2f | Name : %s | TankInfo : %s", f, c, tostring(vehicle.name), vehicleInfo.Tank));
					end;
					----
					-- Fruchtbezeichnung ermitteln
					----
					if fruitType ~= nil and fruitType ~= FruitUtil.FRUITTYPE_UNKNOWN then
						table.insert(vehicleInfo, tostring(Utils.getNoNil(g_i18n:getText(FruitUtil.fruitIndexToDesc[fruitType].name)), g_i18n:getText("MV_Unknown")));
					else 
						table.insert(vehicleInfo, g_i18n:getText("MV_EmptyTank"));	-- Empty --
					end;
					----
				end;
				----
			end;
			----
		end;
		--attachList = {name, fillLevel, fillType, capacity, fillName}
		fruitNames, attachList = getVehicleAttachmentsFruitTypes(vehicle);
		
		----
		-- Attachment Infos. Name und Füllstand und Ladungsname
		----
		if attachList ~= nil then 
			table.insert(vehicleInfo, g_i18n:getText("MV_Attachments"));
			for a=1, table.getn(attachList) do
				if attachList[a].fillLevel~=nil and attachList[a].capacity~=nil and attachList[a].FillType~=nil and attachList[a].fillName~=nil then
					if attachList[a].fillLevel > 0 then
						p = attachList[a].fillLevel / attachList[a].capacity * 100;
						table.insert(vehicleInfo, string.format("   %d : %s", a, attachList[a].Name));
						table.insert(vehicleInfo, string.format("    - %d%% %s", p, attachList[a].fillName));
					else
						table.insert(vehicleInfo, string.format("   %d : %s", a, attachList[a].Name));
						table.insert(vehicleInfo, string.format("    - 0%% - %s -", g_i18n:getText("MV_EmptyTank")));
					end;
				else
					table.insert(vehicleInfo, string.format("   %d : %s", a, attachList[a].Name));
				end;
			end;
		end;
		----
		-- print("----");
		-- print(table.show(attachList, "attachList : GetVehicleInfo()"));
		-- print("----");
		-- print(table.show(vehicleInfo, "vehicleInfo : GetVehicleInfo()"));
		-- print("----");
	end;
	---- Ende Füllstand ermitteln neu ----		
	return vehicleInfo;
end;
----

----
-- Panel anzeigen
----
function mapviewer:ShowPanelonMap()
	if self.showInfoPanel then
		local tX, tY, tLeft, tRight, tTop;
		
		----
		-- Berechnen der benötigten Höhe für den Texthintergrund
		----
		local zeile = table.getn(self.bigmap.InfoPanel.Info);
		self.bigmap.InfoPanel.background.height = zeile * 0.015;
		----
		
		----
		-- ToDo : Position anpassen wenn Panel zuweit oben oder zu weit rechts ist.
		----		
		tX = self.bigmap.InfoPanel.background.Pos.x;
		tY = self.bigmap.InfoPanel.background.Pos.y;
		--tTop = tY + self.bigmap.InfoPanel.background.height - 0.020;
		tTop = tY + self.bigmap.InfoPanel.background.height; -- - 0.035;
		tLeft = tX + 0.005; 
		
		renderOverlay(self.bigmap.InfoPanel.top.OverlayId, self.bigmap.InfoPanel.top.Pos.x, self.bigmap.InfoPanel.top.Pos.y, self.bigmap.InfoPanel.top.width, self.bigmap.InfoPanel.top.height);
		renderOverlay(self.bigmap.InfoPanel.background.OverlayId, self.bigmap.InfoPanel.background.Pos.x, self.bigmap.InfoPanel.background.Pos.y, self.bigmap.InfoPanel.background.width, self.bigmap.InfoPanel.background.height);
		renderOverlay(self.bigmap.InfoPanel.bottom.OverlayId, self.bigmap.InfoPanel.bottom.Pos.x, self.bigmap.InfoPanel.bottom.Pos.y, self.bigmap.InfoPanel.bottom.width, self.bigmap.InfoPanel.bottom.height);
		----

		----
		--
		----
		-- print(table.show(self.bigmap.InfoPanel.Info, "self.bigmap.InfoPanel.Info"));
		----
		
		----
		-- Ausgabe des InfoPanel Text
		----
		setTextBold(true);
		setTextColor(0, 0, 0, 1);
		if self.bigmap.InfoPanel.lastVehicle ~= nil then
			for r=1, table.getn(self.bigmap.InfoPanel.Info) do
				--renderText(tLeft, tTop-r*0.015+0.015, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info[r], g_i18n:getText("MV_Unknown"))));
				renderText(tLeft, tTop-r*0.015, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info[r], g_i18n:getText("MV_Unknown"))));
			end;
		end;
		setTextColor(1, 1, 1, 0);
		setTextBold(false);
	end;
end;
----

----
-- Ausgabe auf dem Bildschirm
----
function mapviewer:draw()
	if self.mapvieweractive then
		if self.bigmap.OverlayId.ovid ~= nil and self.bigmap.OverlayId.ovid ~= 0 then
			setOverlayColor(self.bigmap.OverlayId.ovid, 1,1,1,self.bigmap.mapTransp);
			renderOverlay(self.bigmap.OverlayId.ovid, self.bigmap.mapPosX, self.bigmap.mapPosY, self.bigmap.mapWidth, self.bigmap.mapHeight);
		else
            self.mapvieweractive = false;
		end;
	end;
	if self.mv_Error then
		g_currentMission:addWarning(g_i18n:getText("MV_ErrorCreateMV"), 0.018, 0.033);
	end;
	if self.mapvieweractive then
		--Aktuelle Transparenz und Copyright
		setTextColor(1, 1, 1, 1);
		renderText(0.5-0.0273, 1-0.03, 0.020, string.format("Transparenz\t%d", self.bigmap.mapTransp * 100));
		renderText(0.5-0.035, 0.03, 0.018, g_i18n:getText("mapviewtxt"));
		setTextColor(1, 1, 1, 0);
        ----

		----
		--	TODO: Sichergehen das die Maus nicht ausgeblendet wird, wenn keine Transparenz eingestellt ist
		----
		-- if self.bigmap.mapTransp == 1 then
			-- g_mouseControlsHelp.active = false;
			-- InputBinding.setShowMouseCursor(true);
			-- InputBinding.wrapMousePositionEnabled = false;
			-- if (g_currentMission.player.isEntered) then
				-- g_currentMission.player.isFrozen = true;
			-- end;
		-- elseif self.bigmap.mapTransp < 1 then
			-- g_mouseControlsHelp.active = true;
			-- InputBinding.setShowMouseCursor(false);
			-- InputBinding.wrapMousePositionEnabled = true;
			-- if (g_currentMission.player.isEntered) then
				-- g_currentMission.player.isFrozen = false;
			-- end;
		-- end;
		----

        ----
        -- Anzeigen des aktuell gewählten Modus
        ----
        if self.numOverlay > 0 then
            setTextColor(1, 1, 1, 1);
            renderText(0.5-0.0273, 1-0.05, 0.020, g_i18n:getText(string.format("MV_Mode%d", self.numOverlay)));
            renderText(0.5-0.0273, 1-0.065, 0.020, g_i18n:getText(string.format("MV_Mode%dName", self.numOverlay)));
            setTextColor(1, 1, 1, 0);
        end;
        ----

		--Points of Interessts
		-- if self.usePoi and self.showPoi then
		if self.showPoi then
			if self.bigmap.PoI.OverlayId ~= nil and self.bigmap.PoI.OverlayId ~= 0 then
				renderOverlay(self.bigmap.PoI.OverlayId, self.bigmap.PoI.poiPosX, self.bigmap.PoI.poiPosY, self.bigmap.PoI.width, self.bigmap.PoI.height);
			else
                g_currentMission:addWarning(g_i18n:getText("MV_ErrorPoICreateOverlay"), 0.018, 0.033);
				self.usePoi = false; -- not self.usePoi;
			end;
		end;
        ----
		
		--Fieldnumbers
		-- if self.useFNum and self.showFNum then
		if self.showFNum then
			if self.bigmap.FNum.OverlayId ~= nil and self.bigmap.FNum.OverlayId ~= 0 then
				renderOverlay(self.bigmap.FNum.OverlayId, self.bigmap.FNum.FNumPosX, self.bigmap.FNum.FNumPosY, self.bigmap.FNum.width, self.bigmap.FNum.height);
			else
                -- string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorFNumCreateOverlay"))
                g_currentMission:addWarning(g_i18n:getText("MV_ErrorFNumCreateOverlay"), 0.018, 0.033);
				self.useFNum = false; -- not self.useFNum;
			end;
		end;
        ----

		--Bottles
		-- local countBottlesFound = 0;
		-- if self.showBottles and self.useBottles then
			-- if self.bigmap.iconBottle.Icon.OverlayId ~= nil and self.bigmap.iconBottle.Icon.OverlayId ~= 0 then
                -- for i=1, table.getn(g_currentMission.missionMapBottleTriggers) do
                    -- local bottleFound=string.byte(g_currentMission.foundBottles, i);
                    -- if bottleFound==48 then
                        -- self.posX, self.posY, self.posZ=getWorldTranslation(g_currentMission.missionMapBottleTriggers[i]);
                        -- self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
                        -- self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
                        
                        -- renderOverlay(self.bigmap.iconBottle.Icon.OverlayId,
                                    -- self.buttonX-self.bigmap.iconBottle.width/2, 
                                    -- self.buttonZ-self.bigmap.iconBottle.height/2, 
                                    -- self.bigmap.iconBottle.width, 
                                    -- self.bigmap.iconBottle.height);
					-- else
						-- countBottlesFound = countBottlesFound+1;
                    -- end;
                -- end;
				----
				-- TODO: Container Positionen anzeigen
				----
				-- missionMapGlassContainerTriggers
				----
			-- else
                -- print(string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorBottlesCreateOverlay")));
				-- self.useBottles = not self.useBottles;
			-- end;
		-- end;
        ----
		
		--Maplegende anzeigen
		if self.maplegende and self.useLegend then
			if self.bigmap.Legende.OverlayId ~=nil then
				-- renderOverlay(self.bigmap.Legende.OverlayId, self.bigmap.Legende.legPosX, self.bigmap.Legende.legPosY, self.bigmap.Legende.width, self.bigmap.Legende.height);
				-- setTextColor(0, 0, 0, 1);
				setTextColor(0, 1, 0, 1);
                ----
                -- Legende der Fahrzeuge Typen anzeigen
                ----
				--self.bigmap.Legende.Content, {l_PosX, l_PosY, OverlayID, l_Txt, Txt, TxtSize}
				local c = self.bigmap.Legende.Content;
				for i=1, table.getn(c) do
					if c[i].OverlayID ~= nil and c[i].OverlayID ~= 0 then
						renderOverlay(c[i].OverlayID,
										c[i].l_PosX, -- 0.007324,
										c[i].l_PosY, 
										0.015625, 
										0.015625);
						renderText(c[i].l_Txt, c[i].l_PosY, c[i].TxtSize, c[i].Txt);
						-- if self.printInfo then
							-- print(table.show(c[i], string.format("Content %d : ", i)));
						-- end;
					else
						renderText(c[i].l_Txt, c[i].l_PosY, c[i].TxtSize, "Legenden Icon nicht vorhanden");
					end;
				end;
				self.printInfo = false;

                self.l_PosY = 1-0.02441 - 0.007324 - 0.015625 - self.bigmap.Legende.height;
				-- print("----");
				-- print(string.format("attachmentsTypes.names %d", table.getn(self.bigmap.attachmentsTypes.names)));
				-- print(string.format(table.show(self.bigmap.attachmentsTypes.names, "attachmentsTypes.names")));
				-- print(string.format("attachmentsTypes.overlays %d", table.getn(self.bigmap.attachmentsTypes.overlays)));
				-- print(string.format(table.show(self.bigmap.attachmentsTypes.overlays, "attachmentsTypes.overlays")));
				-- print("----");
				
                for lg=1, table.getn(self.bigmap.attachmentsTypes.names) do
					if self.bigmap.attachmentsTypes.overlays[self.bigmap.attachmentsTypes.names[lg]] ~= nil then 
						renderOverlay(self.bigmap.attachmentsTypes.overlays[self.bigmap.attachmentsTypes.names[lg]],
                                    self.bigmap.Legende.legPosX + 0.007324,
                                    self.l_PosY, 
                                    self.bigmap.attachmentsTypes.width,
                                    self.bigmap.attachmentsTypes.height);
						renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.016, g_i18n:getText("MV_AttachType" .. self.bigmap.attachmentsTypes.names[lg]));
					else
						renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.016, string.format("OverlayIcon nicht gefunden  : %s", self.bigmap.attachmentsTypes.names[lg]));
					end;
					self.l_PosY = self.l_PosY - 0.020;
                end;
                ----
				setTextColor(1, 1, 1, 0);
                
			end;	--if legende nicht NIL
		elseif self.bigmap.Legende.OverlayId == nil or self.bigmap.Legende.OverlayId == 0 then
			renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Rendern der Legende Fehlgeschlagen");
			print(g_i18n:getText("mapviewtxt") .. " : Rendern der Maplegende fehlgeschlagen");
			print(g_i18n:getText("mapviewtxt") .. " : Error rendering map legend");
		elseif self.mapvieweractive and not self.maplegende then
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_Legende"), InputBinding.BIGMAP_Legende);
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_TransPlus"), InputBinding.BIGMAP_TransPlus);
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_TransMinus"), InputBinding.BIGMAP_TransMinus);
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_SwitchOverlay"), InputBinding.BIGMAP_SwitchOverlay);
			-- unterscheiden wenn gedrückt dann info wechseln das maus geklickt werden muss
			-- g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_Teleport"), InputBinding.BIGMAP_Teleport);
			-- g_currentMission:addHelpButtonText("Teportation :" .. g_i18n:getText("BIGMAP_TPKey1") .. g_i18n:getText("BIGMAP_TPKey2") .. g_i18n:getText("BIGMAP_TPMouse"), "");
		end;

		mplayer = {};
		for key, value in pairs (g_currentMission.players) do
			mplayer.player = value;
			if mplayer.player.isControlled == false then
				posX = mplayer.player.lastXPos;
				posY = mplayer.player.lastYPos;
				posZ = posY;
			else
				posX, posY, posZ = getWorldTranslation(mplayer.player.rootNode);
			end;

			mplayer.xPos = ((((self.bigmap.mapDimensionX/2)+posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);--self.bigmap.player.xPosPDA+0.008;
			mplayer.yPos = ((((self.bigmap.mapDimensionY/2)-posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);--self.bigmap.player.yPosPDA+0.003;
			setTextColor(0, 1, 0, 1);

			if mplayer.player.rootNode == self.activePlayerNode and mplayer.player.isControlled then
				if self.bigmap.player.ArrowOverlayId ~= nil and self.bigmap.player.ArrowOverlayId ~= 0 then
					renderOverlay(self.bigmap.player.ArrowOverlayId, 
									mplayer.xPos-self.bigmap.player.width/2, mplayer.yPos-self.bigmap.player.height/2,
									self.bigmap.player.width, self.bigmap.player.height);
				end;
				renderText(mplayer.xPos +self.bigmap.player.width/2, mplayer.yPos-self.bigmap.player.height/2, 0.015, mplayer.player.controllerName);
				renderText(0.020, 0.060, 0.015, string.format("Koordinaten : x%.1f / y%.1f",mplayer.xPos*1000,mplayer.yPos*1000));
			elseif mplayer.player.isControlled then
				if self.bigmap.player.mpArrowOverlayId ~=nil and self.bigmap.player.mpArrowOverlayId ~= 0 then
					renderOverlay(self.bigmap.player.mpArrowOverlayId, 
									mplayer.xPos-self.bigmap.player.width/2, mplayer.yPos-self.bigmap.player.height/2, 
									self.bigmap.player.width, self.bigmap.player.height);
				end;
				renderText(mplayer.xPos +self.bigmap.player.width/2, mplayer.yPos-self.bigmap.player.height/2, 0.015, mplayer.player.controllerName);
			end;
			setTextColor(1, 1, 1, 0);
		end;
		
		----
		-- ToDo : Hotsspots ausblendbar machen
		-- Hotspots auf grosse Karte
		----
		if self.showHotSpots then
			local hsPosX, hsPosY;
			-- print("-- Hotspot Loop --");
			for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
				self.hsWidth = g_currentMission.missionPDA.hotspots[j].width;
				self.hsHeight = g_currentMission.missionPDA.hotspots[j].height;
				----
				hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+1024;
				hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+1024;
				
				self.hsPosX = (hsPosX/self.bigmap.mapDimensionX)-(self.hsWidth/2);
				self.hsPosY = 1-(hsPosY/self.bigmap.mapDimensionY)-(self.hsHeight/2);
				self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;			

				local bc = g_currentMission.missionPDA.hotspots[j].baseColor;
				
				setTextColor(1, 1, 1, 1);
				setTextAlignment(RenderText.ALIGN_CENTER);

				if g_currentMission.missionPDA.hotspots[j].showName then
					setTextColor(bc[1], bc[2], bc[3], bc[4]);
					-- setTextColor(0, 1, 0, 1);
					-- print("--- showName() ---");
					renderText(self.hsPosX, self.hsPosY, 0.032, tostring(g_currentMission.missionPDA.hotspots[j].name));
				else
					renderOverlay(self.hsOverlayId, self.hsPosX, self.hsPosY, self.hsWidth, self.hsHeight);
					if g_i18n:hasText("MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name) then
						renderText(self.hsPosX+self.hsWidth/2, self.hsPosY-self.hsHeight/2, 0.020, tostring(g_i18n:getText("MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name)));
					else
						renderText(self.hsPosX+self.hsWidth/2, self.hsPosY-self.hsHeight/2, 0.020, tostring(g_currentMission.missionPDA.hotspots[j].name));
						-- print("Fehelende Übersetzung: " .. "MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name);
					end;
				end;
				setTextAlignment(RenderText.ALIGN_LEFT);
				setTextColor(1, 1, 1, 0);

				if self.debug.printHotSpots then
					print(string.format("Debug : HS X1 %.2f | HS Y1 %.2f | mapHS X1 %.2f | mapHS Y1 %.2f | name: %s", g_currentMission.missionPDA.hotspots[j].xMapPos, g_currentMission.missionPDA.hotspots[j].yMapPos, self.hsPosX, self.hsPosY, g_currentMission.missionPDA.hotspots[j].name));
				end;
			end;
			if self.debug.printHotSpots then
				self.debug.printHotSpots = false;
			end;
			-- print("-- Hotspot Loop Ende --");
		end;

		----
		-- Fahrzeuge auf grosse Karte
		----
		for i=1, table.getn(g_currentMission.steerables) do
            local Courseplayname = "";
			if not g_currentMission.steerables[i].isBroken then
				self.currentVehicle = g_currentMission.steerables[i];
				self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
				self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
				self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
                
                ----
                -- Auslesen der Kurse wenn CoursePlay vorhanden ist
                ----
                if SpecializationUtil.hasSpecialization(courseplay, self.currentVehicle.specializations) and self.showCP then
                    if self.bigmap.IconCourseplay.Icon.OverlayId ~= nil and self.bigmap.IconCourseplay.Icon.OverlayId ~= 0 then
                        if self.currentVehicle.current_course_name ~=nil then
                            Courseplayname = self.currentVehicle.current_course_name;
                        end;
                        for w=1, table.getn(g_currentMission.steerables[i].Waypoints) do
                            local wx = g_currentMission.steerables[i].Waypoints[w].cx;
                            local wz = g_currentMission.steerables[i].Waypoints[w].cz;
                            wx = ((((self.bigmap.mapDimensionX/2)+wx)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
                            wz = ((((self.bigmap.mapDimensionY/2)-wz)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);

                            renderOverlay(self.bigmap.IconCourseplay.Icon.OverlayId,
                                        wx-self.bigmap.IconCourseplay.width/2, 
                                        wz-self.bigmap.IconCourseplay.height/2,
                                        self.bigmap.IconCourseplay.width,
                                        self.bigmap.IconCourseplay.height);
                        end;
                        setOverlayColor(self.bigmap.IconCourseplay.Icon.OverlayId, 1, 1, 1, 1);
                    end;
                end;
                ----
				
				setTextColor(0, 1, 0, 1);
				if self.currentVehicle.isControlled and self.currentVehicle.controllerName == self.plyname.name then
					if self.bigmap.IconSteerable.mpOverlayId ~= nil and self.bigmap.IconSteerable.mpOverlayId ~= 0 then
						renderOverlay(self.bigmap.IconSteerable.mpOverlayId,
									self.buttonX-self.bigmap.IconSteerable.width/2, 
									self.buttonZ-self.bigmap.IconSteerable.height/2,
									self.bigmap.IconSteerable.width,
									self.bigmap.IconSteerable.height);
						setOverlayColor(self.bigmap.IconSteerable.OverlayId, 1, 1, 1, 1);
					end;
					
					renderText(self.buttonX-0.025, self.buttonZ-self.bigmap.IconSteerable.height-0.01, 0.015, string.format("%s", self.plyname.name));
                    -- Kursnamen am Fahrzeug anzeigen
                    if Courseplayname ~= "" then
                        renderText(self.buttonX-0.025, self.buttonZ-self.bigmap.IconSteerable.height-0.020, 0.015, string.format("CoursePlay : %s", Courseplayname));
                    end;
                    --
					renderText(0.020, 0.020, 0.015, string.format("Koordinaten : x=%.1f / y=%.1f",self.buttonX * 1000,self.buttonZ * 1000));
				elseif self.currentVehicle.isControlled then
					if self.bigmap.IconSteerable.mpOverlayId ~= nil and self.bigmap.IconSteerable.mpOverlayId ~= 0 then
						renderOverlay(self.bigmap.IconSteerable.mpOverlayId,
									self.buttonX-self.bigmap.IconSteerable.width/2, 
									self.buttonZ-self.bigmap.IconSteerable.height/2,
									self.bigmap.IconSteerable.width,
									self.bigmap.IconSteerable.height);
						setOverlayColor(self.bigmap.IconSteerable.OverlayId, 1, 1, 1, 1);
					end;
					renderText(self.buttonX-0.025, self.buttonZ-self.bigmap.IconSteerable.height-0.01, 0.015, string.format("%s", self.currentVehicle.controllerName));
                    
                    -- Kursnamen am Fahrzeug anzeigen
                    if Courseplayname ~= "" then
                        renderText(self.buttonX-0.025, self.buttonZ-self.bigmap.IconSteerable.height-0.020, 0.015, string.format("CoursePlay : %s", Courseplayname));
                    end;
                    --
				else
					if self.bigmap.IconSteerable.OverlayId ~= nil and self.bigmap.IconSteerable.OverlayId ~= 0 then
						renderOverlay(self.bigmap.IconSteerable.OverlayId,
									self.buttonX-self.bigmap.IconSteerable.width/2, 
									self.buttonZ-self.bigmap.IconSteerable.height/2,
									self.bigmap.IconSteerable.width,
									self.bigmap.IconSteerable.height);
						setOverlayColor(self.bigmap.IconSteerable.OverlayId, 1, 1, 1, 1);
                        -- Kursnamen am Fahrzeug anzeigen
                        if Courseplayname ~= "" then
                            renderText(self.buttonX-0.025, self.buttonZ-self.bigmap.IconSteerable.height-0.01, 0.015, string.format("CoursePlay : %s", Courseplayname));
                        end;
                        --
					end;
				end;
				setTextColor(1, 1, 1,0);
			elseif g_currentMission.steerables[i].isBroken then
			----
			-- unbrauchbare Fahrzeuge mit weiterem Icon anzeigen
			----
				self.posX, self.posY, self.posZ = getWorldTranslation(g_currentMission.steerables[i].rootNode);
				self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
				self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
                if self.bigmap.iconIsBroken.Icon.OverlayId ~= nil and self.bigmap.iconIsBroken.Icon.OverlayId ~= 0 then
                    renderOverlay(self.bigmap.iconIsBroken.Icon.OverlayId,
                                self.buttonX-self.bigmap.iconIsBroken.width/2, 
                                self.buttonZ-self.bigmap.iconIsBroken.height/2,
                                self.bigmap.iconIsBroken.width,
                                self.bigmap.iconIsBroken.height);
                    setOverlayColor(self.bigmap.iconIsBroken.Icon.OverlayId, 1, 1, 1, 1);
                end;
			end;
		end;

		-----
		-- Darstellen der Geräte auf der Karte
		----
		for i=1, table.getn(g_currentMission.attachables) do
			self.currentVehicle = g_currentMission.attachables[i];
			self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
			self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
			self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);

            if g_currentMission.attachables[i].attacherVehicle == nil or g_currentMission.attachables[i].attacherVehicle == 0 then
				if self.bigmap.attachmentsTypes.overlays[g_currentMission.attachables[i].typeName] ~= nil then
					renderOverlay(self.bigmap.attachmentsTypes.overlays[g_currentMission.attachables[i].typeName],
                                self.buttonX-self.bigmap.attachmentsTypes.width/2, 
                                self.buttonZ-self.bigmap.attachmentsTypes.height/2,
                                self.bigmap.attachmentsTypes.width,
                                self.bigmap.attachmentsTypes.height);
				else
					renderOverlay(self.bigmap.attachmentsTypes.overlays["other"],
                                self.buttonX-self.bigmap.attachmentsTypes.width/2, 
                                self.buttonZ-self.bigmap.attachmentsTypes.height/2,
                                self.bigmap.attachmentsTypes.width,
                                self.bigmap.attachmentsTypes.height);
				end;
            else
                renderOverlay(self.bigmap.IconAttachments.Icon.front.OverlayId,
                                self.buttonX-self.bigmap.IconAttachments.width/2, 
                                self.buttonZ-self.bigmap.IconAttachments.height/2,
                                self.bigmap.IconAttachments.width,
                                self.bigmap.IconAttachments.height);
            end;
			setOverlayColor(self.bigmap.IconAttachments.Icon.front.OverlayId, 1, 1, 1, 1);
		end;
		----
		
		----
		-- Milchtruck auf Karte Zeichnen
		----
		for i=1, table.getn(g_currentMission.trafficVehicles) do
			if g_currentMission.trafficVehicles[i].typeName == "milktruck" then
				self.currentVehicle = g_currentMission.trafficVehicles[i];
				if self.bigmap.IconMilchtruck.OverlayId ~= nil and self.bigmap.IconMilchtruck.OverlayId ~= 0 then
					self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
					self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
					self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
					
					--self.bigmap.IconMilchtruck = {}; --file, OverlayId, width, height
					if self.bigmap.IconMilchtruck.OverlayId ~= nil then
						renderOverlay(self.bigmap.IconMilchtruck.OverlayId,
									self.buttonX-self.bigmap.IconMilchtruck.width/2, 
									self.buttonZ-self.bigmap.IconMilchtruck.height/2,
									self.bigmap.IconMilchtruck.width,
									self.bigmap.IconMilchtruck.height);
					end;
				end;
				break;
			end;
		end;
		----
		
		----
		-- InfoPanel anzeigen
		----
		setTextColor(0, 0, 0, 1);
		renderText(0.020, 0.090, 0.020, string.format("Mouse Pos : x:%.3f / y:%.3f",self.mouseX,self.mouseY));
		setTextColor(1, 1, 1, 0);
		if self.showInfoPanel then
			self.bigmap.InfoPanel.Info = {};
			-- print("draw() - showPanel = " .. tostring(self.showInfoPanel));
			-- print("draw() - self.bigmap.InfoPanel.vehicleIndex" .. tostring(self.bigmap.InfoPanel.vehicleIndex));
			-- if self.bigmap.InfoPanel.vehicleIndex ~= nil and self.bigmap.InfoPanel.vehicleIndex ~= 0 then
				self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle); -- self.bigmap.InfoPanel.vehicleIndex
				self:ShowPanelonMap();
			-- else
				-- self.showInfoPanel = false;
			-- end;
		end;
		----
	else
		g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_Activate"), InputBinding.BIGMAP_Activate);
	end;
	
	----
	-- Namen auf PDA anzeigen
	----
    ----
    -- TODO: Alle Spieler auf PDA anzeigen, Position des Namens korrigieren
    ----
		self.plyname.name = g_currentMission.player.controllerName;
		self.plyname.yPos = g_currentMission.missionPDA.pdaPlayerMapArrow.y - 0.003;
		self.plyname.xPos = g_currentMission.missionPDA.pdaPlayerMapArrow.x;
	if g_currentMission.missionPDA.showPDA == true and g_currentMission.missionPDA.screen==1 then
		setTextColor(256,256,256,1);
		setTextAlignment(RenderText.ALIGN_CENTER);
		renderText(self.plyname.xPos, self.plyname.yPos, 0.02, self.plyname.name);
		setTextAlignment(RenderText.ALIGN_LEFT);
	end;
	---------------------------
end;
----

----
--
----
function mapviewer:updateTick(dt)
	----
	-- Mousesteuerung nach Transparenz prüfen
	----

	-- if self.mapvieweractive then 
		-- if self.bigmap.mapTransp < 1 then --and g_mouseControlsHelp.active == true then 
			-- print("Transparenz ist < 1: " .. tostring(self.bigmap.mapTransp));
			-- g_mouseControlsHelp.active = true; 
			-- InputBinding.setShowMouseCursor(false); 
			-- InputBinding.wrapMousePositionEnabled = true; 
			-- if (g_currentMission.player.isEntered) then
				-- g_currentMission.player.isFrozen = false;
			-- end;
		-- elseif self.bigmap.mapTransp >= 1 then -- and g_mouseControlsHelp.active == false then 
			-- print("Transparenz ist >= 1: " .. tostring(self.bigmap.mapTransp));
			-- g_mouseControlsHelp.active = false; 
			-- InputBinding.setShowMouseCursor(true); 
			-- InputBinding.wrapMousePositionEnabled = false; 
			-- if (g_currentMission.player.isEntered) then
				-- g_currentMission.player.isFrozen = true;
			-- end;
		-- end; 
	-- end;
	
	  -- if (self.bigmap.mapTransp < 1 or not self.mapvieweractive) and g_mouseControlsHelp.active == false then 
          -- g_mouseControlsHelp.active = true; 
          -- InputBinding.setShowMouseCursor(false); 
          -- InputBinding.wrapMousePositionEnabled = true; 
     -- elseif self.bigmap.mapTransp >= 1 and self.mapvieweractive == true and g_mouseControlsHelp.active == true then 
          -- g_mouseControlsHelp.active = false; 
          -- InputBinding.setShowMouseCursor(true); 
          -- InputBinding.wrapMousePositionEnabled = false; 
     -- end;  
	
	-- if InputBinding.hasEvent(InputBinding.BIGMAP_TransPlus) or InputBinding.hasEvent(InputBinding.BIGMAP_TransMinus) then
		-- if self.bigmap.mapTransp >= 1.0 then
			-- g_mouseControlsHelp.active = false;
			-- InputBinding.setShowMouseCursor(true);
			-- InputBinding.wrapMousePositionEnabled = false;
			-- if (g_currentMission.player.isEntered) then
				-- g_currentMission.player.isFrozen = true;
			-- end;
		-- end;
		-- if self.bigmap.mapTransp < 1 then
			-- g_mouseControlsHelp.active = true;
			-- InputBinding.setShowMouseCursor(false);
			-- InputBinding.wrapMousePositionEnabled = true;		
			-- if (g_currentMission.player.isEntered) then
				-- g_currentMission.player.isFrozen = false;
			-- end;
		-- end;
	-- end;
	----

end;
----

----
-- Update Funktion
----
function mapviewer:update(dt)
	-- Ist der Spieler bereits geladen ?
	if self.activePlayerNode == nil or self.activePlayerNode == 0 then
		-- Wenn ja
		if g_currentMission.player ~= nil then
			-- Eigene Player.ID merken
			self.activePlayerNode=g_currentMission.player.rootNode;
			-- Variablen initialisieren
			mapviewer:InitMapViewer();
		end;
	end;
	
	-- Nur wenn Variablen initialisiert sind, auf Tasten eingaben reagieren
	if not self.mvInit then 
		return;
	end;

	-- Taste für Map einblenden
	if InputBinding.hasEvent(InputBinding.BIGMAP_Activate) then
		if self.bigmap.OverlayId.ovid ~= nil and self.bigmap.OverlayId.ovid ~= 0 then
			self.mapvieweractive=not self.mapvieweractive;
			-- g_currentMission.showHudEnv = not self.mapvieweractive;
			if not self.mapvieweractive then
				g_mouseControlsHelp.active = true; 
				InputBinding.setShowMouseCursor(false); 
				InputBinding.wrapMousePositionEnabled = true; 
				if (g_currentMission.player.isEntered) then
					g_currentMission.player.isFrozen = false;
				end;
				g_currentMission.showHudEnv = true;
			else
				g_currentMission.showHudEnv = false;
			end;
			
			-- if self.mapvieweractive and self.bigmap.mapTransp == 1 then
				-- g_mouseControlsHelp.active = false;
				-- InputBinding.setShowMouseCursor(true);
				-- InputBinding.wrapMousePositionEnabled = false;
				-- if (g_currentMission.player.isEntered) then
					-- g_currentMission.player.isFrozen = true;
				-- end;
			-- else
				-- g_mouseControlsHelp.active = true;
				-- InputBinding.setShowMouseCursor(false);
				-- InputBinding.wrapMousePositionEnabled = true;
				-- if (g_currentMission.player.isEntered) then
					-- g_currentMission.player.isFrozen = false;
				-- end;
			-- end;
		else
			self.mv_Error = not self.mv_Error;
			print(string.format("|| Update() - %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMV")));
		end;
	end;

	--Taste für Legende einblenden
	if InputBinding.hasEvent(InputBinding.BIGMAP_Legende) then
		if self.mapvieweractive and self.useLegend then
			--Legende einblenden
			self.maplegende = not self.maplegende;
			self.printInfo = self.maplegende;
			if g_currentMission:getIsServer() then
				mapviewer:SaveToFile();
			end;
		end;
	end;

	--Overlay wechseln
	if self.mapvieweractive and InputBinding.hasEvent(InputBinding.BIGMAP_SwitchOverlay) then
		self.numOverlay = self.numOverlay+1;

        ----
        -- Überprüfen ob Feldnummern und PoI benutz werden können
        ----
        -- if not self.useFNum or not self.usePoi or not self.useBottles then
            -- if self.numOverlay == 1 and not self.useFNum then
                -- self.numOverlay = self.numOverlay+1;
            -- end;
            -- if self.numOverlay == 2 and not self.usePoi then
                -- self.numOverlay = self.numOverlay+1;
            -- end;
            -- if self.numOverlay == 3 and (not self.usePoi or not self.useFNum) then
                -- self.numOverlay = self.numOverlay+1;
            -- end;
            -- if self.numOverlay == 5 and not self.useBottles then
                -- self.numOverlay = self.numOverlay+1;
            -- end;
        -- end;
        ----
        ----
        -- Alle Overlays deaktivieren
        ----
        self.showPoi = false;
        self.showFNum = false;
        self.showCP = false;
        self.showBottles = false;
        ----

		if self.numOverlay == 1 then	--nur Feldnummern
			self.showHotSpots = true;
		elseif self.numOverlay == 2 then	--nur Feldnummern
			self.showFNum = true;
			self.showHotSpots = false;
		elseif self.numOverlay == 3 then	--nur PoI
            self.showPoi = true;
			self.showHotSpots = false;
		elseif self.numOverlay == 4 then	--Poi und Nummern
			self.showHotSpots = false;
			self.showPoi = true;
			self.showFNum = true;
		-- elseif self.numOverlay == 4 then	--Courseplay Kurse anzeigen
			-- self.showCP = true;
		-- elseif self.numOverlay == 5 then	--Bottlefinder anzeigen
            -- self.showBottles = true;
		else
			self.numOverlay = 0;		--Alles aus
			self.showPoi = false;
			self.showFNum = false;
            self.showCP = false;
            self.showBottles = false;
			self.showHotSpots = false;
		end;

		if self.Debug then
			print("Debug Key BIGMAP_SwitchOverlay: ");
            print(string.format("|| $s || %s : %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_Mode" .. self.numOverlay), g_i18n:getText("MV_Mode".. self.numOverlay .."Name")));
		end;
		if g_currentMission:getIsServer() then
			mapviewer:SaveToFile();
		end;
	end;
	
	----
	-- Panel Position an Fahrzeug anpassen
	----
	if self.mapvieweractive and self.showInfoPanel then 
		-- print(" ---- update() - Panel Position an Fahrzeug anpassen ----");
		-- print("showInfoPanel = " .. tostring(self.showInfoPanel));
		-- print("InfoPanel.vehicleIndex = " .. tostring(self.bigmap.InfoPanel.vehicleIndex));
		-- print("self.bigmap.InfoPanel.lastVehicle.rootNode = " .. tostring(self.bigmap.InfoPanel.lastVehicle.rootNode));
		-- print("nodeToVehicle[self.bigmap.InfoPanel.lastVehicle.rootNode] = Gültig ? " .. tostring(g_currentMission.nodeToVehicle[self.bigmap.InfoPanel.lastVehicle.rootNode]~=nil));
		-- print("-- InfoPanel.lastVehicle Gültig ? -- " .. tostring(self.bigmap.InfoPanel.lastVehicle ~= nil));
		-- print("-- InfoPanel.lastVehicle type() -- " .. tostring(type(self.bigmap.InfoPanel.lastVehicle)));
		
		if self.bigmap.InfoPanel.lastVehicle ~= nil and type(self.bigmap.InfoPanel.lastVehicle) == "table" then	--nodeToVehicle
			-- if g_currentMission.vehicles[self.bigmap.InfoPanel.vehicleIndex].rootNode == self.bigmap.InfoPanel.lastVehicle.rootNode then
			if g_currentMission.nodeToVehicle[self.bigmap.InfoPanel.lastVehicle.rootNode] ~= nil then
				local posX1, posY1, posZ1 = getWorldTranslation(self.bigmap.InfoPanel.lastVehicle.rootNode);
				local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth); -- +self.bigmap.mapPosX;
				local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight); -- +self.bigmap.mapPosY;
				
				self.bigmap.InfoPanel.top.Pos.x = distancePosX-0.0078125-0.0078125;
				self.bigmap.InfoPanel.top.Pos.y = distancePosZ + self.bigmap.InfoPanel.bottom.height + self.bigmap.InfoPanel.background.height;
				self.bigmap.InfoPanel.background.Pos.x = distancePosX-0.0078125-0.0078125;
				self.bigmap.InfoPanel.background.Pos.y = distancePosZ + self.bigmap.InfoPanel.bottom.height;
				self.bigmap.InfoPanel.bottom.Pos.x = distancePosX-0.0078125-0.0078125;
				self.bigmap.InfoPanel.bottom.Pos.y = distancePosZ;
			else
				self.showInfoPanel = false;
			end;
		else
			self.showInfoPanel = false;
			print(string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateInfoPanel")));
			-- print("-- InfoPanel.lastVehicle type() -- " .. tostring(type(self.bigmap.InfoPanel.lastVehicle)));
		end;	
		-- print(" ---- update() - Panel Position ENDE ----");
	end;	
	----
	
	----
	--BigMap Transparenz erhöhen und verringern
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransMinus) then
		if self.bigmap.mapTransp < 1 and self.mapvieweractive then
			self.bigmap.mapTransp = self.bigmap.mapTransp + 0.05;
		end;
			print("Transparenz ist < 1: " .. tostring(self.bigmap.mapTransp));
		if g_currentMission:getIsServer() then
			mapviewer:SaveToFile();
		end;
	end;
	----
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransPlus) then
		if self.bigmap.mapTransp > 0.1 and self.mapvieweractive then
			self.bigmap.mapTransp = self.bigmap.mapTransp - 0.05;
		end;
			print("Transparenz ist >= 1: " .. tostring(self.bigmap.mapTransp));
		if g_currentMission:getIsServer() then
			mapviewer:SaveToFile();
		end;
	end;
	-- ende Transparenz umschalten
	----
	
	if self.mapvieweractive then 
		if self.bigmap.mapTransp < 1 and g_mouseControlsHelp.active == false then 
			g_mouseControlsHelp.active = true; 
			InputBinding.setShowMouseCursor(false); 
			InputBinding.wrapMousePositionEnabled = true; 
			if (g_currentMission.player.isEntered) then
				g_currentMission.player.isFrozen = false;
			end;
		elseif self.bigmap.mapTransp >= 1 and g_mouseControlsHelp.active == true then 
			g_mouseControlsHelp.active = false; 
			InputBinding.setShowMouseCursor(true); 
			InputBinding.wrapMousePositionEnabled = false; 
			if (g_currentMission.player.isEntered) then
				g_currentMission.player.isFrozen = true;
			end;
		end;
	-- else
		-- g_mouseControlsHelp.active = true; 
		-- InputBinding.setShowMouseCursor(false); 
		-- InputBinding.wrapMousePositionEnabled = true; 
		-- if (g_currentMission.player.isEntered) then
			-- g_currentMission.player.isFrozen = false;
		-- end;
	end;	
	
	----
	-- Tasten Modofizierer für Teleport
	----
	if InputBinding.isPressed(InputBinding.BIGMAP_TPKey1) and InputBinding.isPressed(InputBinding.BIGMAP_TPKey2) then -- and InputBinding.isPressed(InputBinding.BIGMAP_TPMouse) then
		-- print("---- ALT Taste ist gedrückt ----");
		self.useTeleport= true; -- not self.useTeleport;
	else
		self.useTeleport = false;
	end;
    ----

end;
----

----
-- Funktionen für Netzwerk / Multiplayer Synchronisierung
----
function mapviewer:readStream(streamId, connection)
	if connection:getIsServer() then
		-- local myPlayerId = streamReadFloat32(streamId);
		-- local x = streamReadFloat32(streamId);
		-- local y = streamReadFloat32(streamId);
		-- local z = streamReadFloat32(streamId);
	end;
end;

function mapviewer:writeStream(streamId, connection)
	if not connection:getIsServer() then
		-- local myPlayerId = streamWriteFloat32(streamId);
		-- local x = streamWriteFloat32(streamId);
		-- local y = streamWriteFloat32(streamId);
		-- local z = streamWriteFloat32(streamId);
	end;
end;

function mapviewer:readUpdateStream(streamId, timestamp, connection)
	 self:readStream(streamId, connection);
end;

function mapviewer:writeUpdateStream(streamId, timestamp, connection)	
	self:writeStream(streamId, connection);
end;
----

----
-- Neue Position an Server/Clients senden
----
function mapviewer:setNewPlayerPos(setNewPlyPosition, noEventSend)
	-- if noEventSend == nil or noEventSend == false then
		-- if g_server ~= nil then
			-- g_server:broadcastEvent(MapViewerTeleportEvent:new(self, setNewPlyPosition), nil, nil, self);
		-- else
			-- g_client:getServerConnection():sendEvent(MapViewerTeleportEvent:new(self, setNewPlyPosition));
		-- end;
	-- end;
end;
----

-------------------------------------------------------------------------------
----
--
-- Ab hier kommen Funktionen die nicht unbedingt vom Mod verwendet werden
-- Einige Funktionen dienen zur Hilfe beim Scripten
--
----
-------------------------------------------------------------------------------

----
-- Funktionen die durch neue ersetzt wurden
----
function mapviewer:ShowPanelonMapAlt()
	if self.showInfoPanel then
		--local vehicleInfo = {Type = "", Ply= "", Tank = 0, Fruit = ""};
		local tX, tY, tLeft, tRight, tTop;
		
		----
		-- Berechnen der benötigten Höhe für den Texthintergrund
		----
		local zeile = table.getn(self.bigmap.InfoPanel.Info);
		self.bigmap.InfoPanel.background.height = zeile * 0.015;
		----
		
		tX = self.bigmap.InfoPanel.background.Pos.x;
		tY = self.bigmap.InfoPanel.background.Pos.y;
		tTop = tY + self.bigmap.InfoPanel.background.height - 0.020;
		tLeft = tX + 0.005; 
		
		renderOverlay(self.bigmap.InfoPanel.top.OverlayId, self.bigmap.InfoPanel.top.Pos.x, self.bigmap.InfoPanel.top.Pos.y, self.bigmap.InfoPanel.top.width, self.bigmap.InfoPanel.top.height);
		renderOverlay(self.bigmap.InfoPanel.background.OverlayId, self.bigmap.InfoPanel.background.Pos.x, self.bigmap.InfoPanel.background.Pos.y, self.bigmap.InfoPanel.background.width, self.bigmap.InfoPanel.background.height);
		renderOverlay(self.bigmap.InfoPanel.bottom.OverlayId, self.bigmap.InfoPanel.bottom.Pos.x, self.bigmap.InfoPanel.bottom.Pos.y, self.bigmap.InfoPanel.bottom.width, self.bigmap.InfoPanel.bottom.height);

		----
		--
		----
		print(table.show(self.bigmap.InfoPanel.Info, "self.bigmap.InfoPanel.Info"));
		----
		
		-- local v = self.bigmap.InfoPanel.lastVehicle;
		setTextBold(true);
		setTextColor(0, 0, 0, 1);
		-- Vehiclename
		renderText(tLeft, tTop, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info[1], g_i18n:getText("MV_Unknown"))));
		-- Vehicletyp oder 
		if self.bigmap.InfoPanel.Info[2] ~= nil then
			renderText(tLeft, tTop-0.015, 0.012, string.format("%s", Utils.getNoNil(tostring(self.bigmap.InfoPanel.Info[2]), g_i18n:getText("MV_Unknown"))));
		end;
		if self.bigmap.InfoPanel.lastVehicle ~= nil then
			local z=4;
			if SpecializationUtil.hasSpecialization(Steerable, self.bigmap.InfoPanel.lastVehicle.specializations) and not SpecializationUtil.hasSpecialization(Combine, self.bigmap.InfoPanel.lastVehicle.specializations) then
				if self.bigmap.InfoPanel.Info[3] ~= nil then
				----
				-- TODO: Rendertext Positionen, Zugriff auf richtige indexes, Übersetzungen
				----
				--if Fahrzeug dann Treibstoff
					renderText(tLeft, tTop-0.030, 0.012, string.format("%s : %s", Utils.getNoNil( g_i18n:getText("MV_VehicleFuel"), "Fuel : "), Utils.getNoNil(self.bigmap.InfoPanel.Info[3], g_i18n:getText("MV_Unknown"))));
					tTop = tTop - 0.045;
				else
					tTop = tTop - 0.030;
				end;
			elseif SpecializationUtil.hasSpecialization(Combine, self.bigmap.InfoPanel.lastVehicle.specializations) then
				-- if combine dann Füllstand und  zusätzlich Treibstoff
				if self.bigmap.InfoPanel.Info[3] ~= nil and self.bigmap.InfoPanel.Info[4] ~= nil then
				--if Fahrzeug dann Treibstoff
					renderText(tLeft, tTop-0.030, 0.012, string.format("%s %s", Utils.getNoNil( g_i18n:getText("MV_VehicleFuel"), "Fuel : "), Utils.getNoNil(self.bigmap.InfoPanel.Info[3], g_i18n:getText("MV_Unknown"))));
					renderText(tLeft, tTop-0.045, 0.012, string.format("%s : %s", Utils.getNoNil( g_i18n:getText("MV_FillLevel"), "Capacity : "), Utils.getNoNil(self.bigmap.InfoPanel.Info[4], g_i18n:getText("MV_Unknown"))));
					tTop = tTop - 0.060;
					z=5;
				else
					tTop = tTop - 0.015;
				end;
			elseif SpecializationUtil.hasSpecialization(Fillable, self.bigmap.InfoPanel.lastVehicle.specializations) and not SpecializationUtil.hasSpecialization(Steerable, self.bigmap.InfoPanel.lastVehicle.specializations) then
				if self.bigmap.InfoPanel.Info[3] ~= nil then
				--Befüllbare Attaches
					renderText(tLeft, tTop-0.030, 0.012, string.format("%s : %s", Utils.getNoNil( g_i18n:getText("MV_FillLevel"), "Capacity : "), Utils.getNoNil(self.bigmap.InfoPanel.Info[3], g_i18n:getText("MV_Unknown"))));
					tTop = tTop - 0.045;
					--z=4;
				else
					tTop = tTop - 0.030;
				end;
			else
				tTop = tTop - 0.030;
			end;
			for r=z, table.getn(self.bigmap.InfoPanel.Info) do
				renderText(tLeft, tTop-r*0.015+0.030, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info[r], g_i18n:getText("MV_Unknown"))));
			end;
		end;
		setTextColor(1, 1, 1, 0);
		setTextBold(false);
	end;
end;

function mapviewer:getFillLevelOld(vehicle)
	local vehicleInfo = {Type = "", Ply= "", Tank = 0, Fruit = ""};
	local percent = 0;
	if vehicle.grainTankFillLevel ~= nil then 
		percent = vehicle.grainTankFillLevel / vehicle.grainTankCapacity * 100;
		vehicleInfo.Tank = string.format("%d / %d | %.2f%%", vehicle.grainTankFillLevel, vehicle.grainTankCapacity, percent);
		if vehicle.grainTankFillLevel > 0 then
			-- vehicleInfo.Fruit = FruitUtil.fruitIndexToDesc[vehicle.currentGrainTankFruitType].name;
			vehicleInfo.Fruit = tostring(g_i18n:getText(FruitUtil.fruitIndexToDesc[vehicle.currentGrainTankFruitType].name));
		else 
			vehicleInfo.Fruit = g_i18n:getText("MV_EmptyTank");
		end;
	elseif vehicle.capacity ~= nil then
		percent = vehicle.fillLevel / vehicle.capacity * 100;
		vehicleInfo.Tank = string.format("%d / %d | %.2f%%", vehicle.fillLevel, vehicle.capacity, percent);
		if SpecializationUtil.hasSpecialization(Fillable, vehicle.specializations) then
			if vehicle.currentFillType ~= Fillable.FILLTYPE_UNKNOWN then
				if g_i18n:hasText (Fillable.fillTypeIntToName[vehicle.currentFillType]) then
					vehicleInfo.Fruit = tostring(g_i18n:getText(Fillable.fillTypeIntToName[vehicle.currentFillType]));
				else
					vehicleInfo.Fruit = tostring(Fillable.fillTypeIntToName[vehicle.currentFillType]);
				end;
			end;
		else 
			vehicleInfo.Fruit = g_i18n:getText("MV_Unknown");
		end;
	elseif vehicle:getAttachedTrailersFillLevelAndCapacity() then
		local f, c;
		f, c = vehicle:getAttachedTrailersFillLevelAndCapacity();
		if f ~= nil and c ~= nil then
			--print(string.format("Fahrzeug Füllstand und Kapazität : %.2f | %.2f", f, c));
			percent = f / c * 100;
			vehicleInfo.Tank = string.format("%d / %d | %.2f%%", f, c, percent);
		end;
	else
		vehicleInfo.Tank = "";
		vehicleInfo.Fruit = ""; 
	end;
	return vehicleInfo;
end;
----

----
-- Trigger Array
----
function mapviewer:listTipTriggers()
	local z=0;
	for k,v in pairs(g_currentMission.tipTriggers) do
		z=z+1;
		print("TipTrigger: " .. tostring(z));
		print(tostring(k) .."("..type(v)..")="..tostring(v));
		for i,j in pairs(g_currentMission.tipTriggers[k]) do
			print(tostring(i).."("..type(j)..")="..tostring(j));
		end;
	end;
	print(table.show(g_currentMission.tipTriggers, "TipTrigger"));
end;
----

----
-- Funktionen um mit Tables zu arbeiten
----
-- Funktion zum  kopieren einer Tabelle in eine neue Tabelle, 
-- incl. Ausgabe der Datentypen, wenn Debug=TRUE
-- Parameter :
----
-- tab = zu kopierende Tabelle
-- parent = Übergeordnetes Element, für Ausgabe
----
function mapviewer:tablecopy(tab, parent)
    local ret = {}
	-- Prüfen auf gültige Tabelle
	-- Abbrechen wenn NIL
	if tab == nil then 
		return nil;
	end;
	
    for key, value in pairs(tab) do
		if  self.Debug then
			if parent ~= nil and type ~= "table" then 
				print(string.format("%s.%s=%s (%s)", parent, tostring(key), tostring(value), type(value)));
			elseif type ~= "table" then 
				print(string.format("%s=%s (%s)", tostring(key), tostring(value), type(value)));
			else
				print(string.format("%s=%s", tostring(key), type(value)));
			end;
		end;
		
        if (type(value) == "table") then 
			ret[key] = mapviewer:tablecopy(value, key)
        else 
			ret[key] = value 
		end;
    end;
    return ret
end;

function mapviewer:tprint (t, indent, done)
    if t == 0 or t == nil then
        print("tprint() : keine Daten");
        return;
    end;
    done = done or {}
    indent = indent or 0
    if type (t) == "table" then
        for key, value in pairs (t) do
            txt = string.format("%s",string.rep ("\t", indent));
            if type (value) == "table" and not done [value] then
                done [value] = true
                print (string.format("%s[%s]:", string.rep("\t", indent), tostring (key)));
                tprint (value, indent + 1, done)
            else
                print(string.format("%s%s=%s", txt, tostring(key), tostring(value)));
            end;
        end;
    elseif type (t) == "string" then
        print("Angegebene Tabelle ist keine Tabelle : -> " .. t);
    else
        print("Angegebene Tabelle ist keine Tabelle : -> " .. type(t));
    end;
end;

function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else 
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" then
         return so
      else
         return string.format("%q", so)
      end
   end
   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value] 
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end

function eval(str)
   return assert(loadstring(str))()
end   
----

----
-- HilfsFunktionen für Datei Verarbeitung
----
-- Find the length of a file
--   filename: file name
-- returns
--   len: length of file
--   asserts on error
----
function mapviewer:length_of_file(filename)
  -- local fh = assert(io.open(filename, "rb"))
  local fh = assert(io.open(filename, "r"))
  local len = assert(fh:seek("end"))
  fh:close()
  return len
end
----

----
-- Return true if file exists and is readable.
----
function mapviewer:file_exists(path)
  -- local file = io.open(path, "rb")
  local file = io.open(path, "r")
  if file then file:close() end
  return file ~= nil
end
----

addModEventListener(mapviewer);