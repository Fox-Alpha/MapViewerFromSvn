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
----
-- Globale ToDos :
----
-- GetNoNil aus den Aufrufen von getText entfernen oder gegen eigene Funktion ersetzten
-- Übersetzungen prüfen
----
-- Testen:
----
-- 
----
-- Übersetzungen :
----
-- TODO: Selbstfahrspritze ist selfpropeleredsprayer / de fehlt || Filtype fehlt
-- TODO: typ Implement, dann Typ=Name, Optional Typ vergleichen (Gewicht, Schild, Ballengabel, Palettengabel)
-- TODO: saat in Maschine, Ausgewählte Saat !
-- TODO: Miststreuer ist manuresprayder
-- TODO: Ladewagen (Gras) ist foragewagon
-- TODO: Güllefass ist Sprayer_animated
-- TODO: Hecksler und Maisgebiss ist cutter_animated
-- TODO: Mähwerk ist mower
-- TODO: Ballensammler ist Name=automatic Baleloader, Typ baleLoader
-- TODO: Schaufel Name=shovel
-- TODO: Palletengabel angehängt ist Implement
-- TODO: Type combine_cilyndered
-- TODO: cultivator_animated muss grubber
-- TODO: auf weitere LS2013 Fahrzeugtypen für Legende prüfen
----
----
-- Globale Fix für Release 0.8
----
-- Beste Verkaufsstelle und besten Preis ermitteln für Hofsilos
-- Milchtruck Position im MP anzeigen. Wird vom Server gesteuert
----

----
-- Hauptfunktion zum Laden des Mods
----
function mapviewer:loadMap(name)

	local userXMLPath = Utils.getFilename("mapviewer.xml", mapviewer.moddir);
	self.xmlFile = loadXMLFile("xmlFile", userXMLPath);
	
	self.mapvieweractive=false;
	self.maplegende = false;
	self.activePlayerNode=0;
	self.mvInit = false;
	
	self.showFNum = false;
	self.showPoi = false;
    self.showCP = false;
    self.showHorseShoes = false;
    self.showInfoPanel = false;
	self.showHotSpots = false;
	self.showTipTrigger = false;
	self.showKeyHelp = false;
	self.showVehicles = true;
	self.showFieldStatus = false;
	
	----
	--	Test eines Overlays für das Felderwachstum und Fruchtsorten pro Feld
	----
	self.showFoliageState = true;
	
	self.mv_FoliageStateOverlays = 0;
	self.growthGrowingColors = {
		{
			0,
			0.45,
			1,
			1
		},
		{
			0,
			0.31,
			0.86,
			1
		},
		{
			0,
			0.2,
			0.7,
			1
		},
		{
			0,
			0.1,
			0.6,
			1
		}
	}
	self.growthReadyToHarvestColors = {
	{
		0,
		0.9,
		0.1,
		1
	},
	{
		0,
		0.7,
		0.1,
		1
	},
	{
		0,
		0.5,
		0.2,
		1
	}
	}
	self.growthReadyToPrepareColor = {
		0.1,
		1,
		0.8,
		1
	}
	self.growthWitheredColor = {
		0.7,
		0,
		0.1,
		1
	}
	--self.mv_FoliageStateOverlays = createFoliageStateOverlay("foliageState", 256, 256)
	----
    
    self.useHorseShoes = true;
    self.useLegend = true;
	self.useTeleport = false;
	self.useHotSpots = true;
	self.useTipTrigger = true;
    self.useCoursePlay = false;
	self.useRentAField = false;
	self.useFieldStatus = true;
	
	self.setNewPlyPosition = false;
    
	self.numOverlay = 0;

	self.mapPath = 0;
	self.useDefaultMap = false;
	self.mapName = "";
    
	
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
	
	----
	--	F1 Hilfe aktiv ?
	----
	self.showHelpTxt = false
	----
	
	----
	-- Debug Modus
	----
	self.Debug = {};
	self.Debug.active = false;
	self.Debug.printHotSpots = true;
	self.Debug.printHorseShoes = false;
	self.Debug.printPanelTable = false;
	self.Debug.printFieldNumbers = false;
	----
	
	self.mv_Error = false;
	
	----
	-- Workaround um in den Steerable den Namen als .name einzubinden
	----
	local aNameSearch = {"vehicle.name." .. g_languageShort, "vehicle.name.en", "vehicle#type"};
	
	if Steerable.load ~= nil then
		local orgSteerableLoad = Steerable.load
		
		Steerable.load = function(self,xmlFile)
			orgSteerableLoad(self,xmlFile)
			
			for nIndex,sXMLPath in pairs(aNameSearch) do 
				self.name = getXMLString(xmlFile, sXMLPath);
				if self.name ~= nil then break; end;
			end;
			if self.name == nil then self.name = g_i18n:getText("UNKNOWN") end;
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
		end
	end;
	----
end;
----

----
-- Grundwerte des Mods setzen
-- Laden und erstellen der Overlays, usw.
----
function mapviewer:initMapViewer()
    print(string.format("|| %s || Starting ... ||", g_i18n:getText("mapviewtxt")));
    
	----
	-- Initialisierung beginnen
	----
	
	print(string.format("|| %s || Initialising ... ||", g_i18n:getText("mapviewtxt")));

	----
	-- Modname und Modverzeichnis (zip) ermitteln
	----
	if self.modName == nil then
		self.modName, self.modBaseDirectory = Utils.getModNameAndBaseDirectory(self.moddir .. "modDesc.xml");
	end;
	----
	
	self.bigmap.OverlayId = {};
    self.bigmap.PoI = {};
    self.bigmap.FNum = {};

	self.bigmap.mapWidth = 1;
	self.bigmap.mapHeight = 1;
	self.bigmap.mapPosX = 0.5-(self.bigmap.mapWidth/2);
	self.bigmap.mapPosY = 0.5-(self.bigmap.mapHeight/2);
	self.bigmap.mapTransp = 1;
	
	----
	-- Wenn keine vorgegebene Datei als Karte verwendet werden soll
	----
	if g_currentMission.missionInfo.map.baseDirectory ~= nil then
		self.mapPath = g_currentMission.missionInfo.map.baseDirectory;
	else
		self.mapPath = "";
	end;
	----
	
	-- TODO: Prüfen was mit der DediServerInfo gemacht werden kann
	-- g_dedicatedServerInfo

    ----
    -- Prüfen ob es sich um die Standard Karte handelt
    ----
	self.mapName = g_currentMission.missionInfo.map.title;
	
	-- Table, um auch alternative Pfade nach der pda_map zu durchsuchen
	local pdaPath = {};
	
	----
	-- Wenn der Pfad leer ist, dann handelt es sich um die Standard Map
	-- In diesem Fall erst einmal den Pfad zur mitgelieferten PDA setzen.
	-- Andernfalls in der zip der Karte auch die am häufigsten verwendeten Pfade durchsuchen
	----
    if self.mapPath == "" then
        self.mapPath = self.moddir;
        self.useDefaultMap = true;
		self.bigmap.file = Utils.getFilename("mv_pda_hagenstedt.dds", self.moddir);
    else
		----
		-- am häufigsten verwendeten Pfade
		----
		table.insert(pdaPath, {file="pda_map.dds", path=self.mapPath});					--[hauptverzeichnis]/
		table.insert(pdaPath, {file="pda_map.dds", path=self.mapPath.."map01/"});		--[hauptverzeichnis]/map01/ 
		table.insert(pdaPath, {file="pda_map.dds", path=self.mapPath.."map/map01/"});	--[hauptverzeichnis]/map/map01/
		
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_InfoTryLocatePDAFile")));
		local pdaI = 1;
		----
		
		----
		-- Alternative Pfade für pda_map.dds prüfen
		----
		for _,pdamap in pairs(pdaPath) do
			if fileExists(Utils.getFilename(pdaPath[pdaI].file, pdaPath[pdaI].path)) then
				self.bigmap.file = pdaPath[pdaI].path..pdaPath[pdaI].file;
				print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_InfoPDAFileLocated")));
				break;
			end;
			pdaI = pdaI+1;
		end;
		----
    end;
	----

	----
	-- Globale Kartengröße verwenden
	-----
	if g_currentMission.terrainSize ~= 2050 then	
		g_currentMission.missionPDA.worldSizeX = 4096;
		g_currentMission.missionPDA.worldSizeZ = 4096;
		g_currentMission.missionPDA.worldCenterOffsetX = g_currentMission.missionPDA.worldSizeX*0.5;
		g_currentMission.missionPDA.worldCenterOffsetZ = g_currentMission.missionPDA.worldSizeZ*0.5;
	end;
	
    self.bigmap.mapDimensionX = g_currentMission.missionPDA.worldSizeX;
    self.bigmap.mapDimensionY = g_currentMission.missionPDA.worldSizeZ;
	----
	
	----
	-- Mapname printen
	-- Mapgroesse printen
	----
	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), string.format(g_i18n:getText("MV_MapName"), g_currentMission.missionInfo.map.title)));
	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), string.format(g_i18n:getText("MV_InfoMapsize"), self.bigmap.mapDimensionX, self.bigmap.mapDimensionY)));
	----

	-----
    self.bigmap.PoI.width = 1;
    self.bigmap.PoI.height = 1;
    self.bigmap.FNum.width = 1;
    self.bigmap.FNum.height = 1;
	----
	
	----
	-- Startwert der Transparenz
	----
	self.bigmap.mapTransp = 1;
	----

	----
	-- Debug ausgaben
	----
	if self.Debug.active then
		print(string.format("--Debug:--"));
		print(string.format("self.bigmap.file: %s", self.bigmap.file));
		print(string.format("self.bigmap.OverlayId.ovid: %s", tostring(self.bigmap.OverlayId.ovid)));
		print(string.format("Map Pfad : %s", self.mapPath));
		print(string.format("MapsUtil.idToMap[]: %s", tostring(MapsUtil.idToMap[g_currentMission.missionInfo.mapId].baseDirectory)));
		print(string.format("g_currentMission.missionInfo.map.baseDirectory: %s", tostring(g_currentMission.missionInfo.map.baseDirectory)));
		print(string.format("g_currentMission.BaseDirectory: %s", tostring(g_currentMission.baseDirectory)));
		print(string.format("self.modDir: %s", tostring(self.moddir)));
		print(string.format("self.modName: %s", tostring(self:getModName(self.moddir))));
		print(string.format("self.modBaseDirectory: %s", tostring(self.modBaseDirectory)));
		print(string.format("Overlay  : %s", tostring(self.bigmap.OverlayId.ovid)));
		print(string.format("----"));
		--print(string.format("--Tip Triggers--"));
		--self:listTipTriggers();
		--print(string.format("--Tip Triggers--"));
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
    
	----
	-- Array für Infopanel
	----
	self.bigmap.InfoPanel = {};
	self.bigmap.InfoPanel.width = 0.15;								--	Standard Breite des Panels
	self.bigmap.InfoPanel.height = 0.0078125+0.125+0.03125;			--	Höhe des Panels, wird berechnet. Standard: Top+Mitte+Bottom
	
	----
	--	Obere Panel Grafiken
	----
	self.bigmap.InfoPanel.top = {};
	self.bigmap.InfoPanel.top.image = {file = "", OverlayId = nil, width = 0.15, height= 0.0078125, Pos = {x=0, y=0}};
	
	self.bigmap.InfoPanel.top.closebar = {file = "", OverlayId = nil, width = 0.15, height= 0.0078125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.top.closebar.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelTop.CloseBarTop#file"), "panel/Info_Panel_closebar_top.dds"), self.moddir);
	self.bigmap.InfoPanel.top.closebar.OverlayId = createImageOverlay(self.bigmap.InfoPanel.top.closebar.file);
	
	self.bigmap.InfoPanel.top.bubbleleft = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.top.bubbleleft.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelTop.BubbleTopLeft#file"), "panel/Info_Panel_bubble_topleft.dds"), self.moddir);
	self.bigmap.InfoPanel.top.bubbleleft.OverlayId = createImageOverlay(self.bigmap.InfoPanel.top.bubbleleft.file);
	
	self.bigmap.InfoPanel.top.bubblemid = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.top.bubblemid.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelTop.BubbleTopMid#file"), "panel/Info_Panel_bubble_topmid.dds"), self.moddir);
	self.bigmap.InfoPanel.top.bubblemid.OverlayId = createImageOverlay(self.bigmap.InfoPanel.top.bubblemid.file);
	
	self.bigmap.InfoPanel.top.bubbleright = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.top.bubbleright.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelTop.BubbleTopRight#file"), "panel/Info_Panel_bubble_topright.dds"), self.moddir);
	self.bigmap.InfoPanel.top.bubbleright.OverlayId = createImageOverlay(self.bigmap.InfoPanel.top.bubbleright.file);
	----
	
	----
	--	Paneltext Hintergrund
	----
	self.bigmap.InfoPanel.background = {};
	self.bigmap.InfoPanel.background = {file = "", OverlayId = nil, width = 0.15, height = 0.125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.background.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBackground#file"), "panel/Info_Panel_bg.dds"), self.moddir);
	self.bigmap.InfoPanel.background.OverlayId = createImageOverlay(self.bigmap.InfoPanel.background.file);
	----
	
	----
	--	Untere Panel Grafiken
	----
	self.bigmap.InfoPanel.bottom = {};
	self.bigmap.InfoPanel.bottom.image = {file = "", OverlayId = nil, width = 0.15, height= 0.0078125, Pos = {x=0, y=0}};
	
	self.bigmap.InfoPanel.bottom.closebar = {file = "", OverlayId = nil, width = 0.15, height= 0.0078125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.bottom.closebar.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBottom.CloseBarBottom#file"), "panel/Info_Panel_closebar_Bottom.dds"), self.moddir);
	self.bigmap.InfoPanel.bottom.closebar.OverlayId = createImageOverlay(self.bigmap.InfoPanel.bottom.closebar.file);
	
	self.bigmap.InfoPanel.bottom.bubbleleft = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.bottom.bubbleleft.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBottom.BubbleBottomLeft#file"), "panel/Info_Panel_bubble_Bottomleft.dds"), self.moddir);
	self.bigmap.InfoPanel.bottom.bubbleleft.OverlayId = createImageOverlay(self.bigmap.InfoPanel.bottom.bubbleleft.file);
	
	self.bigmap.InfoPanel.bottom.bubblemid = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.bottom.bubblemid.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBottom.BubbleBottomMid#file"), "panel/Info_Panel_bubble_Bottommid.dds"), self.moddir);
	self.bigmap.InfoPanel.bottom.bubblemid.OverlayId = createImageOverlay(self.bigmap.InfoPanel.bottom.bubblemid.file);
	
	self.bigmap.InfoPanel.bottom.bubbleright = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
	self.bigmap.InfoPanel.bottom.bubbleright.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.Infopanel.InfoPanelBottom.BubbleBottomRight#file"), "panel/Info_Panel_bubble_Bottomright.dds"), self.moddir);
	self.bigmap.InfoPanel.bottom.bubbleright.OverlayId = createImageOverlay(self.bigmap.InfoPanel.bottom.bubbleright.file);
	----
	
	--Array für Hinweisesymbole
	self.bigmap.InfoPanel.Hints = {};
	self.bigmap.InfoPanel.Hints.Icons = {
										critical = {
												file = "", OverlayId = nil, height = 0, width = 0}, 
										warning = {
												file = "", OverlayId = nil, height = 0, width = 0}
										};
										
	self.bigmap.InfoPanel.Hints.Icons.critical.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.InfoPanel.InfoPanelHintIcons.HintCritical#file"), "icons/critical.dds"), self.moddir);
	self.bigmap.InfoPanel.Hints.Icons.warning.file  = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.InfoPanel.InfoPanelHintIcons.HintWarning#file"), "icons/warning.dds"), self.moddir);
	
	self.bigmap.InfoPanel.Hints.Icons.critical.OverlayId = createImageOverlay(self.bigmap.InfoPanel.Hints.Icons.critical.file);
	self.bigmap.InfoPanel.Hints.Icons.warning.OverlayId  = createImageOverlay(self.bigmap.InfoPanel.Hints.Icons.warning.file);
	
	self.bigmap.InfoPanel.Hints.Icons.critical.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.InfoPanel.InfoPanelHintIcons.HintCritical#height"), 0.0078125);
	self.bigmap.InfoPanel.Hints.Icons.warning.height  = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.InfoPanel.InfoPanelHintIcons.HintWarning#height" ), 0.0078125);
	
	self.bigmap.InfoPanel.Hints.Icons.critical.width = Utils.getNoNil(getXMLFloat(self.xmlFile,	"mapviewer.map.InfoPanel.InfoPanelHintIcons.HintCritical#width"), 0.0078125);
	self.bigmap.InfoPanel.Hints.Icons.warning.width  = Utils.getNoNil(getXMLFloat(self.xmlFile,	"mapviewer.map.InfoPanel.InfoPanelHintIcons.HintWarning#width"), 0.0078125);	
	----
	
	
	-- Informationen die angezeigt werden
	self.bigmap.InfoPanel.Info = {Type = "", Ply = "", Tank = 0, Fruit = ""};

	--- Fahrzeug Informationen
	self.bigmap.InfoPanel.vehicleIndex = 0;
	self.bigmap.InfoPanel.isVehicle = false;
	self.bigmap.InfoPanel.lastVehicle = {};

	--- Trigger Informationen
	self.bigmap.InfoPanel.triggerIndex = 0;
	self.bigmap.InfoPanel.isTrigger = false;
	self.bigmap.InfoPanel.lastTrigger = {};
	self.bigmap.InfoPanel.triggerType = {	
											"StationTrigger",	-- Verkaufsstellen
											"FarmTrigger", 		-- HofSilos
											"BGA", 				-- BGA Lager ?
											"GAS", 				-- Tankstellen	
											"FieldTrigger",		-- Feldnummern
											"Other",			-- Alles andere
										};
	self.bigmap.InfoPanel.isField = false;
	self.bigmap.InfoPanel.lastField = {};
	self.bigmap.InfoPanel.fieldIndex = 0;
	----
	
	----
	--	DEBUG: InfoPanel Daten
	----
	if self.Debug.active and self.Debug.printPanelTable then
		print(table.show(self.bigmap.InfoPanel, "InfoPanel"));
	end;
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
    
	-- TODO: Typen an LS 2013 anpassen
    self.bigmap.attachmentsTypes = {};
    --self.bigmap.attachmentsTypes.names = {"cutter", "trailer", "sowingMachine", "plough", "sprayer", "baler", "baleLoader", "cultivator", "tedder", "windrower", "shovel", "mower", "cultivator_animated", "selfPropelledSprayer", "cutter_animated", "sprayer_animated", "manureSpreader", "forageWagon", "other"};
	
	self.bigmap.attachmentsTypes.names = {"waterTrailer", "cultivator_animated", "selfPropelledPotatoHarvester", "mower_animated", "selfPropelledSprayer", "baleLoader", "milktruck", "trailer_mouseControlled", "baler", "dynamicMountAttacherImplement", "cart", "selfPropelledMixerWagon", "trailer", "plough", "sowingMachine_animated", "trafficVehicle", "implement_animated", "telehandler", "fuelTrailer", "ridingMower", "attachableCombine", "wheelLoader", "dynamicMountAttacherTrailer", "defoliator_animated", "implement", "tractor_cylindered", "windrower", "forageWagon", "sowingMachine", "tractor", "manureBarrel", "mower", "manureSpreader", "sprayer", "shovel_animated", "sprayer_mouseControlled", "cultivator", "sprayer_animated", "cutter_animated", "tractor_articulatedAxis", "cutter", "mixerWagon", "combine_cylindered", "strawBlower", "selfPropelledMower", "combine", "frontloader", "tedder", "shovel"};
    self.bigmap.attachmentsTypes.icons = {}
    self.bigmap.attachmentsTypes.overlays = {}
    
    for at=1, table.getn(self.bigmap.attachmentsTypes.names) do
        local tempIcon = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconAttachment" .. self.bigmap.attachmentsTypes.names[at] .."#file"), "icons/other.dds"), self.moddir);
        table.insert(self.bigmap.attachmentsTypes.icons,tempIcon); 
        self.bigmap.attachmentsTypes.overlays[self.bigmap.attachmentsTypes.names[at]] = createImageOverlay(self.bigmap.attachmentsTypes.icons[at]);
    end;
	
    self.bigmap.attachmentsTypes.width = 0.01;
    self.bigmap.attachmentsTypes.height = 0.01;
    ----

	----
	-- Unterstützte Fremdmods suchen
	----
	local mods = g_currentMission.missionDynamicInfo.mods;
	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_CheckForCoursePlay")));
	
	local beg, ende = 0, 0;
	local cpid = 0;			-- ID von CoursePlay
	local rafid = 0;		-- ID von RentaField
	
	----
	--	Suchen ob RendAField vorhanden ist
	----
	for i=1, table.getn(mods) do
		beg, ende = string.find(string.lower(mods[i].modName), "rentafield");
		if beg ~= nil and ende ~= nil then
			self.useRentAField = true;
			rafid = i;
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), string.format(g_i18n:getText("Rent A Field Mod Gefunden"), mods[rafid].title, mods[rafid].version)));
			break;
		end;
	end;
	----
	--	Suchen ob CoursePlay vorhanden ist
	----
	cpid = 0;
	for i=1, table.getn(mods) do
		beg, ende = string.find(string.lower(mods[i].modName), "courseplay");
		if beg ~= nil and ende ~= nil then
			self.useCoursePlay = true;
			cpid = i;
			break;
		end;
	end;
	----
	
	----
	--Array für CourseplayIcon
	----
	if self.useCoursePlay then
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), string.format(g_i18n:getText("MV_CoursePlayFound"), mods[cpid].title, mods[cpid].version)));
		self.bigmap.IconCourseplay = {};
		self.bigmap.IconCourseplay.Icon = {};
		self.bigmap.IconCourseplay.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#file"), "icons/courseplay.dds"), self.moddir);
		self.bigmap.IconCourseplay.Icon.OverlayId = createImageOverlay(self.bigmap.IconCourseplay.Icon.file);
		self.bigmap.IconCourseplay.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#width"), 0.0078125);
		self.bigmap.IconCourseplay.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconCoursePlay#height"), 0.0078125);
	else
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_CoursePlayNotFound")));
	end;
	----

	--Array für isBrokenIcon
	self.bigmap.iconIsBroken = {};
	self.bigmap.iconIsBroken.Icon = {};
    self.bigmap.iconIsBroken.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconIsBroken#file"), "icons/IsBroken.dds"), self.moddir);
	self.bigmap.iconIsBroken.Icon.OverlayId = createImageOverlay(self.bigmap.iconIsBroken.Icon.file);
	self.bigmap.iconIsBroken.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#width"), 0.0078125);
	self.bigmap.iconIsBroken.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#height"), 0.0078125);
	----

	--Array für HorseShoes anzeige
    self.useHorseShoes = true;
	self.bigmap.iconHorseShoes = {};
	self.bigmap.iconHorseShoes.Icon = {};
    self.bigmap.iconHorseShoes.Icon.OverlayId = nil;
    self.bigmap.iconHorseShoes.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconHorseShoe#file"), "icons/hufeisen.dds"), self.moddir);
	self.bigmap.iconHorseShoes.Icon.OverlayId = createImageOverlay(self.bigmap.iconHorseShoes.Icon.file);
	self.bigmap.iconHorseShoes.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconHorseShoe#width"), 0.0078125);
	self.bigmap.iconHorseShoes.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconHorseShoe#height"), 0.0156250);
    if self.bigmap.iconHorseShoes.Icon.OverlayId == nil or self.bigmap.iconHorseShoes.Icon.OverlayId == 0 then
        self.useHorseShoes = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorHorseShoesCreateOverlay")));
    elseif g_currentMission.collectableHorseshoesObject == nil or g_currentMission.collectableHorseshoesObject == 0 then
        self.useHorseShoes = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitHorseShoes")));
	else
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_InitHorseShoesSuccess")));
    end;
	----
    
	----
	-- Array für TipTrigger anzeige
	----
    self.useTipTrigger = true;
	self.bigmap.iconTipTrigger = {};
	self.bigmap.iconTipTrigger.Icon = {};
    self.bigmap.iconTipTrigger.Icon.OverlayId = nil;
    self.bigmap.iconTipTrigger.Icon.file = Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlace.png", self.baseDirectory); 
	self.bigmap.iconTipTrigger.Icon.OverlayId = createImageOverlay(self.bigmap.iconTipTrigger.Icon.file);
	self.bigmap.iconTipTrigger.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconHorseShoe#width"), 0.0078125);
	self.bigmap.iconTipTrigger.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconHorseShoe#height"), 0.0156250);
	
    if self.bigmap.iconTipTrigger.Icon.OverlayId == nil or self.bigmap.iconTipTrigger.Icon.OverlayId == 0 then
        self.useTipTrigger = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_InitHorseShoesFailed")));
	else
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_InitTipTriggerSuccess")));
    end;
	----
    
	----
	-- Array für Spielerinfos
	----
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
	self.bigmap.Legende.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.legende.LegendeBackground#file"), "panel/Info_Panel_bg.dds"), self.moddir);
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
		_lx = self.bigmap.Legende.legPosX + 0.007324;
		_ly = 1-0.02441 - 0.007324 - 0.015625;
		_ty = _ly;

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
	-- Prüfen auf lokale PDA Datei
	----
	local bl, lf = self:checkLocalPDAFile();
	
	if bl == true and lf ~= nil then
		self.bigmap.file = lf;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_LocalePDAFileSuccess")));
	end;
	
	if fileExists(self.bigmap.file) then
		self.bigmap.OverlayId.ovid = createImageOverlay(self.bigmap.file);
	else
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMV")));
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMVFileNotFound")));
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), self.bigmap.file));

		self.bigmap.file = 0;
	end;
	----

	----
	-- Checken ob es lokale Fnum und Poi Dateien gibt
	----
	-- Lokale PoI Datei
	-- Point of Interest verwenden
	----
	self.usePoi = false;
    self.bigmap.PoI.OverlayId = nil;
    self.bigmap.PoI.poiPosX = 0.5-(self.bigmap.PoI.width/2);
    self.bigmap.PoI.poiPosY = 0.5-(self.bigmap.PoI.height/2);


	print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_CheckForLocaleOverlay")));

	local bpoi, lfpoi = self:checkLocalPoIFile();
	if self.useDefaultMap then
		self.bigmap.PoI.file = Utils.getFilename("mv_poi_" .. string.gsub(g_currentMission.missionInfo.map.title, " ", "_") .. ".dds", self.mapPath);
	else
		self.bigmap.PoI.file = Utils.getFilename("mv_poi_" .. self:getModName(self.mapPath) .. ".dds", self.mapPath);
	end
	
	if bpoi and lfpoi ~= nil then
        self.bigmap.PoI.file = lfpoi;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_LocalePoIFileSuccess")));
	else
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMVFromLocalPoI")));
    end;

	if self.Debug.active then
		print(string.format("|| Debug || PoIFile : %s ||", tostring(self.bigmap.PoI.file)));
	end;
	
	if fileExists(self.bigmap.PoI.file) then 
		self.bigmap.PoI.OverlayId = createImageOverlay(self.bigmap.PoI.file);
	else
		self.bigmap.PoI.file = 0;
	end;
	
    if self.bigmap.PoI.OverlayId == nil or self.bigmap.PoI.OverlayId == 0 then
        self.usePoi = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitPoI")));
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreatePoIFileNotFound")));
	else
		self.usePoi = true;
    end;
	
	if self.usePoi then
		if not bpoi and not self.useDefaultMap then 
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_PoIInMap")));
		elseif not bpoi and self.useDefaultMap then 
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_PoIFromMV")));
		else
			print(string.format("|| %s || %s||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_PoIFromLocaleFile")));
		end;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_MapPoISuccess")));
	end;
	----
	
	----
	-- Lokale Fnum Datei
	-- Fieldnumbers verwenden
	----
	self.useFNum = true;
	self.bigmap.FNum.OverlayId = nil
	self.bigmap.FNum.FNumPosX = 0.5-(self.bigmap.FNum.width/2);
	self.bigmap.FNum.FNumPosY = 0.5-(self.bigmap.FNum.height/2);
	
	local bfnum, lfnum = self:checkLocalFnumFile();

	if self.Debug.active then
		print(string.format("|| %S || Debug: || bfnum : %s | lfnum : %s ||", g_i18n:getText("mapviewtxt"), tostring(bfnum), tostring(lfnum)));
	end;

	if self.useDefaultMap then
		self.bigmap.FNum.file = Utils.getFilename("mv_fnum_" .. string.gsub(g_currentMission.missionInfo.map.title, " ", "_") .. ".dds", self.mapPath);
	else
		self.bigmap.FNum.file = Utils.getFilename("mv_fnum_" .. self:getModName(self.mapPath) .. ".dds", self.mapPath);
	end;
	
	if bfnum and lfnum ~= nil then
		self.bigmap.FNum.file = lfnum;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_LocaleFNumFileSuccess")));
	else
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateMVFromLocalFNum")));
	end;
	
	if self.Debug.active then
		print(string.format("|| %s || Debug || FnumFile : %s ||", g_i18n:getText("mapviewtxt"), tostring(self.bigmap.FNum.file)));
	end;
	
	if fileExists(self.bigmap.FNum.file) then 
		self.bigmap.FNum.OverlayId = createImageOverlay(self.bigmap.FNum.file);
	else
		self.bigmap.FNum.file = 0;
	end;

	if self.bigmap.FNum.OverlayId == nil or self.bigmap.FNum.OverlayId == 0 then
		self.useFNum = false;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorInitFNum")));
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateFNumFileNotFound")));
	end;

	if self.Debug.active then
		print(string.format("|| %s || Debug || useFnum : %s ||", g_i18n:getText("mapviewtxt"), tostring(self.useFNum)));
	end;

	if self.useFNum then
		if not bfnum and not self.useDefaultMap then 
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_FNumInMap")));
		elseif not bfnum and self.useDefaultMap then 
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_FNumFromMV")));
		else
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_FNumFromLocaleFile")));
		end;
		print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_MapFNumSuccess")));
	end;
	
	print(string.format("|| %s || %s complete ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_CheckForLocaleOverlay")));
	----

	----
	--	Ausgabe der nicht übersetzten VehicleTypes nur im Debug
	----
	if self.Debug.active then
		print(string.format("--vehicleTypes--"));
		for k,v in pairs(VehicleTypeUtil.vehicleTypes) do
			print(string.format("|| %s || vehicleTypes.name  : %s || %s ||", 
				g_i18n:getText("mapviewtxt"), 
				tostring(g_i18n:getText(VehicleTypeUtil.vehicleTypes[k].name)), 
				tostring(VehicleTypeUtil.vehicleTypes[k].name)
				));
		end;
		print(string.format("--vehicleTypes--"));
	end;
	----
	
	----
	--	Table für Overlay Modi
	----
	self.Overlays = {};
	self.Overlays.mode = {"MV_Mode1Name", "MV_Mode2Name", "MV_Mode3Name", "MV_Mode4Name", "MV_Mode5Name", "MV_Mode6Name", "MV_Mode7Name", "MV_Mode8Name", "MV_Mode9Name", "MV_Mode10Name"};
	self.Overlays.names = {};
		-- Erstellen der Namensliste für die Overlays
		for i=1, table.getn(self.Overlays.mode) do
			table.insert(self.Overlays.names, g_i18n:getText(self.Overlays.mode[i]));
		end;
		--
	self.Overlays.active = {mode1=false, mode2=false, mode3=false, mode4=false, mode5=false, mode6=false, mode7=false, mode8=false, mode9=false, mode10=true};
	
	----
	-- Übersicht der Overlays Ausgeben
	----
	print(string.format("|| %s || --- Overlay Übersicht --- ||", g_i18n:getText("mapviewtxt")));
	for k,v in pairs(self.Overlays.names) do
		print(string.format("|| %s || Overlay%s=%s / active=%s ||", g_i18n:getText("mapviewtxt"), tostring(k), tostring(v), tostring(self.Overlays.active[string.format("mode%d", k)])));
	end;
	print(string.format("|| %s || --- Overlay Übersicht --- ||", g_i18n:getText("mapviewtxt")));
	----
	
	----
	-- Initialisierung abgeschlossen
	----
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

	if g_currentMission.baseDirectory == "" or g_currentMission.baseDirectory == nil then	--Standard Karte
		temp = string.gsub(g_currentMission.missionInfo.map.title, " ", "_");
	else
		temp = self:getModName(g_currentMission.baseDirectory);
	end;
	fileName = fileName .. temp;
	fileName = string.lower(fileName);
	
	fileName = PathToModDir..fileName..".dds";

	isLocal = fileExists(fileName);

	return isLocal, fileName;
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

	if g_currentMission.BaseDirectory == "" or g_currentMission.baseDirectory == nil then	--Standard Karte
		temp = string.gsub(g_currentMission.missionInfo.map.title, " ", "_");
	else
		temp = self:getModName(g_currentMission.baseDirectory);
	end;
	
	
	fileName = fileName .. temp;
	fileName = string.lower(fileName);
	
	fileName = PathToModDir..fileName..".dds";
	isLocal = fileExists(fileName);
	
	return isLocal, fileName;
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

	if g_currentMission.BaseDirectory == "" or g_currentMission.baseDirectory == nil then	--Standard Karte
		temp = string.gsub(g_currentMission.missionInfo.map.title, " ", "_");
	else
		temp = self:getModName(g_currentMission.baseDirectory);
	end;

	fileName = fileName .. temp;
	fileName = string.lower(fileName);
	
	fileName = PathToModDir..fileName..".dds";
	isLocal = fileExists(fileName);

	return isLocal, fileName;
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
	-- Funktion zum Ausgeben bestimmter Informationen in der LOG
	-- Wird bei Bedarf angepasst
    ----
	if isDown and sym == Input.KEY_d and bitAND(modifier, Input.MOD_ALT) > 0  then
		print("---- MapViwer Debug aktiviert ----");
		--self.Debug.active = not self.Debug.active;
		 g_currentMission:addWarning("Ausgabe von g_currentMission in Log. Dies kann einen moment dauern", 0.018, 0.033);
		print(table.show(g_currentMission, "g_currentMission"));
		print("------");
	end;
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
			
			self.bigmap.InfoPanel.lastTrigger = nil;
			self.bigmap.InfoPanel.Info = nil;
			self.bigmap.InfoPanel.triggerIndex = nil;
			self.bigmap.InfoPanel.isTrigger = nil;
			
			self.bigmap.InfoPanel.lastField = nil;
			self.bigmap.InfoPanel.Info = nil;
			self.bigmap.InfoPanel.fieldIndex = nil;
			self.bigmap.InfoPanel.isField = nil;
			
			if not self.useTeleport then
				----
				--	Klickbare Objekte
				----
				-- Fahrzeuge und Geräte immer Klickbar
				---
				self.bigmap.InfoPanel.vehicleIndex, self.bigmap.InfoPanel.isVehicle, self.bigmap.InfoPanel.lastVehicle = self:vehicleInMouseRange();
				----
				-- Trigger nur Klickbar, wenn sie angezeigt werden
				----
				if self.showTipTrigger then
					self.bigmap.InfoPanel.triggerIndex, self.bigmap.InfoPanel.isTrigger, self.bigmap.InfoPanel.lastTrigger = self:triggerInMouseRange();
				end;
				----
				-- Feldtrigger nur Klickbar, wenn sie angezeigt werden
				----
				if self.showFieldStatus then
					self.bigmap.InfoPanel.fieldIndex, self.bigmap.InfoPanel.isField, self.bigmap.InfoPanel.lastField = self:fieldInMouseRange();
				end;
				----
				
				----
				--	Informationen zum angeklickten Objekt abrufen
				--	Fahrzeuge und Geräte haben immer vorrang
				----
				if self.bigmap.InfoPanel.lastVehicle ~= nil and type(self.bigmap.InfoPanel.lastVehicle) == "table" and self.bigmap.InfoPanel.vehicleIndex > 0 then
					self.showInfoPanel = true;
					self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle);
				elseif self.bigmap.InfoPanel.lastTrigger ~= nil and type(self.bigmap.InfoPanel.lastTrigger) == "table" and self.bigmap.InfoPanel.triggerIndex > 0 then
					self.bigmap.InfoPanel.Info = self:GetTriggerInfo(self.bigmap.InfoPanel.lastTrigger);
					self.showInfoPanel = true;
				elseif self.bigmap.InfoPanel.lastField ~= nil and type(self.bigmap.InfoPanel.lastField) == "table" and self.bigmap.InfoPanel.fieldIndex > 0 then
					self.bigmap.InfoPanel.Info = self:GetFieldInfo(self.bigmap.InfoPanel.lastField);
					self.showInfoPanel = true;
				else
					self.showInfoPanel = false;
				end;
				----
			else
				----
				-- Teleportieren
				----
				local tpX, tpY, tpZ;
				
				tpX = self.mouseX/self.bigmap.mapWidth*self.bigmap.mapDimensionX-(self.bigmap.mapDimensionX/2);
				tpZ = -self.mouseY/self.bigmap.mapHeight*self.bigmap.mapDimensionY+(self.bigmap.mapDimensionY/2);
				tpY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, tpX, 0, tpZ) + 10;
				if g_currentMission.player.isControlled then
					if g_currentMission.missionDynamicInfo.isMultiplayer and g_currentMission:getIsServer() then
						g_server:broadcastEvent(PlayerTeleportEvent:new(tpX, tpY, tpZ), nil, nil, self);
					elseif g_currentMission.missionDynamicInfo.isMultiplayer and not g_currentMission:getIsServer() then
						g_client:getServerConnection():sendEvent(PlayerTeleportEvent:new(tpX, tpY, tpZ));
					end;
					setTranslation(g_currentMission.player.rootNode, tpX, tpY, tpZ);
					self.mapvieweractive = false;	
					
					----
					-- Mouse Kontrolle wiederherstellen
					----
					g_mouseControlsHelp.active = true; 
					InputBinding.setShowMouseCursor(false); 
					InputBinding.wrapMousePositionEnabled = true; 
					if (g_currentMission.player.isEntered) then
						g_currentMission.player.isFrozen = false;
					end;
					g_currentMission.showHudEnv = true;
					----
				end;
				self.useTeleport = false;
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
-- Feld Trigger in der Nähe des Mausklicks finden
----
function mapviewer:fieldInMouseRange()

	local currFT = nil;
	local isField = false;
	local index = 0;
	local fieldIndex = 0;
	
	local nearestDistance = 0.005;
	local tmpDistance = 0.006;
	local distance = 0.006;
	local sDistance = 0.006
	local aDistance = 0.006;
	local vDistance = 0.006;

	for i=1, g_currentMission.fieldDefinitionBase.numberOfFields do
		local currF = g_currentMission.fieldDefinitionBase.fieldDefsByFieldNumber[i];
		
		local posX1, posY1, posZ1 = getWorldTranslation(currF.fieldBuyTrigger);
		local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
		local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
		
		tmpDistance = Utils.vector2Length(self.mouseX-distancePosX, self.mouseY-distancePosZ);
		
		if tmpDistance < nearestDistance then
			sDistance = tmpDistance;
			if sDistance < distance then 
				distance = sDistance;
				index = i;
				isField = true;
				currFT = currF;
			end;
		end;
	end;
	
	return index, isField, currFT;	
end;
----

----
-- Trigger in der Nähe des Mausklicks finden
----
function mapviewer:triggerInMouseRange()
	local currTT = nil;
	local isTrigger = false;
	local index = 0;
	local triggerIndex = 0;
	
	local nearestDistance = 0.005;
	local tmpDistance = 0.006;
	local distance = 0.006;
	local sDistance = 0.006
	local aDistance = 0.006;
	local vDistance = 0.006;

	for i,j in pairs(g_currentMission.tipTriggers) do
		triggerIndex = triggerIndex +1;
		local currT = j;
		
		local posX1, posY1, posZ1 = getWorldTranslation(currT.rootNode);
		local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
		local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
		
		tmpDistance = Utils.vector2Length(self.mouseX-distancePosX, self.mouseY-distancePosZ);
		
		if tmpDistance < nearestDistance then
			sDistance = tmpDistance;
			if sDistance < distance then 
				distance = sDistance;
				index = triggerIndex;
				isTrigger = true;
				currTT = currT;
			end;
		end;
	end;

	return index, isTrigger, currTT;	
end;
----

----
-- Ermitteln der Felder Informationen
----
function mapviewer:GetFieldInfo(field)
	local fieldInfo = {};
	
	if field ~= nil and type(field) == "table" then
		table.insert(fieldInfo, string.format("%s %s", g_i18n:getText("MV_FieldInfoFieldNumber"), tostring(field.fieldNumber)));
		table.insert(fieldInfo,string.format("%s %0.2f ha", g_i18n:getText("MV_FieldInfoFieldSize"),field.fieldArea));		
		if not field.ownedByPlayer and not field.fieldAuctionActive then
			table.insert(fieldInfo, string.format("%s %s€", g_i18n:getText("MV_FieldInfoFieldPrice"), field.fieldPrice));
		elseif not field.ownedByPlayer and field.fieldAuctionActive then
			table.insert(fieldInfo,string.format("%s %s", g_i18n:getText("MV_FieldInfoCurrentBid"),tostring(field.fieldCurrentBid)));
			table.insert(fieldInfo,string.format("%s %s", g_i18n:getText("MV_FieldInfoHighestBidder"),tostring(field.fieldHighestBidder)));
			table.insert(fieldInfo,string.format("%s %s", g_i18n:getText("MV_FieldInfoNextBid"),tostring(field.fieldPrice+field.fieldBidStep)));			
		end;
		if self.useRentAField then 
			if field.rentByPlayer then
				table.insert(fieldInfo,string.format("Rent A Field Mod: %s ", g_i18n:getText("RAFIS_True")));
			elseif field.ownedByPlayer then
				table.insert(fieldInfo,string.format("Rent A Field Mod: %s ", g_i18n:getText("RAFIS_Owned")));
			else
				table.insert(fieldInfo,string.format("Rent A Field Mod: %s ", g_i18n:getText("RAFIS_False")));
			end;
			if not field.ownedByPlayer or field.rentByPlayer then
				table.insert(fieldInfo,string.format("- %s: %s ", g_i18n:getText("RAFIS_Costs"), g_i18n:formatMoney(field.fieldPrice / 25)));
			end;
		end;
		
		-- print(string.format("Rent A Field Mod: %s ", tostring(field.rentByPlayer)) .. string.format("||    %s: %s ", g_i18n:getText("RAFIS_Costs"), g_i18n:formatMoney(field.fieldPrice / 25)));
	end;
	
	return fieldInfo;
end;
----

----
-- Ermitteln der Trigger Informationen
----
function mapviewer:GetTriggerInfo(trigger)
	local triggerInfo = {};
	local fruits = {};
	local prices = {};
	local amounts = {};
	local fsa = 0;
	local triggerName = "";
	
	if trigger ~= nil and type(trigger) == "table" then
		
		----
		-- Aktzeptierte Waren und Preise ermitteln
		----
		if g_i18n:hasText(trigger.stationName) then
			triggerName = g_i18n:getText(trigger.stationName);
		elseif trigger.isFarmTrigger then 
			triggerName = g_i18n:getText("MV_Farmsilo");
		else
			triggerName = trigger.stationName;
		end;
		
		if trigger.bga ~= nil then
			triggerName = g_i18n:getText("BGA_Station_name");
		end;
		
		fruits, prices = self:getTriggerFruitTypesAndPrices(trigger);
		if trigger.isFarmTrigger then
			table.insert(triggerInfo, string.format("Name: %s", triggerName));
		else
			table.insert(triggerInfo, string.format("Name: %s", tostring(triggerName)));
		end;
		
		for fillType, _ in pairs (trigger.acceptedFillTypes) do
			fsa = g_currentMission.missionStats.farmSiloAmounts[fillType];
			if fsa ~= nil then
				table.insert(amounts, math.ceil(fsa));
			else
				table.insert(amounts, 0);
			end;
		end;

		for i=1, table.getn(fruits) do
			local Frucht;
			
			if trigger.isFarmTrigger then
				table.insert(triggerInfo, string.format("%s : %s", tostring(fruits[i]), tostring(amounts[i])));
			else
				table.insert(triggerInfo, string.format("%s (%s€)", tostring(fruits[i]), tostring(prices[i])));
			end;
		end;
		----
	end;
	
	return triggerInfo;
end;
----

----
--	Aktzeptierte Fruchtsorten und Preise eines Triggers abfragen
----
function mapviewer:getTriggerFruitTypesAndPrices(trigger)
	local fruits = {};
	local prices = {};
	local missionStats = g_currentMission.missionStats;
	
	for fillType, _ in pairs (trigger.acceptedFillTypes) do
		local difficultyMultiplier = math.max(2 * (3 - missionStats.difficulty), 1)
		local greatDemandMultiplier = 1
		local greatDemand = g_currentMission.economyManager:getCurrentGreatDemand(trigger.stationName, fillType)
		if greatDemand ~= nil then
			greatDemandMultiplier = greatDemand.demandMultiplier
		end
		local price = math.ceil(Fillable.fillTypeIndexToDesc[fillType].pricePerLiter * 1000 * trigger.priceMultipliers[fillType] * difficultyMultiplier * greatDemandMultiplier);
		table.insert(prices, price);
		
		if not FruitUtil.fillTypeIsWindrow[fillType] then
			table.insert(fruits, tostring(Utils.getNoNil(g_i18n:getText(Fillable.fillTypeIndexToDesc[fillType].name),g_i18n:getText("MV_Unknown"))));
		else
			table.insert(fruits, tostring(g_i18n:getText(FruitUtil.fruitIndexToDesc[FruitUtil.fillTypeToFruitType[fillType]].name)) .. " " .. g_i18n:getText("MV_Windrow"));
		end;
	end;
	
	return fruits, prices;
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

	for j=1, table.getn(g_currentMission.steerables) do

		local currS = g_currentMission.steerables[j];
		local posX1, posY1, posZ1 = getWorldTranslation(currS.rootNode);
		local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
		local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
		tmpDistance = Utils.vector2Length(self.mouseX-distancePosX, self.mouseY-distancePosZ);

		if tmpDistance < nearestDistance then
			sDistance = tmpDistance;
			if sDistance < distance then 
				distance = sDistance;
				index = j;
				isVehicle = true;
				currV = currS;
			end;
		end;
	end;
	
	tmpDistance = 0.006;
	aDistance = 0.006;
	vDistance = 0.006;
	
	----
	--Attachables
	----
	for a=1, table.getn(g_currentMission.attachables) do
		if g_currentMission.attachables[a].attacherVehicle == nil or g_currentMission.attachables[a].attacherVehicle == 0 then
			local currA = g_currentMission.attachables[a];
			local posX1, posY1, posZ1 = getWorldTranslation(currA.rootNode);
			local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
			local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
			tmpDistance = Utils.vector2Length(self.mouseX-distancePosX, self.mouseY-distancePosZ);

			if tmpDistance < nearestDistance then
				aDistance = tmpDistance;
				if aDistance < distance then 
					distance = aDistance;
					index = a;
					isVehicle = false;
					currV = currA;
				end;
			end;
		end;
	end;
	----
	
	return index, isVehicle, currV;	
end;
----

----
-- Ermitteln ob Attachments vorhanden sind
----
function mapviewer:getVehicleAttachmentsFruitTypes(object)
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
			self:getImplements(oImplements[z], oImplements);
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
		return Fruitnames, Attaches;
	end;
	return nil;
end;

function mapviewer:getImplements(object, o)
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
	-- TODO: getNoNil aufrufe entfernen
	-- TODO: getText aufrufe durch eigene Funktion ersetzen
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
				if vehicle.grainTankCapacity ~= nil and vehicle.grainTankCapacity > 0 then
					fruitType = vehicle.currentGrainTankFruitType; 
					fruitFillLevel = vehicle.grainTankFillLevel; 
					f = fruitFillLevel;
					useGrainTank = true;
					if useGrainTank and f ~= nil then
						c = vehicle.grainTankCapacity;
						if c > 0 then
							p = f / c * 100;
							table.insert(vehicleInfo, string.format("%s %d / %d | %.2f%%", g_i18n:getText("MV_FillLevel"), f, c, p));
						end;
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
		fruitNames, attachList = self:getVehicleAttachmentsFruitTypes(vehicle);
		
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
	end;
	---- Ende Füllstand ermitteln neu ----		
	return vehicleInfo;
end;
----

----
-- Anzeigen der Tasten für die MapViewer Steuerung
----
function mapviewer:showMapViewerKeys()
	local tY, tX, tLeft, tTop, tHeight, yHelp;
	
	tX = 0.01;	-- Abstand zum Linken Bildrand
	tY = 0.92;	-- Abstand zum oberen Bildrand
	tHeight = 6*0.018;	-- Höhe des Text Hintergrunds
	tTop = 0.92 - tHeight;	-- Obere linke Ecke des Hintergrunds
	tLeft = 0.018;	-- Begin des Textes links
	tRight = (self.bigmap.InfoPanel.background.width)*1.75 ;	-- Begin des Textes links
	tyBottom = tY - self.bigmap.InfoPanel.top.closebar.height - tHeight;
	
	renderOverlay(self.bigmap.InfoPanel.top.closebar.OverlayId, tX, tY, self.bigmap.InfoPanel.top.closebar.width*1.75, self.bigmap.InfoPanel.top.closebar.height);
	renderOverlay(self.bigmap.InfoPanel.background.OverlayId, tX, tTop, self.bigmap.InfoPanel.background.width*1.75, tHeight);
	renderOverlay(self.bigmap.InfoPanel.bottom.closebar.OverlayId, tX, tyBottom, self.bigmap.InfoPanel.bottom.closebar.width*1.75, self.bigmap.InfoPanel.bottom.closebar.height);

	setTextColor(0, 0, 0, 1);

	----
	-- TODO: Tastenbelegung erweitern
	--	Overlay Tasten
	----
	setTextAlignment(RenderText.ALIGN_LEFT)
	renderText(tLeft, tY-0.016, 0.015, string.format("%s ->", g_i18n:getText("BIGMAP_Legende")));	--InputBinding.BIGMAP_Legende)
	renderText(tLeft, tY-0.033, 0.015, string.format("%s ->", g_i18n:getText("BIGMAP_TransPlus")));	--InputBinding.BIGMAP_Legende)
	renderText(tLeft, tY-0.049, 0.015, string.format("%s ->", g_i18n:getText("BIGMAP_TransMinus")));	--InputBinding.BIGMAP_Legende)
	renderText(tLeft, tY-0.066, 0.015, string.format("%s ->", g_i18n:getText("BIGMAP_SwitchOverlay")));	--InputBinding.BIGMAP_Legende)
	renderText(tLeft, tY-0.083, 0.015, string.format("%s ->", g_i18n:getText("BIGMAP_Teleport")));	--InputBinding.BIGMAP_Legende)
	renderText(tLeft, tY-0.100, 0.015, string.format("%s ->", g_i18n:getText("BIGMAP_ShowOverlay")));
	setTextAlignment(RenderText.ALIGN_RIGHT)
	renderText(tRight, tY-0.016, 0.015, string.format("%s", tostring(KeyboardHelper.getKeyNames(InputBinding.actions[InputBinding.BIGMAP_Legende].keys1))));
	renderText(tRight, tY-0.033, 0.015, string.format("%s", tostring(KeyboardHelper.getKeyNames(InputBinding.actions[InputBinding.BIGMAP_TransPlus].keys1))));
	renderText(tRight, tY-0.049, 0.015, string.format("%s", tostring(KeyboardHelper.getKeyNames(InputBinding.actions[InputBinding.BIGMAP_TransMinus].keys1))));
	renderText(tRight, tY-0.066, 0.015, string.format("%s", tostring(KeyboardHelper.getKeyNames(InputBinding.actions[InputBinding.BIGMAP_SwitchOverlay].keys1))));
	renderText(tRight, tY-0.083, 0.015, string.format("%s", tostring(KeyboardHelper.getKeyNames(InputBinding.actions[InputBinding.BIGMAP_Teleport].keys1))));
	renderText(tRight, tY-0.100, 0.015, string.format("NumPad 1-9"));
	setTextAlignment(RenderText.ALIGN_LEFT)
	setTextColor(1, 1, 1, 0);
end;
----

----
-- Panel anzeigen
----
function mapviewer:ShowPanelonMap()
	if self.showInfoPanel and self.bigmap.InfoPanel.Info ~=nil then
		local tX, tY, tLeft, tRight, tTop;
		
		----
		-- Berechnen der benötigten Höhe für den Texthintergrund
		----
		local zeile = table.getn(self.bigmap.InfoPanel.Info);
		self.bigmap.InfoPanel.background.height = zeile * 0.015;
		----
		
		----		
		tX = self.bigmap.InfoPanel.background.Pos.x;
		tY = self.bigmap.InfoPanel.background.Pos.y;
		tTop = tY + self.bigmap.InfoPanel.background.height;
		tLeft = tX + 0.005; 
		
		renderOverlay(self.bigmap.InfoPanel.top.image.OverlayId, self.bigmap.InfoPanel.top.image.Pos.x, self.bigmap.InfoPanel.top.image.Pos.y, self.bigmap.InfoPanel.top.image.width, self.bigmap.InfoPanel.top.image.height);
		
		renderOverlay(self.bigmap.InfoPanel.background.OverlayId, self.bigmap.InfoPanel.background.Pos.x, self.bigmap.InfoPanel.background.Pos.y, self.bigmap.InfoPanel.background.width, self.bigmap.InfoPanel.background.height);
		
		renderOverlay(self.bigmap.InfoPanel.bottom.image.OverlayId, self.bigmap.InfoPanel.bottom.image.Pos.x, self.bigmap.InfoPanel.bottom.image.Pos.y, self.bigmap.InfoPanel.bottom.image.width, self.bigmap.InfoPanel.bottom.image.height);
		----

		----
		-- Ausgabe des InfoPanel Text
		----
		setTextBold(true);
		setTextColor(0, 0, 0, 1);
		if self.bigmap.InfoPanel.lastVehicle ~= nil or self.bigmap.InfoPanel.lastTrigger ~= nil or self.bigmap.InfoPanel.lastField ~= nil then
			for r=1, table.getn(self.bigmap.InfoPanel.Info) do
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
		----
		-- Aktuelle Transparenz und Copyright anzeigen
		----
		setTextColor(1, 1, 1, 1);
		setTextAlignment(RenderText.ALIGN_CENTER);
		renderText(0.5-0.0273, 1-0.03, 0.020, string.format("Transparenz\t%d", self.bigmap.mapTransp * 100));
		renderText(0.5-0.035, 0.03, 0.018, g_i18n:getText("mapviewtxt"));
		setTextAlignment(RenderText.ALIGN_LEFT);
		setTextColor(1, 1, 1, 0);
        ----
		
		----
		-- Hilfe Anzeige ausschalten solange MV Aktiv ist
		----
		-- TODO: vorherigen Stand merken
		----
		g_currentMission.showHelpText = false;
		----
		
		----
		-- Taste für Teleport wurde gedrückt
		-- Hinweis das der nächste Mausklick den spieler teleportiert anzeigen
		----
		if self.useTeleport then
			g_currentMission:addWarning("Teleport aktiv. Bitte Ziel wählen", 0.018, 0.033);
		end;
		----

		
		----
		-- Points of Interessts
		-- Fieldnumbers Overlay
		----
		self:showCustomOverlays();
		----

		----
		-- Trigger
		----
		if self.showTipTrigger and self.useTipTrigger then
			self:showTipTriggerHotSpot();
		end;
		----
				
		----
		-- Alle Mitspieler auf Karte zeigen
		----
		self:showPlayerOnMap();
		----
		
		----
		-- Hotspots aus der Karte anzeigen
		if self.showHotSpots and self.useHotSpots then
			self:showMapHotspotsOnMap();
		end;
		----
		
		----
		-- aktueller Besitzstand und Feldinformationen der Felder 
		-- aus der Kartendefinition auf grosse Karte anzeigen
		----
		if self.showFieldStatus and self.useFieldStatus then
			self:showFieldNumbersOnMap();
		end;
		----
		
		----
		-- Fahrzeuge und Attachments einblenden
		----
		if self.showVehicles then
		----
			self:showSteerablesOnMap();
		----
		
		----
		--	Darstellen der Geräte auf der Karte
			self:showAttachmentsOnMap();
		----
		
		----
		-- Milchtruck auf Karte Zeichnen
		----
			self:showMilkTruckOnMap();
		----
		end;
		----
		
		----
		-- Maplegende anzeigen
		----
		if self.maplegende then
			self:showMaplegende();
		end;
		----
		
		----
		-- Tastenbelegung mit Panelhintergrund statt Hilfetext anzeigen
		----
		if self.showKeyHelp and not self.maplegende then
			self:showMapViewerKeys();
			----
			-- Anzeigen der aktuell aktivierten Overlay Modi
			----
			self:showOverlayModiName();
			----
		end;
		----
		
		----
		-- Wenn Debug, Ausgabe der Mouseposition
		----		
		if self.Debug.active then
			setTextColor(0, 0, 0, 1);
			renderText(0.020, 0.090, 0.020, string.format("Mouse Pos : x:%.3f / y:%.3f",self.mouseX,self.mouseY));
			setTextColor(1, 1, 1, 0);
		end;
		----

		----
		-- InfoPanel anzeigen
		----		
		if self.showInfoPanel then
			self.bigmap.InfoPanel.Info = {};
			if self.bigmap.InfoPanel.lastVehicle ~= nil then
			-- TODO: CoursePlay Kurs einblendung in Funktion auslaggern
				self.bigmap.InfoPanel.Info = self:GetVehicleInfo(self.bigmap.InfoPanel.lastVehicle); -- self.bigmap.InfoPanel.vehicleIndex
			elseif self.bigmap.InfoPanel.lastTrigger ~= nil then
				self.bigmap.InfoPanel.Info = self:GetTriggerInfo(self.bigmap.InfoPanel.lastTrigger); -- self.bigmap.InfoPanel.vehicleIndex
			elseif self.bigmap.InfoPanel.lastField ~= nil then
				self.bigmap.InfoPanel.Info = self:GetFieldInfo(self.bigmap.InfoPanel.lastField); -- self.bigmap.InfoPanel.vehicleIndex
			else
				self.showInfoPanel = false;
			end;
		
			----
			-- CoursePlayKurse für gewähltes Fahrzeug
			----
			if self.bigmap.InfoPanel.lastVehicle ~= nil then
				local Courseplayname = nil;
				self.currentVehicle = self.bigmap.InfoPanel.lastVehicle;
				if SpecializationUtil.hasSpecialization(courseplay, self.currentVehicle.specializations) then
					if self.bigmap.IconCourseplay.Icon.OverlayId ~= nil and self.bigmap.IconCourseplay.Icon.OverlayId ~= 0 then
						if self.currentVehicle.cp.currentCourseName ~=nil then
							Courseplayname = self.currentVehicle.cp.currentCourseName;
						else
							Courseplayname = nil;
						end;
						
						for w=1, table.getn(self.currentVehicle.Waypoints) do
							local wx = self.currentVehicle.Waypoints[w].cx;
							local wz = self.currentVehicle.Waypoints[w].cz;
							wx = ((((self.bigmap.mapDimensionX/2)+wx)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
							wz = ((((self.bigmap.mapDimensionY/2)-wz)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);

							renderOverlay(self.bigmap.IconCourseplay.Icon.OverlayId,
										wx-self.bigmap.IconCourseplay.width/2, 
										wz-self.bigmap.IconCourseplay.height/2,
										self.bigmap.IconCourseplay.width,
										self.bigmap.IconCourseplay.height);
						end;
						setOverlayColor(self.bigmap.IconCourseplay.Icon.OverlayId, 1, 1, 1, 1);
						if Courseplayname ~= nil then
							table.insert(self.bigmap.InfoPanel.Info, 2, string.format("%s: %s",g_i18n:getText("MV_ActiveCPCourse"), Courseplayname));
						end;
					end;
				end;
			end;
			----
			
			if self.showInfoPanel then
				self:ShowPanelonMap();
			end;
		end;
		----
		-- Test Feld STatus
		----
		-- if self.mapvieweractive and self.mv_FoliageStateOverlays ~= nil and self.mv_FoliageStateOverlays ~= 0 then
			-- if getIsFoliageStateOverlayReady(self.foliageStateOverlay) then
			-- if self.showFoliageState then
			-- print(table.show(g_inGameMenu.foliageStateOverlay, "g_inGameMenu.foliageStateOverlay"));
			-- self.showFoliageState = false;
				-- renderOverlay(self.mv_FoliageStateOverlays, 0.0915, 0.2075, 0.4685, 0.625);
			-- end;
		-- end;
		----
	else
		g_currentMission:addHelpButtonText(g_i18n:getText("BIGMAP_Activate"), InputBinding.BIGMAP_Activate);
	end;
	
	----
	-- Horseshoes und Anzahl anzeigen
	----
	if self.showHorseShoes and self.useHorseShoes then
		local countHorseShoesFound = 0;		--	Anzahl der bereits gefundenen Hufeisen
		
		countHorseShoesFound = self:showHorseShoesOnMap();
		
		setTextColor(1, 1, 1, 1);
		setTextAlignment(RenderText.ALIGN_CENTER);
		renderText(0.5-0.0273, 1-0.065, 0.020, 
				string.format(g_i18n:getText("MV_Mode6Title"), tostring(countHorseShoesFound), tostring(table.getn(g_currentMission.collectableHorseshoesObject.horseshoes)))
				);
		etTextAlignment(RenderText.ALIGN_LEFT);
		setTextColor(1, 1, 1, 0);
	end;
	----

	----
	-- Eigenen Namen auf PDA anzeigen
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
	----
end;
----

----
--	Anzeigen aller aktiven Overlaymodi
----
function mapviewer:showOverlayModiName()
	local tmpTable = {};
	local col = 0;
	
	for k,v in pairs(self.Overlays.names) do
		if self.Overlays.active[string.format("mode%s",tostring(k))] then 
			table.insert(tmpTable, {name=self.Overlays.names[k], index=k});
			col = col +1;
		end;
	end;
	
	local tY, tX, tLeft, tTop, tHeight, yHelp;
	if col > 0 then
		tX = 0.01;	-- Abstand zum Linken Bildrand
		tY = 0.8;	-- Abstand zum oberen Bildrand
		tHeight = col*0.018+0.016;	-- Höhe des Text Hintergrunds
		tTop = 0.8 - tHeight;	-- Obere linke Ecke des Hintergrunds
		tLeft = 0.018;	-- Begin des Textes links
		tRight = (self.bigmap.InfoPanel.background.width)*1.75 ;	-- Begin des Textes links
		tyBottom = tY - self.bigmap.InfoPanel.top.closebar.height - tHeight;

		renderOverlay(self.bigmap.InfoPanel.top.closebar.OverlayId, tX, tY, self.bigmap.InfoPanel.top.closebar.width*1.75, self.bigmap.InfoPanel.top.closebar.height);
		renderOverlay(self.bigmap.InfoPanel.background.OverlayId, tX, tTop, self.bigmap.InfoPanel.background.width*1.75, tHeight);
		renderOverlay(self.bigmap.InfoPanel.bottom.closebar.OverlayId, tX, tyBottom, self.bigmap.InfoPanel.bottom.closebar.width*1.75, self.bigmap.InfoPanel.bottom.closebar.height);
		
		setTextColor(0, 0, 0, 1);
		renderText(tLeft, tY-1*0.017, 0.015, "Aktive Overlays");
		tY= tY - 0.017;
		for i=1, col do
			setTextAlignment(RenderText.ALIGN_LEFT)
			renderText(tLeft, tY-i*0.017, 0.015, string.format("%s", tmpTable[i].name));	--InputBinding.BIGMAP_Legende)
		end;
		setTextColor(1, 1, 1, 0);
	end;
end;
----

----
--	Funktion zum erstellen eines Feldwachstums Overlay in Testphase
function mapviewer:mv_createMapStateOverlay()
	do
		for fruitType, ids in pairs(g_currentMission.fruits) do
			if ids.id ~= 0 then
				local desc = FruitUtil.fruitIndexToDesc[fruitType]
				if 0 <= desc.maxHarvestingGrowthState then
					local witheredState = desc.maxHarvestingGrowthState + 1
					if 0 <= desc.maxPreparingGrowthState then
						witheredState = desc.maxPreparingGrowthState + 1
					end
		
					if witheredState ~= desc.cutState and witheredState ~= desc.preparedGrowthState and witheredState ~= desc.minPreparingGrowthState then
						setFoliageStateOverlayGrowthStateColor(self.mv_FoliageStateOverlays, ids.id, witheredState + 1, self.growthWitheredColor[1], self.growthWitheredColor[2], self.growthWitheredColor[3])
					end
			
					local maxGrowingState = desc.minHarvestingGrowthState - 1
					if 0 <= desc.minPreparingGrowthState then
						maxGrowingState = math.min(maxGrowingState, desc.minPreparingGrowthState - 1)
					end
			
					for i = 0, maxGrowingState do
						local index = math.min(i + 1, #self.growthGrowingColors)
						setFoliageStateOverlayGrowthStateColor(self.mv_FoliageStateOverlays, ids.id, i + 1, self.growthGrowingColors[index][1], self.growthGrowingColors[index][2], self.growthGrowingColors[index][3])
					end
			
					if 0 <= desc.minPreparingGrowthState then
						for i = desc.minPreparingGrowthState, desc.maxPreparingGrowthState do
							setFoliageStateOverlayGrowthStateColor(self.mv_FoliageStateOverlays, ids.id, i + 1, self.growthReadyToPrepareColor[1], self.growthReadyToPrepareColor[2], self.growthReadyToPrepareColor[3])
						end
					end
			
					for i = desc.minHarvestingGrowthState, desc.maxHarvestingGrowthState do
						local index = math.min(i - desc.minHarvestingGrowthState + 1, #self.growthReadyToHarvestColors)
						setFoliageStateOverlayGrowthStateColor(self.mv_FoliageStateOverlays, ids.id, i + 1, self.growthReadyToHarvestColors[index][1], self.growthReadyToHarvestColors[index][2], self.growthReadyToHarvestColors[index][3])
					end
				end
			end
		end
	end;
	generateFoliageStateOverlayGrowthStateColors(self.mv_FoliageStateOverlays)
	g_inGameMenu:checkFoliageStateOverlayReady()
end;
----

----
-- Hufeisen anzeigen
----
function mapviewer:showHorseShoesOnMap()

	local countHorseShoesFound = 0;

	if self.showHorseShoes and self.useHorseShoes then
		local HShoes = {};
		HShoes = g_currentMission.collectableHorseshoesObject.horseshoes;
		if self.bigmap.iconHorseShoes.Icon.OverlayId ~= nil and self.bigmap.iconHorseShoes.Icon.OverlayId ~= 0 then
			for i=1, table.getn(HShoes) do
				local bottleFound=string.byte(g_currentMission.missionStats.foundHorseshoes, i);
				if bottleFound==48 then
					self.posX, self.posY, self.posZ=getWorldTranslation(HShoes[i].horseshoeTriggerId);
					self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
					self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
					
					renderOverlay(self.bigmap.iconHorseShoes.Icon.OverlayId,
								self.buttonX-self.bigmap.iconHorseShoes.width/2, 
								self.buttonZ-self.bigmap.iconHorseShoes.height/2, 
								self.bigmap.iconHorseShoes.width, 
								self.bigmap.iconHorseShoes.height);
				else
					countHorseShoesFound = countHorseShoesFound+1;
				end;

				if self.Debug.printHorseShoes then
					print(string.format("Debug : HS X1 %.2f | HS Y1 %.2f | mapHS X1 %.2f | mapHS Y1 %.2f | Index: %s | Count: %d", self.posX, self.posZ, self.buttonX, self.buttonZ, tostring(i), countHorseShoesFound));
				end;
			end;
			if self.Debug.printHorseShoes then
				self.Debug.printHorseShoes = false;
			end;
		else
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorHorseShoesCreateOverlay")));
			self.useHorseShoes = not self.useHorseShoes;
		end;
	end;
	----
	-- Anzahl der gefundenen Hufeisen zurückgeben
	----
	return countHorseShoesFound;
end;
----

----
-- Alle Mitspieler auf Karte zeigen
----
function mapviewer:showPlayerOnMap()
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

		mplayer.xPos = ((((self.bigmap.mapDimensionX/2)+posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
		mplayer.yPos = ((((self.bigmap.mapDimensionY/2)-posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
		setTextColor(0, 1, 0, 1);

		if mplayer.player.rootNode == self.activePlayerNode and mplayer.player.isControlled then
			if self.bigmap.player.ArrowOverlayId ~= nil and self.bigmap.player.ArrowOverlayId ~= 0 then
				renderOverlay(self.bigmap.player.ArrowOverlayId, 
								mplayer.xPos-self.bigmap.player.width/2, mplayer.yPos-self.bigmap.player.height/2,
								self.bigmap.player.width, self.bigmap.player.height);
			end;
			renderText(mplayer.xPos +self.bigmap.player.width/2, mplayer.yPos-self.bigmap.player.height/2, 0.015, mplayer.player.controllerName);
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
end;
----

----
-- Hotspots auf grosse Karte, 
-- zusammen mit den Feldnummern und dem aktuellen Besitzstand der Felder aus der Kartendefinition
----
function mapviewer:showMapHotspotsOnMap()

	if self.showHotSpots and self.useHotSpots then
		local hsPosX, hsPosY, hsWidth, hsHeight;
		for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
			hsWidth = g_currentMission.missionPDA.hotspots[j].width;
			hsHeight = g_currentMission.missionPDA.hotspots[j].height;
			----
			self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;			

			local bc = g_currentMission.missionPDA.hotspots[j].baseColor;
			
			setTextColor(1, 1, 1, 1);
			setTextAlignment(RenderText.ALIGN_CENTER);

			----
			-- Integrierte Map Hotspots
			----
			if not g_currentMission.missionPDA.hotspots[j].showName then
				if self.useDefaultMap then 
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+1024;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+1024;
				elseif g_currentMission.terrainSize ~= 2050 then	
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+2048;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+2048;
				else
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos;
				end;
				
				hsPosX = (hsPosX/self.bigmap.mapDimensionX)-(hsWidth/2);
				hsPosY = 1-(hsPosY/self.bigmap.mapDimensionY)-(hsHeight/2);

				renderOverlay(self.hsOverlayId, hsPosX, hsPosY, hsWidth, hsHeight);
				if g_i18n:hasText("MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name) then
					renderText(hsPosX+hsWidth/2, hsPosY-hsHeight/2, 0.020, tostring(g_i18n:getText("MV_HotSpot" .. g_currentMission.missionPDA.hotspots[j].name)));
				else
					renderText(hsPosX+hsWidth/2, hsPosY-hsHeight/2, 0.020, tostring(g_currentMission.missionPDA.hotspots[j].name));
				end;
			end;
			setTextAlignment(RenderText.ALIGN_LEFT);
			setTextColor(1, 1, 1, 0);

			-- Ausgabe der Hotspot Positionen und weiterer Infos
			-- if self.Debug.printHotSpots then
				-- print(string.format("Debug MapHotspots: HS X1 %.2f | HS Y1 %.2f | mapHS X1 %.2f | mapHS Y1 %.2f | name: %s", g_currentMission.missionPDA.hotspots[j].xMapPos, g_currentMission.missionPDA.hotspots[j].yMapPos, self.hsPosX, self.hsPosY, g_currentMission.missionPDA.hotspots[j].name));
			-- end;
		end;
		-- if self.Debug.printHotSpots then
			-- self.Debug.printHotSpots = false;
		-- end;
	end;
end;
----

----
--	Feldnummern und dem aktuellen Besitzstand der Felder aus der Kartendefinition
----
function mapviewer:showFieldNumbersOnMap_try()
	for _, fieldDef in pairs(g_currentMission.fieldDefinitionBase.fieldDefs) do
		local x, _, z = getWorldTranslation(fieldDef.fieldMapIndicator)
		setTextBold(true)
		setTextColor(0, 0, 0, 1)
		renderText(0.0915 + (g_currentMission.missionPDA.worldCenterOffsetX + x) / g_currentMission.missionPDA.worldSizeX * 0.4685 - 0.0075, 0.8325 - (g_currentMission.missionPDA.worldCenterOffsetZ + z) / g_currentMission.missionPDA.worldSizeZ * 0.625 - 0.011, 0.02, tostring(fieldDef.fieldNumber))
		setTextColor(fieldDef.fieldMapHotspot.baseColor[1], fieldDef.fieldMapHotspot.baseColor[2], fieldDef.fieldMapHotspot.baseColor[3], 1)
		renderText(0.0915 + (g_currentMission.missionPDA.worldCenterOffsetX + x) / g_currentMission.missionPDA.worldSizeX * 0.4685 - 0.0075, 0.8325 - (g_currentMission.missionPDA.worldCenterOffsetZ + z) / g_currentMission.missionPDA.worldSizeZ * 0.625 - 0.009, 0.02, tostring(fieldDef.fieldNumber))
		setTextBold(false)
	end
end;
----
--	Feldnummern und dem aktuellen Besitzstand der Felder aus der Kartendefinition
----
function mapviewer:showFieldNumbersOnMap()
	if self.showFieldStatus and self.useFieldStatus then
		local hsPosX, hsPosY, hsWidth, hsHeight;
		hsPosX = 0;
		hsPosY = 0;
		hsWidth = 0;
		hsHeight = 0;
		for j=1, table.getn(g_currentMission.missionPDA.hotspots) do
			hsWidth = g_currentMission.missionPDA.hotspots[j].width;
			hsHeight = g_currentMission.missionPDA.hotspots[j].height;
			----
			self.hsOverlayId = g_currentMission.missionPDA.hotspots[j].overlay.overlayId;			

			local bc = g_currentMission.missionPDA.hotspots[j].baseColor;
			
			setTextColor(1, 1, 1, 1);
			--setTextAlignment(RenderText.ALIGN_CENTER);

			----
			-- Feldnummern Positionen
			----
			--	TODO: Position der angezeigten Feldnummern
			----
			--	BUG: Feldnummerindex um 1 versetzt
			----
			if g_currentMission.missionPDA.hotspots[j].showName then
				if self.useDefaultMap then 		-- Standard Karte
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+1024;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+1024;
				elseif g_currentMission.terrainSize ~= 2050 then		-- Größe anders als Standard Karte	
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos+2048;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos+2048;
				else		-- Gemoddede Karte mit standard größe
					hsPosX = g_currentMission.missionPDA.hotspots[j].xMapPos;
					hsPosY = g_currentMission.missionPDA.hotspots[j].yMapPos;
				end;
				
				hsPosX = (hsPosX/self.bigmap.mapDimensionX)-(hsWidth/2);
				hsPosY = 1-(hsPosY/self.bigmap.mapDimensionY)-(hsHeight/2);

				if self.useRentAField and self.showFieldStatus then
					if g_currentMission.fieldDefinitionBase.fieldDefsByFieldNumber[tonumber(g_currentMission.missionPDA.hotspots[j].name)].rentByPlayer ~= nil then
						setTextColor(0, 0, 1, 1);
					else
						setTextColor(bc[1], bc[2], bc[3], bc[4]);
					end;
				end;
				--renderOverlay(self.hsOverlayId, self.hsPosX, self.hsPosY, self.hsWidth, self.hsHeight);
				renderText(hsPosX, hsPosY, 0.032, tostring(g_currentMission.missionPDA.hotspots[j].name));

				setTextAlignment(RenderText.ALIGN_LEFT);
				setTextColor(1, 1, 1, 0);

				if self.Debug.active and self.Debug.printFieldNumbers then
					print(string.format("Debug Feldnummern: HS X1 %.2f | HS Y1 %.2f | mapHS X1 %.2f | mapHS Y1 %.2f | name: %s", g_currentMission.missionPDA.hotspots[j].xMapPos, g_currentMission.missionPDA.hotspots[j].yMapPos, hsPosX, hsPosY, g_currentMission.missionPDA.hotspots[j].name));
				end;
			end;
		end;
		if self.Debug.printHotSpots then
			self.Debug.printHotSpots = false;
		end;
	end;
end;
----

----
--	Fahrzeuge auf grosse Karte 
----
function mapviewer:showSteerablesOnMap()
	for i=1, table.getn(g_currentMission.steerables) do
		if not g_currentMission.steerables[i].isBroken then
			self.currentVehicle = g_currentMission.steerables[i];
			self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
			self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
			self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
			
			----
			-- Auslesen der Kurse wenn CoursePlay vorhanden ist
			----
			if self.useCoursePlay then
				-- Erst prüfen ob die CP Spezi im Fahrzeug vorhanden ist.
				if SpecializationUtil.hasSpecialization(courseplay, self.currentVehicle.specializations) and self.showCP then
					if self.bigmap.IconCourseplay.Icon.OverlayId ~= nil and self.bigmap.IconCourseplay.Icon.OverlayId ~= 0 then
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
				
				if self.Debug.active then
					renderText(0.020, 0.020, 0.015, string.format("Koordinaten : x=%.1f / y=%.1f",self.buttonX * 1000,self.buttonZ * 1000));
				end;
				
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
			else
				if self.bigmap.IconSteerable.OverlayId ~= nil and self.bigmap.IconSteerable.OverlayId ~= 0 then
					renderOverlay(self.bigmap.IconSteerable.OverlayId,
								self.buttonX-self.bigmap.IconSteerable.width/2, 
								self.buttonZ-self.bigmap.IconSteerable.height/2,
								self.bigmap.IconSteerable.width,
								self.bigmap.IconSteerable.height);
					setOverlayColor(self.bigmap.IconSteerable.OverlayId, 1, 1, 1, 1);
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
end;
----

----
--	Darstellen der Geräte auf der Karte
----
function mapviewer:showAttachmentsOnMap()
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
end;
----

----
-- Milchtruck auf Karte Anzeigen
----
function mapviewer:showMilkTruckOnMap()
	for i=1, table.getn(g_currentMission.trafficVehicles) do
		if g_currentMission.trafficVehicles[i].typeName == "milktruck" then
			self.currentVehicle = g_currentMission.trafficVehicles[i];
			if self.bigmap.IconMilchtruck.OverlayId ~= nil and self.bigmap.IconMilchtruck.OverlayId ~= 0 then
				self.posX, self.posY, self.posZ = getWorldTranslation(self.currentVehicle.rootNode);
				self.buttonX = ((((self.bigmap.mapDimensionX/2)+self.posX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
				self.buttonZ = ((((self.bigmap.mapDimensionY/2)-self.posZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
				
				if self.bigmap.IconMilchtruck.OverlayId ~= nil then
					renderOverlay(self.bigmap.IconMilchtruck.OverlayId,
								self.buttonX-self.bigmap.IconMilchtruck.width/2, 
								self.buttonZ-self.bigmap.IconMilchtruck.height/2,
								self.bigmap.IconMilchtruck.width,
								self.bigmap.IconMilchtruck.height);
				-- TODO: Milchtruckposition an Clients senden
				end;
			end;
			break;
		end;
	end;
end;
----

----
--	Points of Interessts und Fieldnumbers Overlay
--	Custom1 und custom2
----
function mapviewer:showCustomOverlays()
	----
	-- Points of Interessts
	----
	if self.showPoi then
		if self.bigmap.PoI.OverlayId ~= nil and self.bigmap.PoI.OverlayId ~= 0 then
			renderOverlay(self.bigmap.PoI.OverlayId, self.bigmap.PoI.poiPosX, self.bigmap.PoI.poiPosY, self.bigmap.PoI.width, self.bigmap.PoI.height);
		else
			g_currentMission:addWarning(g_i18n:getText("MV_ErrorPoICreateOverlay"), 0.018, 0.033);
			self.usePoi = false;
		end;
	end;
	----
	
	----
	-- Fieldnumbers Overlay
	----
	if self.showFNum then
		if self.bigmap.FNum.OverlayId ~= nil and self.bigmap.FNum.OverlayId ~= 0 then
			renderOverlay(self.bigmap.FNum.OverlayId, self.bigmap.FNum.FNumPosX, self.bigmap.FNum.FNumPosY, self.bigmap.FNum.width, self.bigmap.FNum.height);
		else
			g_currentMission:addWarning(g_i18n:getText("MV_ErrorFNumCreateOverlay"), 0.018, 0.033);
			self.useFNum = false; 
		end;
	end;
	----
end;
----

----
-- Funktion um einen HotSpot für jeden TipTrigger anzuzeigen
----
function mapviewer:showTipTriggerHotSpot()
	local t, z;
	local ttX, ttY, ttZ;
	local countFruits;
	local fillType;
	local fruitType;
	
	for k,v in pairs(g_currentMission.tipTriggers) do
		ttX, ttY, ttZ = getWorldTranslation(g_currentMission.tipTriggers[k].rootNode)
		self.ttPosX = ((((self.bigmap.mapDimensionX/2)+ttX)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
		self.ttPosZ = ((((self.bigmap.mapDimensionY/2)-ttZ)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
		
		renderOverlay(self.bigmap.iconTipTrigger.Icon.OverlayId,
					self.ttPosX-self.bigmap.iconTipTrigger.width/2, 
					self.ttPosZ-self.bigmap.iconTipTrigger.height/2, 
					self.bigmap.iconTipTrigger.width, 
					self.bigmap.iconTipTrigger.height);
	end;
end;
----

----
-- Maplegende anzeigen
----
function mapviewer:showMaplegende()
	if self.maplegende and self.useLegend then
		if self.bigmap.Legende.OverlayId ~=nil then
			setTextColor(0, 0, 0, 1);
			----
			-- Legende der Fahrzeuge Typen anzeigen
			----
			renderOverlay(self.bigmap.Legende.OverlayId, 
					self.bigmap.Legende.legPosX, 
					0,
					self.bigmap.Legende.width, 
					1);
			----
			local c = self.bigmap.Legende.Content;
			for i=1, table.getn(c) do
				if c[i].OverlayID ~= nil and c[i].OverlayID ~= 0 then
					renderOverlay(c[i].OverlayID,
									c[i].l_PosX,
									c[i].l_PosY, 
									0.015625, 
									0.015625);
					renderText(c[i].l_Txt, c[i].l_PosY, c[i].TxtSize, c[i].Txt);
				else
					renderText(c[i].l_Txt, c[i].l_PosY, c[i].TxtSize, "Legenden Icon nicht vorhanden");
				end;
			end;
			self.printInfo = false;

			self.l_PosY = 1-0.02441 - 0.007324 - 0.015625 - self.bigmap.Legende.height;
			
			local LegTxtPosX = self.bigmap.Legende.legPosX + 0.029297;
			local LegOvIDPosX = self.bigmap.Legende.legPosX + 0.007324;

			for k,v in pairs(VehicleTypeUtil.vehicleTypes) do
				if self.bigmap.attachmentsTypes.overlays[VehicleTypeUtil.vehicleTypes[k].name] ~= nil then 
						renderOverlay(self.bigmap.attachmentsTypes.overlays[VehicleTypeUtil.vehicleTypes[k].name],
									LegOvIDPosX,
									self.l_PosY, 
									self.bigmap.attachmentsTypes.width,
									self.bigmap.attachmentsTypes.height);

					if g_i18n:hasText("MV_AttachType" .. VehicleTypeUtil.vehicleTypes[k].name) then
						renderText(LegTxtPosX, self.l_PosY, 0.016, g_i18n:getText("MV_AttachType" .. VehicleTypeUtil.vehicleTypes[k].name));
					else
						renderText(LegTxtPosX, self.l_PosY, 0.016, VehicleTypeUtil.vehicleTypes[k].name);
					end;
				else		-- TODO: Übersetzen
					renderOverlay(self.bigmap.attachmentsTypes.overlays["other"],
								LegOvIDPosX,
								self.l_PosY, 
								self.bigmap.attachmentsTypes.width,
								self.bigmap.attachmentsTypes.height);
					renderText(LegTxtPosX, self.l_PosY, 0.016, tostring(VehicleTypeUtil.vehicleTypes[k].name));
				end;
				self.l_PosY = self.l_PosY - 0.020;
				
				----
				--	Wenn mehr zeilen als verfügbar angezeigt werden sollen
				----
				if self.l_PosY < 0 then
					--- Weiteren Hintergrund zeichenen
					self.l_PosY = 1;
					LegOvIDPosX = LegOvIDPosX + 0.025 + self.bigmap.Legende.width;
					LegTxtPosX = LegTxtPosX + 0.025 + self.bigmap.Legende.width;
					
					renderOverlay(self.bigmap.Legende.OverlayId, 
						self.bigmap.Legende.legPosX + 0.025 + self.bigmap.Legende.width, 
						0, --self.bigmap.Legende.legPosY, 
						self.bigmap.Legende.width, 
						1); --self.bigmap.Legende.height
				end;
				----
			end;
			----
			setTextColor(1, 1, 1, 0);
			
		end;	--if legende nicht NIL
	elseif self.bigmap.Legende.OverlayId == nil or self.bigmap.Legende.OverlayId == 0 then		-- TODO: Übersetzen
		renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Rendern der Legende Fehlgeschlagen");
		print(g_i18n:getText("mapviewtxt") .. " : Rendern der Maplegende fehlgeschlagen");
		print(g_i18n:getText("mapviewtxt") .. " : Error rendering map legend");
	end;
	----
end;
----

----
--
----
function mapviewer:updateTick(dt)
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
			mapviewer:initMapViewer();
		end;
	end;
	
	----
	-- Nur wenn Variablen initialisiert sind, auf Tasten eingaben reagieren
	----
	if not self.mvInit then 
		return;
	end;
	----

	----
	-- Auf Taste zum MapViewer einblenden reagieren
	----
	if InputBinding.hasEvent(InputBinding.BIGMAP_Activate) then
		if self.bigmap.OverlayId.ovid ~= nil and self.bigmap.OverlayId.ovid ~= 0 then
			self.mapvieweractive=not self.mapvieweractive;
			if not self.mapvieweractive then
				----
				-- Wenn MapViewer deaktiviert wird, F1 Hilfe wieder herstellen
				g_currentMission.showHelpText = self.showHelpTxt;
				----
				g_mouseControlsHelp.active = true; 
				InputBinding.setShowMouseCursor(false); 
				InputBinding.wrapMousePositionEnabled = true; 
				if (g_currentMission.player.isEntered) then
					g_currentMission.player.isFrozen = false;
				end;
				g_currentMission.showHudEnv = true;
			else
				----
				--	Merken ob F1 Hilfe aktiviert ist
				----
				self.showHelpTxt = g_currentMission.showHelpText;
				----
				g_currentMission.showHudEnv = false;
			end;
		else
			self.mv_Error = not self.mv_Error;
		end;
	end;
	----

	----
	-- Auf Taste zum Legende einblenden reagieren
	----
	if self.mapvieweractive and InputBinding.hasEvent(InputBinding.BIGMAP_Legende) then
		if self.mapvieweractive and self.useLegend then
			--Legende einblenden
			self.maplegende = not self.maplegende;
			self.printInfo = self.maplegende;
		end;
	end;
	----
	
	----
	-- Erzeugen des Feldwachstumsoverlay in Testphase
	----
	if self.mapvieweractive then
		--self:mv_createMapStateOverlay();
		--generateFoliageStateOverlayFruitTypeColors(self.mv_FoliageStateOverlays)
		--generateFoliageStateOverlayGrowthStateColors(self.mv_FoliageStateOverlays)
		--g_inGameMenu:checkFoliageStateOverlayReady()
	end;
	----
	
	----
	-- Auf Taste zum Tastenbelegung einblenden reagieren
	----
	if self.mapvieweractive and InputBinding.hasEvent(InputBinding.BIGMAP_KeyHelp) then
		if self.mapvieweractive then
			self.showKeyHelp = not self.showKeyHelp;
		end;
	end;
	----

	----
	-- Auf Taste zum Overlay wechseln reagieren
	----
	if self.mapvieweractive and InputBinding.hasEvent(InputBinding.BIGMAP_SwitchOverlay) then
		--self.numOverlay = self.numOverlay+1;

		----
		-- Alle Overlays deaktivieren
		----
		self.showPoi = false;
		self.showFNum = false;
		self.showCP = false;
		self.showHorseShoes = false;
		self.showHotSpots = false;
		self.showTipTrigger = false;
		self.showFieldStatus = false;

		for i=1, table.getn(self.Overlays.names) do
			self.Overlays.active[string.format("mode%s",tostring(i))] = false;
		end;
		self.Overlays.active["mode10"] = true;
		----

		-- if self.numOverlay == 1 then	--nur Feldnummernhotspots und Besitzstatus
			-- self.showHotSpots = true;
			-- self.showTipTrigger = true;
		-- end;
		
		-- if self.numOverlay == 2 then	--nur Feldnummern
			-- self.showFNum = true;
			-- self.showHotSpots = false;
		-- end;
		
		-- if self.numOverlay == 3 then	--nur PoI
            -- self.showPoi = true;
			-- self.showHotSpots = false;
		-- end;
		
		-- if self.numOverlay == 4 then	--Poi und Nummern
			-- self.showHotSpots = false;
			-- self.showPoi = true;
			-- self.showFNum = true;
		-- end;
		
		-- if self.numOverlay == 5 and self.useHorseShoes then	--HorseShoes anzeigen
            -- self.showHorseShoes = true;
		-- elseif self.numOverlay == 5 and not self.useHorseShoes then
			-- self.numOverlay = self.numOverlay +1;
		-- end;
		
		-- if self.numOverlay == 6 and self.useCoursePlay then	--Courseplay vorhanden, dann anzeigen
            -- self.showCP = true;
		-- elseif self.numOverlay == 6 and not self.useCoursePlay then
			-- self.numOverlay = self.numOverlay +1;
		-- end;
		
		-- if self.numOverlay > 6 then
			-- self.numOverlay = 0;		--Alles aus
			-- self.showTipTrigger = false;
			-- self.showPoi = false;
			-- self.showFNum = false;
            -- self.showCP = false;
            -- self.showHorseShoes = false;
			-- self.showHotSpots = false;
		-- end;

		-- if self.Debug.active and self.numOverlay > 0 then
			-- print("Debug Key BIGMAP_SwitchOverlay: ");
            -- print(string.format("|| %s || %s : %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_Mode" .. self.numOverlay), g_i18n:getText("MV_Mode".. self.numOverlay .."Name")));
		-- end;
	end;
	
	----
	-- Panel Position an Fahrzeug anpassen, nur wenn Karte Aktiv und ein Panel aufgerufen wurde
	----
	if self.mapvieweractive and self.showInfoPanel then 
		local obj = nil;
		if self.bigmap.InfoPanel.lastVehicle ~= nil and type(self.bigmap.InfoPanel.lastVehicle) == "table" then
			if g_currentMission.nodeToVehicle[self.bigmap.InfoPanel.lastVehicle.rootNode] ~= nil then
				obj = self.bigmap.InfoPanel.lastVehicle.rootNode;
			else
				self.showInfoPanel = false;
			end;
		elseif self.bigmap.InfoPanel.lastTrigger ~= nil and type(self.bigmap.InfoPanel.lastTrigger) == "table" then
			obj = self.bigmap.InfoPanel.lastTrigger.rootNode;
		elseif self.bigmap.InfoPanel.lastField ~= nil and type(self.bigmap.InfoPanel.lastField) == "table" then
			obj = self.bigmap.InfoPanel.lastField.fieldBuyTrigger;
		else
			self.showInfoPanel = false;
			print(string.format("|| %s || %s ||", g_i18n:getText("mapviewtxt"), g_i18n:getText("MV_ErrorCreateInfoPanel")));
		end;	
		
		if self.showInfoPanel and obj ~= nil then
			--	Position des angeklickten Objektes (Fahrzeug oder Trigger etc.)
			local posX1, posY1, posZ1 = getWorldTranslation(obj);
			local distancePosX = ((((self.bigmap.mapDimensionX/2)+posX1)/self.bigmap.mapDimensionX)*self.bigmap.mapWidth);
			local distancePosZ = ((((self.bigmap.mapDimensionY/2)-posZ1)/self.bigmap.mapDimensionY)*self.bigmap.mapHeight);
			----
			
			local panelWidth = self.bigmap.InfoPanel.width;
			
			--	Standard Images für obere und untere Grafik zuweisen
			self.bigmap.InfoPanel.top.image = {file = "", OverlayId = nil, width = 0.15, height= 0.0078125, Pos = {x=0, y=0}};
			self.bigmap.InfoPanel.top.image.OverlayId = self.bigmap.InfoPanel.top.closebar.OverlayId;
			self.bigmap.InfoPanel.top.image.width = self.bigmap.InfoPanel.top.closebar.width;
			self.bigmap.InfoPanel.top.image.height = self.bigmap.InfoPanel.top.closebar.height;
			
			self.bigmap.InfoPanel.bottom.image = {file = "", OverlayId = nil, width = 0.15, height= 0.03125, Pos = {x=0, y=0}};
			self.bigmap.InfoPanel.bottom.image.OverlayId = self.bigmap.InfoPanel.bottom.bubblemid.OverlayId;
			self.bigmap.InfoPanel.bottom.image.width = self.bigmap.InfoPanel.bottom.bubblemid.width;
			self.bigmap.InfoPanel.bottom.image.height = self.bigmap.InfoPanel.bottom.bubblemid.height;
			----
			
			----
			-- Funktion zum berechnen der Position
			----
			local function calcPos()
				self.bigmap.InfoPanel.top.image.Pos.x = distancePosX-panelWidth/2;
				self.bigmap.InfoPanel.top.image.Pos.y = distancePosZ + self.bigmap.InfoPanel.bottom.image.height + self.bigmap.InfoPanel.background.height;
				
				self.bigmap.InfoPanel.background.Pos.x = distancePosX-panelWidth/2;
				self.bigmap.InfoPanel.background.Pos.y = distancePosZ + self.bigmap.InfoPanel.bottom.image.height;
				
				self.bigmap.InfoPanel.bottom.image.Pos.x = distancePosX-panelWidth/2;
				self.bigmap.InfoPanel.bottom.image.Pos.y = distancePosZ;
			end;
			----
			
			----
			--	Übertragen der Position auf Panel
			----
			
			calcPos();
			
			----
			--	Prüfen der berechneten Position zum Bildschirmrand
			----
			--	rechte Position
			--	Panel mit Bubble nach rechts-unten
			----
			if distancePosX + panelWidth/2 > self.bigmap.mapWidth then
				self.bigmap.InfoPanel.bottom.image.OverlayId = self.bigmap.InfoPanel.bottom.bubbleright.OverlayId;
				self.bigmap.InfoPanel.bottom.image.width = self.bigmap.InfoPanel.bottom.bubbleright.width;
				self.bigmap.InfoPanel.bottom.image.height = self.bigmap.InfoPanel.bottom.bubbleright.height;

				self.bigmap.InfoPanel.top.image.Pos.x = self.bigmap.InfoPanel.top.image.Pos.x - panelWidth/2;
				self.bigmap.InfoPanel.background.Pos.x = self.bigmap.InfoPanel.background.Pos.x - panelWidth/2;
				self.bigmap.InfoPanel.bottom.image.Pos.x = self.bigmap.InfoPanel.bottom.image.Pos.x - panelWidth/2;
			end;
			
			local panelHeight = self.bigmap.InfoPanel.top.image.height + self.bigmap.InfoPanel.background.height + self.bigmap.InfoPanel.bottom.image.height;

			----
			--	obere Position
			--	Panel mit Bubble mittig-oben
			----
			if distancePosZ + panelHeight > self.bigmap.mapHeight then
				self.bigmap.InfoPanel.top.image.OverlayId = self.bigmap.InfoPanel.top.bubblemid.OverlayId;
				self.bigmap.InfoPanel.top.image.width = self.bigmap.InfoPanel.top.bubblemid.width;
				self.bigmap.InfoPanel.top.image.height = self.bigmap.InfoPanel.top.bubblemid.height;

				self.bigmap.InfoPanel.bottom.image.OverlayId = self.bigmap.InfoPanel.bottom.closebar.OverlayId;
				self.bigmap.InfoPanel.bottom.image.width = self.bigmap.InfoPanel.bottom.closebar.width;
				self.bigmap.InfoPanel.bottom.image.height = self.bigmap.InfoPanel.bottom.closebar.height;

				self.bigmap.InfoPanel.top.image.Pos.y = distancePosZ - self.bigmap.InfoPanel.top.image.height;
				self.bigmap.InfoPanel.background.Pos.y = self.bigmap.InfoPanel.top.image.Pos.y - self.bigmap.InfoPanel.background.height;
				self.bigmap.InfoPanel.bottom.image.Pos.y = self.bigmap.InfoPanel.background.Pos.y - self.bigmap.InfoPanel.bottom.image.height;
			end;
			
			----
			--	linke Position
			--	Panel mit Bubble nach links-unten
			----
			if distancePosX - panelWidth/2 < 0 then
				self.bigmap.InfoPanel.bottom.image.OverlayId = self.bigmap.InfoPanel.bottom.bubbleleft.OverlayId;
				self.bigmap.InfoPanel.bottom.image.width = self.bigmap.InfoPanel.bottom.bubbleleft.width;
				self.bigmap.InfoPanel.bottom.image.height = self.bigmap.InfoPanel.bottom.bubbleleft.height;

				self.bigmap.InfoPanel.top.image.Pos.x = self.bigmap.InfoPanel.top.image.Pos.x + panelWidth/2;
				self.bigmap.InfoPanel.background.Pos.x = self.bigmap.InfoPanel.background.Pos.x + panelWidth/2;
				self.bigmap.InfoPanel.bottom.image.Pos.x = self.bigmap.InfoPanel.bottom.image.Pos.x + panelWidth/2;
			end;			
			----

			----
			--	Oben/Links
			--	Panel mit Bubble nach links-oben
			----
			if distancePosX - panelWidth/2 < 0 and distancePosZ + panelHeight > self.bigmap.mapHeight then
			-- Obere Grafik setzen
				self.bigmap.InfoPanel.top.image.OverlayId = self.bigmap.InfoPanel.top.bubbleleft.OverlayId;
				self.bigmap.InfoPanel.top.image.width = self.bigmap.InfoPanel.top.bubbleleft.width;
				self.bigmap.InfoPanel.top.image.height = self.bigmap.InfoPanel.top.bubbleleft.height;
			-- untere Grafik setzen
				self.bigmap.InfoPanel.bottom.image.OverlayId = self.bigmap.InfoPanel.bottom.closebar.OverlayId;
				self.bigmap.InfoPanel.bottom.image.width = self.bigmap.InfoPanel.bottom.closebar.width;
				self.bigmap.InfoPanel.bottom.image.height = self.bigmap.InfoPanel.bottom.closebar.height;
			-- Panel richtig zum Objekt positionieren Y-position (unterhalb)
				self.bigmap.InfoPanel.top.image.Pos.y = distancePosZ - self.bigmap.InfoPanel.top.image.height;
				self.bigmap.InfoPanel.background.Pos.y = self.bigmap.InfoPanel.top.image.Pos.y - self.bigmap.InfoPanel.background.height;
				self.bigmap.InfoPanel.bottom.image.Pos.y = self.bigmap.InfoPanel.background.Pos.y - self.bigmap.InfoPanel.bottom.image.height;
			-- Panel richtig zum Objekt positionieren X-position (rechts)
				self.bigmap.InfoPanel.top.image.Pos.x = distancePosX;
				self.bigmap.InfoPanel.background.Pos.x = distancePosX;
				self.bigmap.InfoPanel.bottom.image.Pos.x = distancePosX;
			end;
			----
			
			----
			--	Oben/rechts
			--	Panel mit Bubble nach rechts-oben
			----
			if distancePosX + panelWidth/2 > 1 and distancePosZ + panelHeight > self.bigmap.mapHeight then
			-- Obere Grafik setzen
				self.bigmap.InfoPanel.top.image.OverlayId = self.bigmap.InfoPanel.top.bubbleright.OverlayId;
				self.bigmap.InfoPanel.top.image.width = self.bigmap.InfoPanel.top.bubbleright.width;
				self.bigmap.InfoPanel.top.image.height = self.bigmap.InfoPanel.top.bubbleright.height;
			-- untere Grafik setzen
				self.bigmap.InfoPanel.bottom.image.OverlayId = self.bigmap.InfoPanel.bottom.closebar.OverlayId;
				self.bigmap.InfoPanel.bottom.image.width = self.bigmap.InfoPanel.bottom.closebar.width;
				self.bigmap.InfoPanel.bottom.image.height = self.bigmap.InfoPanel.bottom.closebar.height;
			-- Panel richtig zum Objekt positionieren Y-position (Oberhalb)
				self.bigmap.InfoPanel.top.image.Pos.y = distancePosZ - self.bigmap.InfoPanel.top.image.height;
				self.bigmap.InfoPanel.background.Pos.y = self.bigmap.InfoPanel.top.image.Pos.y - self.bigmap.InfoPanel.background.height;
				self.bigmap.InfoPanel.bottom.image.Pos.y = self.bigmap.InfoPanel.background.Pos.y - self.bigmap.InfoPanel.bottom.image.height;
			-- Panel richtig zum Objekt positionieren X-position (links)
				self.bigmap.InfoPanel.top.image.Pos.x = distancePosX - panelWidth;
				self.bigmap.InfoPanel.background.Pos.x = distancePosX - panelWidth;
				self.bigmap.InfoPanel.bottom.image.Pos.x = distancePosX - panelWidth;
			end;
			----
		end;
	end;	
	----
	
	----
	--	Manuelles einblenden der Overlays
	----
	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_1) then
			self.showTipTrigger = not self.showTipTrigger;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_1")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay TipTrigger Aktiv? %s", tostring(self.showTipTrigger)));
			self.Overlays.active["mode1"] = self.showTipTrigger;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_2) then
			self.showFNum = not self.showFNum;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_2")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay Feldnummern Aktiv? %s", tostring(self.showFNum)));
			self.Overlays.active["mode2"] = self.showFNum;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_3) then
			self.showPoi = not self.showPoi;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_3")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay POI Aktiv? %s", tostring(self.showPoi)));
			self.Overlays.active["mode3"] = self.showPoi;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_4) then
			self.showHotSpots = not self.showHotSpots;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_4")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay HotSpots Aktiv? %s", tostring(self.showHotSpots)));
			self.Overlays.active["mode4"] = self.showHotSpots;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_5) then
            self.showCP = not self.showCP;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_5")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay CoursePlay Aktiv? %s", tostring(self.showCP)));
			self.Overlays.active["mode5"] = self.showCP;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_6) then
            self.showHorseShoes = not self.showHorseShoes;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_6")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay Hufeisen Aktiv? %s", tostring(self.showHorseShoes)));
			self.Overlays.active["mode6"] = self.showHorseShoes;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_7) then
			self.showFieldStatus = not self.showFieldStatus;
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_7")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			-- print(string.format("Overlay Aktiv? %s", tostring(self.showFieldStatus)));
			self.Overlays.active["mode7"] = self.showFieldStatus;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_8) then
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_8")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			--print(string.format("Overlay Aktiv? %s", tostring(self.)));
			--self.Overlays.active["mode8"] = self.;
		end;
	end;

	if self.mapvieweractive then
		if InputBinding.hasEvent(InputBinding.BIGMAP_Overlay_9) then
			-- print(string.format("%s ->", g_i18n:getText("BIGMAP_Overlay_9")));
			-- print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			--print(string.format("Overlay Aktiv? %s", tostring(self.)));
			--self.Overlays.active["mode9"] = self.;
		end;
	end;
	----
	
	----
	-- BigMap Transparenz erhöhen und verringern
	----
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransMinus) then
		if self.bigmap.mapTransp > 0.1 and self.mapvieweractive then
			self.bigmap.mapTransp = self.bigmap.mapTransp - 0.05;
		end;
	end;
	----
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransPlus) then
		if self.bigmap.mapTransp < 1 and self.mapvieweractive then
			self.bigmap.mapTransp = self.bigmap.mapTransp + 0.05;
		end;
	end;

	----
	-- Im Debug Informationen zu Transparenz ausgeben
	----
	if self.Debug.active then
		if InputBinding.hasEvent(InputBinding.BIGMAP_TransPlus) then
			print(string.format("%s ->", g_i18n:getText("BIGMAP_TransPlus")));
			print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			print(string.format("Aktuelle Transparenz %s", tostring(self.bigmap.mapTransp)));
		end;

		if InputBinding.hasEvent(InputBinding.BIGMAP_TransMinus) then
			print(string.format("%s ->", g_i18n:getText("BIGMAP_TransMinus")));
			print(string.format("MapViewer Aktiv? %s", tostring(self.mapvieweractive)));
			print(string.format("Aktuelle Transparenz %s", tostring(self.bigmap.mapTransp)));
		end;		
	end;
	----
	-- ende Transparenz umschalten
	----
	
	----
	-- Wenn Transparenz aktiv, Mauszeiger ausblenden
	----
	if self.mapvieweractive then 
		if self.bigmap.mapTransp > 1 then
			self.bigmap.mapTransp = 1;
		end;
		
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
	end;	
	----
	
	----
	-- Tasten Modofizierer für Teleport
	----
	if self.mapvieweractive and self.bigmap.mapTransp >= 1 then
		if InputBinding.isPressed(InputBinding.BIGMAP_Teleport) then
			self.useTeleport= true; 
		else
			self.useTeleport = false;
		end;
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
	--for k,v in pairs(g_currentMission.tipTriggers) do
		z=z+1;
		--print("TipTrigger: " .. tostring(z));
		--print(tostring(k) .."("..type(v)..")="..tostring(v));
		--for i,j in pairs(g_currentMission.tipTriggers[k]) do
			--print(tostring(i).."("..type(j)..")="..tostring(j));
			--table.show(g_currentMission.tipTriggers[k], "TipTrigger: " .. tostring(z))
		--end;
	--end;
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
		if  self.Debug.active then
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