-- mein Mapviewer, anzeigen der PDA Map auf dem Bildschirm
----
-- $Rev$:     Revision der letzten Änderung
-- $Author$:  Author der letzten Änderung
-- $Date$:    Date der letzten Änderung
----
-- Mein Mapviewer, anzeigen der PDA Map auf dem Bildschirm
----

mapviewer={};
mapviewer.moddir=g_currentModDirectory;

function mapviewer:loadMap(name)
	print("mapviewer:loadmap() :" .. string.format("|| %s ||", g_i18n:getText("mapviewtxt")));
	local userXMLPath = Utils.getFilename("mapviewer.xml", mapviewer.moddir);
	self.xmlFile = loadXMLFile("xmlFile", userXMLPath);
	----
	-- Datei mit Mapdaten
	----

	self.mapvieweractive=false;
	self.maplegende = false;
	self.activePlayerNode=0;
	self.mvInit = false;
	self.showFNum = false;
	self.showPoi = false;
    self.showCP = false;
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
	self.l_PosY = 0;	--Legende Y Position
	self.TEntfernung=0;
	self.TRichtung=0;
	self.playerRotY=0;
	self.plyname = {};
	self.bigmap ={};
	
	----
	-- Debug Modus
	----
	self.Debug = false;
	----
end;

function mapviewer:InitMapViewer()
	----
	-- Initialisierung beginnen
	----
	
	print(string.format("|| %s || MapViewer:Init() ||", g_i18n:getText("mapviewtxt")));
	
	self.bigmap.OverlayId = {};
    self.bigmap.PoI = {};
    self.bigmap.FNum = {};

	self.bigmap.mapDimensionX = 2048;
	self.bigmap.mapDimensionY = 2048;
	self.bigmap.mapWidth = 1;
	self.bigmap.mapHeight = 1;
	self.bigmap.mapPosX = 0.5-(self.bigmap.mapWidth/2);
	self.bigmap.mapPosY = 0.5-(self.bigmap.mapHeight/2);
	self.bigmap.mapTransp = 1;

    self.bigmap.mapDimensionX = 2048;
    self.bigmap.mapDimensionY = 2048;
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
        print(g_i18n:getText("mapviewtxt") .. " : Kann 'PoI Overlay' nicht erzeugen, PoI ist deaktiviert, PoI nicht in dieser Map unterstützt");
        print(g_i18n:getText("mapviewtxt") .. " : Could not Create PoI Overlay, PoI is disabled. PoI not supported in this Map");
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
			print(g_i18n:getText("mapviewtxt") .. " : Kann 'Feldnummern Overlay' nicht erzeugen, FNum ist deaktiviert, PoI nicht in dieser Map unterstützt");
			print(g_i18n:getText("mapviewtxt") .. " : Could not Create Fieldnumber Overlay, PoI is disabled. PoI not supported in this Map");
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
	self.bigmap.IconAttachments.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconAttachment#width"), 0.0078125);
	self.bigmap.IconAttachments.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconAttachment#height"), 0.0078125);
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
    self.bigmap.iconIsBroken.Icon.file = Utils.getFilename(Utils.getNoNil(getXMLString(self.xmlFile, "mapviewer.map.icons.iconIsBroken#file"), "icons/iconIsBroken.png"), self.moddir);
	self.bigmap.iconIsBroken.Icon.OverlayId = createImageOverlay(self.bigmap.iconIsBroken.Icon.file);
	self.bigmap.iconIsBroken.width = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#width"), 0.0078125);
	self.bigmap.iconIsBroken.height = Utils.getNoNil(getXMLFloat(self.xmlFile, "mapviewer.map.icons.iconIsBroken#height"), 0.0078125);
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
	-- Initialisierung abgeschlossen
	print(string.format("|| %s || MapViewer:Init() Abgeschlossen ||", g_i18n:getText("mapviewtxt")));
	----
	self.mvInit = true;
end;

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
end;
--

--
-- Auf Tastendruck reagieren
--
function mapviewer:keyEvent(unicode, sym, modifier, isDown)
	-- Tatse um den Debugmodus zu aktivieren
	-- ALT+d
	if isDown and sym == Input.KEY_d and bitAND(modifier, Input.MOD_ALT) > 0 then
		self.Debug=not self.Debug;
		print("Debug = "..tostring(self.Debug));
	end;
	
	-- Umschalten der Mapgrösse für 2048 (Standard) und 4096
	if isDown and sym == Input.KEY_m and bitAND(modifier, Input.MOD_ALT) > 0 then
		if self.bigmap.mapDimensionX == 2048 then
			self.bigmap.mapDimensionX = 4096;
			self.bigmap.mapDimensionY = 4096;
		else
			self.bigmap.mapDimensionX = 2048;
			self.bigmap.mapDimensionY = 2048;
		end;
		print(string.format("Mapgroesse = %d x %d", self.bigmap.mapDimensionX, self.bigmap.mapDimensionY));
	end;
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

	-- Taste für Map anzeigen
	if InputBinding.hasEvent(InputBinding.BIGMAP_Activate) then
		self.mapvieweractive=not self.mapvieweractive;
	end;
	--Taste für Legende einblenden
	if InputBinding.hasEvent(InputBinding.BIGMAP_Legende) then
		if self.mapvieweractive then
			--Legende einblenden
			self.maplegende = not self.maplegende;
		end;
	end;

	--Overlay wechseln
	if InputBinding.hasEvent(InputBinding.BIGMAP_SwitchOverlay) then
		self.numOverlay = self.numOverlay+1;
		if self.numOverlay == 1 then	--nur Feldnummern
			self.showPoi = false;
			self.showFNum = true;
		elseif self.numOverlay == 2 then	--nur PoI
			self.showFNum = false;
			self.showPoi = true;
		elseif self.numOverlay == 3 then	--Poi und Nummern
			self.showPoi = true;
			self.showFNum = true;
		elseif self.numOverlay == 4 then	--Courseplay Kurse anzeigen
			self.showCP = true;
			self.showPoi = false;
			self.showFNum = false;
		else
			self.numOverlay = 0;		--Alles aus
			self.showPoi = false;
			self.showFNum = false;
            self.showCP = false;
		end;
        print(string.format("showCP:%s||showFNum:%s||showPoi:%s",tostring(self.showCP),tostring(self.showFNum),tostring(self.showPoi)));
		if self.Debug then
			print("Debug Key BIGMAP_SwitchOverlay: ");
			print(string.format("useFNum:%s||usePoi:%s",tostring(self.useFNum),tostring(self.usePoi)));
			print(string.format("numOverlay:%d||showFNum:%s||showPoi:%s",self.numOverlay,tostring(self.showFNum),tostring(self.showPoi)));
			mapviewer:tablecopy(self.bigmap.PoI, "bigmap.Poi");
			mapviewer:tablecopy(self.bigmap.FNum, "bigmap.FNum");
		end;
	end;
	
	--BigMap Transparenz erhöhen und verringern
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransMinus) then
		if self.bigmap.mapTransp < 1 then
			self.bigmap.mapTransp = self.bigmap.mapTransp + 0.05;
		end;
	end;
	if InputBinding.hasEvent(InputBinding.BIGMAP_TransPlus) then
		if self.bigmap.mapTransp > 0.1 then
			self.bigmap.mapTransp = self.bigmap.mapTransp - 0.05;
		end;
	end;
	-- ende Trasnparenz umschalten
end;

function mapviewer:draw()
	if self.mapvieweractive then
		if self.bigmap.OverlayId.ovid ~= nil and self.bigmap.OverlayId.ovid ~= 0 then
			setOverlayColor(self.bigmap.OverlayId.ovid, 1,1,1,self.bigmap.mapTransp);
			renderOverlay(self.bigmap.OverlayId.ovid, self.bigmap.mapPosX, self.bigmap.mapPosY, self.bigmap.mapWidth, self.bigmap.mapHeight);
		else
			renderText(0.25, 0.5-0.03, 0.024, string.format("Erzeugen des Mapviewers fehlgeschlagen, weitere Informationen in der Log.txt"));
			print(g_i18n:getText("mapviewtxt") .. " : Kann 'self.bigmap.OverlayId' nicht erzeugen");
			print(g_i18n:getText("mapviewtxt") .. " : Could not Create Map Overlay");
			if self.Debug then
				print("Debug: :draw()");
				print(string.format("self.useMapFile: %s", tostring(self.useMapFile)));
				print(string.format("self.bigmap.file: %s", self.bigmap.file));
				print(string.format("self.bigmap.OverlayId.ovid: %d", self.bigmap.OverlayId.ovid));
			end;
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

		--Points of Interessts
		if self.usePoi and self.showPoi then
			if self.bigmap.PoI.OverlayId ~= nil and self.bigmap.PoI.OverlayId ~= 0 then
				renderOverlay(self.bigmap.PoI.OverlayId, self.bigmap.PoI.poiPosX, self.bigmap.PoI.poiPosY, self.bigmap.PoI.width, self.bigmap.PoI.height);
			else
				print(g_i18n:getText("mapviewtxt") .. " : Kann 'PoI Overlay' nicht erzeugen");
				print(g_i18n:getText("mapviewtxt") .. " : Could not Create PoI Overlay");
				self.usePoi = not self.usePoi;
			end;
		end;
		
		--Fieldnumbers
		if self.useFNum and self.showFNum then
			if self.bigmap.FNum.OverlayId ~= nil and self.bigmap.FNum.OverlayId ~= 0 then
				renderOverlay(self.bigmap.FNum.OverlayId, self.bigmap.FNum.FNumPosX, self.bigmap.FNum.FNumPosY, self.bigmap.FNum.width, self.bigmap.FNum.height);
			else
				print(g_i18n:getText("mapviewtxt") .. " : Kann 'FNum Overlay' nicht erzeugen");
				print(g_i18n:getText("mapviewtxt") .. " : Could not Create FNum Overlay");
				self.useFNum = not self.useFNum;
			end;
		end;

		--Maplegende anzeigen
		if self.maplegende then
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
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Eigener Spieler auf Karte");
				--Andere Spieler Icon
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.player.mpArrowOverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Andere Spieler auf Karte");
				--Spieler auf Fahrzeug
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.IconSteerable.mpOverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Andere Spieler im Fahrzeug");
				--Leere Fahrzeug
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.IconSteerable.OverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Leere Fahrzeuge auf Karte");
				--Anbaugeräte, Anhänger
				self.l_PosY = self.l_PosY - 0.020;
				renderOverlay(self.bigmap.IconAttachments.Icon.front.OverlayId,
								self.bigmap.Legende.legPosX + 0.007324,
								self.l_PosY,
								0.015625, 
								0.015625);
				renderText(self.bigmap.Legende.legPosX + 0.029297, self.l_PosY, 0.012, "Anbaugeräte und Anhänger");
				setTextColor(1, 1, 1, 0);
			end;	--if legende nicht NIL
		elseif self.bigmap.Legende.OverlayId == nil then
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
                -- Auslesen der Kurse wenn CourcePlay vorhanden ist
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
			-- TODO:
			-- unbrauchbare Fahrzeuge mit weiterem Icon anzeigen
			--
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
			renderOverlay(self.bigmap.IconAttachments.Icon.front.OverlayId,
							self.buttonX-self.bigmap.IconAttachments.width/2, 
							self.buttonZ-self.bigmap.IconAttachments.height/2,
							self.bigmap.IconAttachments.width,
							self.bigmap.IconAttachments.height);
			setOverlayColor(self.bigmap.IconAttachments.Icon.front.OverlayId, 1, 1, 1, 1);
		end;
		-----
	end;
	----
	--Namen auf PDA anzeigen
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