-- mein Mapviewer, anzeigen der PDA Map auf dem Bildschirm
----
-- $Rev$:     Revision der letzten Änderung
-- $Author$:  Author der letzten Änderung
-- $Date$:    Date der letzten Änderung
-- $URL$
----
-- Mein Mapviewer, anzeigen der PDA Map auf dem Bildschirm
----

mapviewer={};
mapviewer.moddir=g_currentModDirectory;

function mapviewer:loadMap(name)
	-- print(string.format("|| %s || Starting ... ||", g_i18n:getText("mapviewtxt")));
	local userXMLPath = Utils.getFilename("mapviewer.xml", mapviewer.moddir);
	self.xmlFile = loadXMLFile("xmlFile", userXMLPath);

	self.mapvieweractive=false;
	self.maplegende = false;
	self.activePlayerNode=0;
	self.mvInit = false;
	self.showFNum = false;
	self.showPoi = false;
    self.showCP = false;
    self.showBottles = false;
    self.showInfoPanel = false;
    
    self.useBottles = true;
    self.useLegend = true;
    
	self.numOverlay = 0;
	self.mapPath = 0;
	
	self.useDefaultMap = false;
    
    self.courseplay = true;


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
	
	----
	-- Debug Modus
	----
	self.Debug = false;
	----
end;

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

	----
	-- Globale Kartengröße verwnenden
	-----
    self.bigmap.mapDimensionX = g_currentMission.missionPDA.worldSizeX;
    self.bigmap.mapDimensionY = g_currentMission.missionPDA.worldSizeZ;
	-----
    self.bigmap.PoI.width = 1;
    self.bigmap.PoI.height = 1;
    self.bigmap.FNum.width = 1;
    self.bigmap.FNum.height = 1;
	
	--
	-- Wenn keine vorgegebene Datei als Karte verwendet werden soll
	--
	self.mapPath = g_currentMission.missionInfo.map.baseDirectory;

    --
    -- Prüfen ob es sich um die Standard Karte handelt
    --
    if self.mapPath == "" and g_currentMission.missionInfo.map.title == "Karte 1" then
        self.mapPath = getAppBasePath() .. "data/maps/map01/";
        self.useDefaultMap = true;
    else
        self.mapPath = self.mapPath .. "map01/"
    end;
    -----
    self.bigmap.file = Utils.getNoNil(Utils.getFilename("pda_map.png", self.mapPath), Utils.getFilename("pda_map.dds", self.mapPath));
    self.bigmap.OverlayId.ovid = createImageOverlay(self.bigmap.file);

	-- Startwert der Transparenz
	self.bigmap.mapTransp = 1;
	
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
	-- Map Legende
	----
	self.bigmap.Legende = {};
	self.bigmap.Legende.OverlayId = nil
	self.bigmap.Legende.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.legende#file"), "gfx/background.png"), self.moddir);
	self.bigmap.Legende.OverlayId = createImageOverlay(self.bigmap.Legende.file);
    if self.bigmap.Legende.OverlayId == nil or self.bigmap.Legende.OverlayId == 0 then
        self.useLegend = false;
        print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorInitLegend")); 
    end;
	self.bigmap.Legende.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#width"), 0.15);
	self.bigmap.Legende.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#height"), 0.125);
	self.bigmap.Legende.legPosX = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#posX"), 0.0244);
	self.bigmap.Legende.legPosY = 1-Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.legende#posY"), 0.15);
	----
	
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
    self.bigmap.PoI.OverlayId = createImageOverlay(self.bigmap.PoI.file);
    if self.bigmap.PoI.OverlayId == nil or self.bigmap.PoI.OverlayId == 0 then
        self.usePoi = false;
        print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorInitPoI")); 
    end;
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
        
		self.bigmap.FNum.OverlayId = createImageOverlay(self.bigmap.FNum.file);
		if self.bigmap.FNum.OverlayId == nil or self.bigmap.FNum.OverlayId == 0 then
			self.useFNum = false;
            print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorInitFNum"));
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
	self.bigmap.IconSteerable.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconSteerable#file"), "icons/tractor.png"), self.moddir);
	self.bigmap.IconSteerable.filemp = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconSteerableCtrl#file"), "icons/tractorctrl.png"), self.moddir);
	self.bigmap.IconSteerable.OverlayId = createImageOverlay(self.bigmap.IconSteerable.file);
	self.bigmap.IconSteerable.mpOverlayId = createImageOverlay(self.bigmap.IconSteerable.filemp);
	self.bigmap.IconSteerable.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconSteerable#width"), 0.0078125);
	self.bigmap.IconSteerable.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconSteerable#height"), 0.0078125);
	----
    
	--Array für Geräteicons
	self.bigmap.IconAttachments = {};
	self.bigmap.IconAttachments.Icon = {front = {file = "", OverlayId = nil},rear={file = "", OverlayId = nil}};
	self.bigmap.IconAttachments.Icon.front.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachmentFront#file"), "icons/feldgeraet.png"), self.moddir);
	self.bigmap.IconAttachments.Icon.rear.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachmentRear#file"), "icons/feldgeraet.png"), self.moddir);
	self.bigmap.IconAttachments.Icon.front.OverlayId = createImageOverlay(self.bigmap.IconAttachments.Icon.front.file);
	self.bigmap.IconAttachments.Icon.rear.OverlayId = createImageOverlay(self.bigmap.IconAttachments.Icon.rear.file);
	self.bigmap.IconAttachments.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconAttachmentFront#width"), 0.0078125);
	self.bigmap.IconAttachments.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconAttachmentFront#height"), 0.0078125);
	----
    
	--Array für Infopanel
	self.bigmap.InfoPanel = {};
	self.bigmap.InfoPanel.background = {};
	self.bigmap.InfoPanel.background = {file = "", OverlayId = nil, width = 0.15, height= 0.125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.background.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel#file"), "gfx/Info_Panel.png"), self.moddir);
	self.bigmap.InfoPanel.background.OverlayId = createImageOverlay(self.bigmap.InfoPanel.background.file);
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
    self.bigmap.attachmentsTypes.names = {"cutter", "trailer", "sowingMachine", "plough", "sprayer", "bailer", "cultivator", "tedder", "windrower", "shovel", "mover", "other"};
    self.bigmap.attachmentsTypes.icons = {}
    self.bigmap.attachmentsTypes.overlays = {}
    
    for at=1, table.getn(self.bigmap.attachmentsTypes.names) do
        local tempIcon = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachment" .. self.bigmap.attachmentsTypes.names[at] .."#file"), "icons/courseplay.png"), self.moddir);
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
    self.bigmap.IconCourseplay.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#file"), "icons/courseplay.png"), self.moddir);
	self.bigmap.IconCourseplay.Icon.OverlayId = createImageOverlay(self.bigmap.IconCourseplay.Icon.file);
	self.bigmap.IconCourseplay.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#width"), 0.0078125);
	self.bigmap.IconCourseplay.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#height"), 0.0078125);
	----

	--Array für isBrokenIcon
	self.bigmap.iconIsBroken = {};
	self.bigmap.iconIsBroken.Icon = {};
    self.bigmap.iconIsBroken.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconIsBroken#file"), "icons/IsBroken.png"), self.moddir);
	self.bigmap.iconIsBroken.Icon.OverlayId = createImageOverlay(self.bigmap.iconIsBroken.Icon.file);
	self.bigmap.iconIsBroken.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#width"), 0.0078125);
	self.bigmap.iconIsBroken.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#height"), 0.0078125);
	----

	--Array für Bottle anzeige
    self.useBottles = true;
	self.bigmap.iconBottle = {};
	self.bigmap.iconBottle.Icon = {};
    self.bigmap.iconBottle.Icon.OverlayId = nil;
    self.bigmap.iconBottle.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconBottle#file"), "icons/Bottle.png"), self.moddir);
	self.bigmap.iconBottle.Icon.OverlayId = createImageOverlay(self.bigmap.iconBottle.Icon.file);
    if self.bigmap.iconBottle.Icon.OverlayId == nil or self.bigmap.iconBottle.Icon.OverlayId == 0 then
        self.useBottles = false;
        print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorInitBottles"));
    end;
	self.bigmap.iconBottle.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconBottle#width"), 0.0078125);
	self.bigmap.iconBottle.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconBottle#height"), 0.0156250);
	----
    
	--Array für Spielerinfos
	self.bigmap.player = {}; --
	self.bigmap.player.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconPlayer#file"), "icons/eigenerspieler.png"), self.moddir);
	self.bigmap.player.filemp = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconMPPlayer#file"), "icons/mpspieler.png"), self.moddir);
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
    -- Einstellungen nur laden wenn Datei bereits vorhanden ist
    ----
	-- ToDo: Nur Laden wenn nicht client im Multiplayer
	----
    print("MapViewer LoadOptions()");
    local path = getUserProfileAppPath() .. "savegame" .. g_careerScreen.selectedIndex .. "/mapviewer.xml";
    print(path);
    if mapviewer:file_exists(path) then
        mapviewer:LoadFromFile();
    else
    ----
	-- ToDo: Nur Speichern wenn nicht client im Multiplayer
	----
        mapviewer:SaveToFile();
    end;
	
	----
	-- Mapgroesse printen
	----
	print(g_i18n:getText("mapviewtxt") .. " : " .. string.format(g_i18n:getText("MV_InfoMapsize"), self.bigmap.mapDimensionX, self.bigmap.mapDimensionY));	--
	----
    print("MapViewer LoadOptions() beendet");
    ----
    
	----
	-- Initialisierung abgeschlossen
	print(string.format("|| %s || Initializing Complete ||", g_i18n:getText("mapviewtxt")));
	----

	self.mvInit = true;
end;

-- Find the length of a file
--   filename: file name
-- returns
--   len: length of file
--   asserts on error
function mapviewer:length_of_file(filename)
  local fh = assert(io.open(filename, "rb"))
  local len = assert(fh:seek("end"))
  fh:close()
  return len
end

-- Return true if file exists and is readable.
function mapviewer:file_exists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

----
-- Speichern der Einstellungen im Savegame Ordner
----
function mapviewer:SaveToFile()
    local path = getUserProfileAppPath() .. "savegame" .. g_careerScreen.selectedIndex .. "/";
    local mvxml = nil; 
    
    if not mapviewer:file_exists(path .. "MapViewer.xml") then
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

    mvxml = loadXMLFile("MapViewerXML", path .. "MapViewer.xml"); 
    
    if mvxml ~= nil then
        -- int
        self.bigmap.mapDimensionX = getXMLInt(mvxml, "mapviewer.map.mapSize#DimX");
        self.bigmap.mapDimensionY = getXMLInt(mvxml, "mapviewer.map.mapSize#DimY");
        
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
        print(g_i18n:getText("mapviewtxt") .. " : " .. g_i18n:getText("MV_ErrorLoadOptions"));
    end;
end;
----

--
-- Funkmtion zum  kopieren einer Tabelle in eine neue Tabelle, 
-- incl. Ausgabe der Datentypen, wenn Debug=TRUE
-- Parameter :
-- 
-- tab = zu kopierende Tabelle
-- parent = Übergeordnetes Element, für Ausgabe
--
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
function mapviewer:deleteMap()
end;


--
-- Funktionen für Netzwerk / Multiplayer Synchronisierung
--
function mapviewer:writeStream(streamId, connection)
end;

function mapviewer:readStream(streamId, connection)
end;

function mapviewer:mouseEvent(posX, posY, isDown, isUp, button)
	--Infopanel an Mousepos anzeigen
	local vehicle;
	local panelX, panelY, panelZ;
	if self.mapvieweractive then
		if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_LEFT) and not Input.isMouseButtonPressed(Input.MOUSE_BUTTON_RIGHT) then
			self.mouseX = posX;
			self.mouseY = posY;
			self.bigmap.InfoPanel.vehicleIndex, self.bigmap.InfoPanel.isVehicle, self.bigmap.InfoPanel.lastVehicle = self:vehicleInMouseRange();
			--print(self:vehicleInMouseRange());
			if self.bigmap.InfoPanel.lastVehicle ~= nil and type(self.bigmap.InfoPanel.lastVehicle) == "table" and self.bigmap.InfoPanel.vehicleIndex > 0 then
				-- self.bigmap.InfoPanel.vehicleIndex = vehicle;
				print(string.format("vehicleInMouseRange() - Fahrzeug in der Nähe : %d", self.bigmap.InfoPanel.vehicleIndex));
				self.showInfoPanel = true;
				-- panelX, panelY, panelZ = getWorldTranslation(g_currentMission.attachables[vehicle].rootNode);
				panelX, panelY, panelZ = getWorldTranslation(self.bigmap.InfoPanel.lastVehicle.rootNode);
				self.bigmap.InfoPanel.background.Pos.x = posX-0.0078125-0.0078125;
				self.bigmap.InfoPanel.background.Pos.y = posY;
				-- print(string.format("VehiclePos : %.3f, %.3f, %.3f || Node : %d ", panelX, panelY, panelZ, g_currentMission.steerables[vehicle].rootNode));
				self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle);
				-- print(table.show(self.bigmap.InfoPanel.Info, "vehicleInfo."));
			else
				self.showInfoPanel = false;
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
-- Ermitteln der Vehicle Informationen
----
function mapviewer:GetVehicleInfo(vehicle)
	-- local currV = g_currentMission.steerables[vehicle];
	local vehicleInfo = {Type = "", Ply= "", Tank = 0, Fruit = ""};
	local percent = 0;
	
	if vehicle ~= nil and type(vehicle) == "table" then
		vehicleInfo.Type = string.sub(Utils.getNoNil(vehicle.name, g_i18n:getText("MV_Unknown")), 0, 25); 
		
		if self.bigmap.InfoPanel.isVehicle then
			vehicleInfo.Ply = "SPIELER : " .. string.sub(Utils.getNoNil(vehicle.controllerName, g_i18n:getText("MV_EmptyTank")), 0, 20); 
			if vehicle.isHired then 
				vehicleInfo.Ply = vehicleInfo.Ply .. " [H]"
			end;
		-- TODO --
		-- Wenn Tractor, dann auf Anhänger usw. prüfen um den Füllstand zu ermitteln
		----
		else
			vehicleInfo.Ply = "Typ : " .. g_i18n:getText("MV_AttachType"..vehicle.typeName); --"Attachable";
		end;
				
		-- Füllstand ermitteln
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
		
	end;
	return vehicleInfo;
end;
----

----
-- Panel anzeigen
----
function mapviewer:ShowPanelonMap()
	if self.showInfoPanel then
		--local vehicleInfo = {Type = "", Ply= "", Tank = 0, Fruit = ""};
		local tX, tY, tLeft, tRight, tTop;
		tX = self.bigmap.InfoPanel.background.Pos.x;
		tY = self.bigmap.InfoPanel.background.Pos.y;
		tTop = tY + self.bigmap.InfoPanel.background.height - 0.020;
		tLeft = tX + 0.005; 
		
		--print(table.show(self.bigmap.InfoPanel.Info, "vehicleInfo."));
		
		renderOverlay(self.bigmap.InfoPanel.background.OverlayId, self.bigmap.InfoPanel.background.Pos.x, self.bigmap.InfoPanel.background.Pos.y, self.bigmap.InfoPanel.background.width, self.bigmap.InfoPanel.background.height);

		local v = self.bigmap.InfoPanel.lastVehicle;
		setTextBold(true);
		--MV_Unknown
		setTextColor(0, 0, 0, 1);
		renderText(tLeft, tTop, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info.Type, g_i18n:getText("MV_Unknown"))));
		renderText(tLeft, tTop-0.020, 0.012, string.format("%s", Utils.getNoNil(tostring(self.bigmap.InfoPanel.Info.Ply), g_i18n:getText("MV_Unknown"))));
		if self.bigmap.InfoPanel.lastVehicle ~= nil then
			if self.bigmap.InfoPanel.lastVehicle.grainTankCapacity ~= nil then -- and self.bigmap.InfoPanel.lastVehicle.grainTankCapacity > 0 then
				renderText(tLeft, tTop-0.040, 0.012, string.format("Füllstand : "));
				renderText(tLeft, tTop-0.060, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info.Tank, g_i18n:getText("MV_Unknown"))));
				renderText(tLeft, tTop-0.080, 0.012, string.format("Ladung : %s", Utils.getNoNil(self.bigmap.InfoPanel.Info.Fruit, g_i18n:getText("MV_Unknown"))));
			elseif self.bigmap.InfoPanel.lastVehicle.capacity ~= nil then -- and self.bigmap.InfoPanel.lastVehicle.capacity > 0 then
				renderText(tLeft, tTop-0.040, 0.012, string.format("Füllstand : "));
				renderText(tLeft, tTop-0.060, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info.Tank, g_i18n:getText("MV_Unknown"))));
				renderText(tLeft, tTop-0.080, 0.012, string.format("Ladung : %s", Utils.getNoNil(self.bigmap.InfoPanel.Info.Fruit, g_i18n:getText("MV_Unknown"))));
			elseif self.bigmap.InfoPanel.lastVehicle:getAttachedTrailersFillLevelAndCapacity() then
				renderText(tLeft, tTop-0.040, 0.012, string.format("Füllstand : "));
				renderText(tLeft, tTop-0.060, 0.012, string.format("%s", Utils.getNoNil(self.bigmap.InfoPanel.Info.Tank, g_i18n:getText("MV_Unknown"))));				
			end;
		end;
		setTextColor(1, 1, 1, 0);
		setTextBold(false);
		
	end;
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
	-- print("----");

	return index, isVehicle, currV;	
end;
----

--
-- Auf Tastendruck reagieren
--
function mapviewer:keyEvent(unicode, sym, modifier, isDown)
    ----
	-- Tatse um den Debugmodus zu aktivieren
	-- ALT+d
    ----
	-- if isDown and sym == Input.KEY_d and bitAND(modifier, Input.MOD_ALT) > 0 then
		--self.Debug=not self.Debug;
		--print("Debug = "..tostring(self.Debug));
		-- self:listTipTriggers();
		-- if not connection:getIsServer() then
			-- print("Server Aktiv");
		-- else
			-- print("Client Aktiv");
		-- end;
		
		-- if self.isServer then print("Server Aktiv"); end;
		-- if self.isClient then print("Server Aktiv"); end;
	-- end;
    ----
	
	-- Umschalten der Mapgrösse für 2048 (Standard) und 4096
    ----
	-- ToDo: Kann entfernt werden wenn MP Fehler behoben
	--       Globale Kartengröße verwenden !
	----

	if isDown and sym == Input.KEY_m and bitAND(modifier, Input.MOD_ALT) > 0 then
		if self.bigmap.mapDimensionX == 2048 then
			self.bigmap.mapDimensionX = 4096;
			self.bigmap.mapDimensionY = 4096;
		else
			self.bigmap.mapDimensionX = 2048;
			self.bigmap.mapDimensionY = 2048;
		end;
        print(g_i18n:getText("mapviewtxt") .. " : " .. string.format(g_i18n:getText("MV_InfoMapsize"), self.bigmap.mapDimensionX, self.bigmap.mapDimensionY));
		print();
        mapviewer:SaveToFile();
	end;
	
	----
end;

--
-- Update Funktion
--
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
		self.mapvieweractive=not self.mapvieweractive;
		if self.mapvieweractive then
			g_mouseControlsHelp.active = false;
			InputBinding.setShowMouseCursor(true);
			InputBinding.wrapMousePositionEnabled = false;
			if (g_currentMission.player.isEntered) then
				g_currentMission.player.isFrozen = true;
			end;
		else
			g_mouseControlsHelp.active = true;
			InputBinding.setShowMouseCursor(false);
			InputBinding.wrapMousePositionEnabled = true;
			if (g_currentMission.player.isEntered) then
				g_currentMission.player.isFrozen = false;
			end;
		end;
	end;
	--Taste für Legende einblenden
	if InputBinding.hasEvent(InputBinding.BIGMAP_Legende) then
		if self.mapvieweractive and self.useLegend then
			--Legende einblenden
			self.maplegende = not self.maplegende;
            mapviewer:SaveToFile();
		end;
	end;

	--Overlay wechseln
	if InputBinding.hasEvent(InputBinding.BIGMAP_SwitchOverlay) then
		self.numOverlay = self.numOverlay+1;

        ----
        -- Überprüfen ob Feldnummern und PoI benutz werden können
        ----
        if not self.useFNum or not self.usePoi or not self.useBottles then
            if self.numOverlay == 1 and not self.useFNum then
                self.numOverlay = self.numOverlay+1;
            end;
            if self.numOverlay == 2 and not self.usePoi then
                self.numOverlay = self.numOverlay+1;
            end;
            if self.numOverlay == 3 then
                self.numOverlay = self.numOverlay+1;
            end;
            if self.numOverlay == 5 and not self.useBottles then
                self.numOverlay = self.numOverlay+1;
            end;
        end;
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
			self.showFNum = true;
		elseif self.numOverlay == 2 then	--nur PoI
            self.showPoi = true;
		elseif self.numOverlay == 3 then	--Poi und Nummern
			self.showPoi = true;
			self.showFNum = true;
		elseif self.numOverlay == 4 then	--Courseplay Kurse anzeigen
			self.showCP = true;
		elseif self.numOverlay == 5 then	--Bottlefinder anzeigen
            self.showBottles = true;
		else
			self.numOverlay = 0;		--Alles aus
			self.showPoi = false;
			self.showFNum = false;
            self.showCP = false;
            self.showBottles = false;
		end;

		if self.Debug then
			print("Debug Key BIGMAP_SwitchOverlay: ");
            print(string.format("|| $s || %s : %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_Mode" .. self.numOverlay), g_i18n:getText("MV_Mode".. self.numOverlay .."Name")));
		end;
        mapviewer:SaveToFile();
	end;
	
	----
	-- Panel Position an Fahrzeug anpassen
	----
	if self.mapvieweractive and self.showInfoPanel then
		if self.bigmap.InfoPanel.lastVehicle ~= nil and type(self.bigmap.InfoPanel.lastVehicle) == "table" then
			local posX1, posY1, posZ1 = getWorldTranslation(self.bigmap.InfoPanel.lastVehicle.rootNode);
			local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth); -- +self.bigmap.mapPosX;
			local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight); -- +self.bigmap.mapPosY;
			
			self.bigmap.InfoPanel.background.Pos.x = distancePosX-0.0078125-0.0078125;
			self.bigmap.InfoPanel.background.Pos.y = distancePosZ;
			
			self.bigmap.InfoPanel.Info = {};
			self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle); -- self.bigmap.InfoPanel.vehicleIndex

		else
			selfShowInfoPanel = false;
			print("--\nFehler in Update() - showInfoPanel\n--");
		end;	
	end;	
	----
	
	--BigMap Transparenz erhöhen und verringern
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransMinus) then
		if self.bigmap.mapTransp < 1 then
			self.bigmap.mapTransp = self.bigmap.mapTransp + 0.05;
		end;
        mapviewer:SaveToFile();
	end;
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransPlus) then
		if self.bigmap.mapTransp > 0.1 then
			self.bigmap.mapTransp = self.bigmap.mapTransp - 0.05;
		end;
        mapviewer:SaveToFile();
	end;
	-- ende Transparenz umschalten
end;

---- Trigger Array
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

function mapviewer:draw()
	if self.mapvieweractive then
		if self.bigmap.OverlayId.ovid ~= nil and self.bigmap.OverlayId.ovid ~= 0 then
			setOverlayColor(self.bigmap.OverlayId.ovid, 1,1,1,self.bigmap.mapTransp);
			renderOverlay(self.bigmap.OverlayId.ovid, self.bigmap.mapPosX, self.bigmap.mapPosY, self.bigmap.mapWidth, self.bigmap.mapHeight);
		else
			renderText(0.25, 0.5-0.03, 0.024, string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMV")));
			if self.Debug then
                print("----");
				print("Debug: :draw()");
				print(string.format("self.useMapFile: %s", tostring(self.useMapFile)));
				print(string.format("self.bigmap.file: %s", self.bigmap.file));
				print(string.format("self.bigmap.OverlayId.ovid: %d", self.bigmap.OverlayId.ovid));
                print("----");
			end;
            self.mapvieweractive = false;
		end;
		if self.mapvieweractive and not self.maplegende then
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_Legende"), InputBinding.BIGMAP_Legende);
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_TransPlus"), InputBinding.BIGMAP_TransPlus);
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_TransMinus"), InputBinding.BIGMAP_TransMinus);
			g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_SwitchOverlay"), InputBinding.BIGMAP_SwitchOverlay);
		end;

		--Aktuelle Transparenz und Copyright
		setTextColor(1, 1, 1, 1);
		renderText(0.5-0.0273, 1-0.03, 0.020, string.format("Transparenz\t%d", self.bigmap.mapTransp * 100));
		renderText(0.5-0.035, 0.03, 0.018, g_i18n:getText("mapviewtxt"));
		setTextColor(1, 1, 1, 0);
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
		if self.usePoi and self.showPoi then
			if self.bigmap.PoI.OverlayId ~= nil and self.bigmap.PoI.OverlayId ~= 0 then
				renderOverlay(self.bigmap.PoI.OverlayId, self.bigmap.PoI.poiPosX, self.bigmap.PoI.poiPosY, self.bigmap.PoI.width, self.bigmap.PoI.height);
			else
                string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorPoICreateOverlay"))
				self.usePoi = not self.usePoi;
			end;
		end;
        ----
		
		--Fieldnumbers
		if self.useFNum and self.showFNum then
			if self.bigmap.FNum.OverlayId ~= nil and self.bigmap.FNum.OverlayId ~= 0 then
				renderOverlay(self.bigmap.FNum.OverlayId, self.bigmap.FNum.FNumPosX, self.bigmap.FNum.FNumPosY, self.bigmap.FNum.width, self.bigmap.FNum.height);
			else
                string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorFNumCreateOverlay"))
				self.useFNum = not self.useFNum;
			end;
		end;
        ----

		--Bottles
		if self.showBottles and self.useBottles then
			if self.bigmap.iconBottle.Icon.OverlayId ~= nil and self.bigmap.iconBottle.Icon.OverlayId ~= 0 then
                for i=1, table.getn(g_currentMission.missionMapBottleTriggers) do
                    local bottleFound=string.byte(g_currentMission.foundBottles, i);
                    if bottleFound==48 then
                        self.posX, self.posY, self.posZ=getWorldTranslation(g_currentMission.missionMapBottleTriggers[i]);
                        self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
                        self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
                        
                        renderOverlay(self.bigmap.iconBottle.Icon.OverlayId,
                                    self.buttonX-self.bigmap.iconBottle.width/2, 
                                    self.buttonZ-self.bigmap.iconBottle.height/2, 
                                    self.bigmap.iconBottle.width, 
                                    self.bigmap.iconBottle.height);
                    end;
                end;
			else
                string.format("|| $s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorBottlesCreateOverlay"))
				self.useBottles = not self.useBottles;
			end;
		end;
        ----
		
		--Maplegende anzeigen
		if self.maplegende and self.useLegend then
				----
				-- TODO : Liste der Legende durch Schleife jagen
				----
			if self.bigmap.Legende.OverlayId ~=nil then
				renderOverlay(self.bigmap.Legende.OverlayId, self.bigmap.Legende.legPosX, self.bigmap.Legende.legPosY, self.bigmap.Legende.width, self.bigmap.Legende.height);
				setTextColor(0, 0, 0, 1);
				--Icons in Legende erstellen
				self.l_PosY = 1-0.02441 - 0.007324 - 0.015625; -- 1-50-15-32
				--Eigener Spieler Icon
				renderOverlay(self.bigmap.player.ArrowOverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY, 
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, g_i18n:getText("MV_LegendeLocalPlayer"));
				--Andere Spieler Icon
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.player.mpArrowOverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, g_i18n:getText("MV_LegendeOtherPlayer"));
				--Spieler auf Fahrzeug
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.IconSteerable.mpOverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, g_i18n:getText("MV_LegendeControledVehicle"));
				--Leere Fahrzeug
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.IconSteerable.OverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, g_i18n:getText("MV_LegendeEmptyVehicle"));
				--Anbaugeräte, Anhänger
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.IconAttachments.Icon.front.OverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, g_i18n:getText("MV_LegendeAttachments"));
                ----
                -- Legende der Attachment Typen anzeigen
                ----
                setTextColor(0, 1, 0, 1);
                self.l_PosY = 1-0.02441 - 0.007324 - 0.015625 - self.bigmap.Legende.height;
                for lg=1, table.getn(self.bigmap.attachmentsTypes.names) do
                    renderOverlay(self.bigmap.attachmentsTypes.overlays[self.bigmap.attachmentsTypes.names[lg]],
                                    self.bigmap.Legende.legPosX + 0.007324,
                                    self.l_PosY, 
                                    self.bigmap.attachmentsTypes.width,
                                    self.bigmap.attachmentsTypes.height);
                    renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.016, g_i18n:getText("MV_AttachType" .. self.bigmap.attachmentsTypes.names[lg]));
                    self.l_PosY = self.l_PosY - 0.020;
                end;
                ----
				setTextColor(1, 1, 1, 0);
                
			end;	--if legende nicht NIL
            ----
            -- DONE Wenn legende fehlerhaft, Meldung ausgeben
            ----
		elseif self.bigmap.Legende.OverlayId == nil or self.bigmap.Legende.OverlayId == 0 then
			renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Rendern der Legende Fehlgeschlagen");
			print(g_i18n:getText("mapviewtxt") .. " : Rendern der Maplegende fehlgeschlagen");
			print(g_i18n:getText("mapviewtxt") .. " : Error rendering map legend");
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
		--Hotspots auf grosse Karte
		----
		for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
			self.hsWidth = g_currentMission.missionPDA.hotspots[j].width;
			self.hsHeight = g_currentMission.missionPDA.hotspots[j].height;
			self.hsPosX = (g_currentMission.missionPDA.hotspots[j].xMapPos/self.bigmap.mapDimensionX)-(self.hsWidth/2);
			self.hsPosY = 1-(g_currentMission.missionPDA.hotspots[j].yMapPos/self.bigmap.mapDimensionY);--self.hsHeight;
			self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;
			renderOverlay(self.hsOverlayId, self.hsPosX, self.hsPosY, self.hsWidth, self.hsHeight);
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
                renderOverlay(self.bigmap.attachmentsTypes.overlays[g_currentMission.attachables[i].typeName],
                                self.buttonX-self.bigmap.attachmentsTypes.width/2, 
                                self.buttonZ-self.bigmap.attachmentsTypes.height/2,
                                self.bigmap.attachmentsTypes.width,
                                self.bigmap.attachmentsTypes.height);
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
		-- InfoPanel anzeigen
		----
		setTextColor(0, 0, 0, 1);
		renderText(0.020, 0.090, 0.020, string.format("Mouse Pos : x:%.3f / y:%.3f",self.mouseX,self.mouseY));
		setTextColor(1, 1, 1, 0);
		if self.showInfoPanel then
			self.bigmap.InfoPanel.Info = {};
			self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle); -- self.bigmap.InfoPanel.vehicleIndex
			
			self:ShowPanelonMap();
		end;
		----
	else
		g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_Activate"), InputBinding.BIGMAP_Legende);
	end;
	----
	-- Namen auf PDA anzeigen
	----
    ----
    -- TODO: Alle Spieler auf PDA anzeiegn
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

addModEventListener(mapviewer);