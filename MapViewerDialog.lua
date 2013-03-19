MapViewerDialog = {}
local MapViewerDialog_mt = Class(MapViewerDialog)

function MapViewerDialog:new()
	local self = {}
	self = setmetatable(self, MapViewerDialog_mt)
	
	self.mode = 1;
	self.numberOfModes = 6;
	
	return self
end
function MapViewerDialog:onOpen(element)
	g_currentMission.isPlayerFrozen = true;
	InputBinding.setShowMouseCursor(true);
	self:updateDialog();
end

function MapViewerDialog:onClose(element)
	g_currentMission.isPlayerFrozen = false
	InputBinding.setShowMouseCursor(false)
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
