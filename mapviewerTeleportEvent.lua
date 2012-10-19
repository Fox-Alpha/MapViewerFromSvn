----
--  MapViewerTeleportEvent
----
MapViewerTeleportEvent = {};
MapViewerTeleportEvent_mt = Class(MapViewerTeleportEvent, Event);
  
InitStaticEventClass(MapViewerTeleportEvent, "MapViewerTeleportEvent", EventIds.EVENT_MAPVIEWER_TELEPORT);
  
function MapViewerTeleportEvent:emptyNew()
	local self = Event:new(MapViewerTeleportEvent_mt);
	self.className="MapViewerTeleportEvent";
	return self;
end;
  
function MapViewerTeleportEvent:new(object, setNewPlyPosition)
	local self = MapViewerTeleportEvent:emptyNew()
	self.object = object;
	self.setNewPlyPosition = setNewPlyPosition;
	return self;
end;
  
function MapViewerTeleportEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.setNewPlyPosition = streamReadBool(streamId);
	self.object = networkGetObject(id);
	self:run(connection);
end;
  
function MapViewerTeleportEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.object));
	streamWriteBool(streamId, self.setNewPlyPosition);
end;
  
function MapViewerTeleportEvent:run(connection)
	self.object:setNewPlayerPos(self.setNewPlyPosition, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(MapViewerTeleportEvent:new(self.object, self.setNewPlyPosition), nil, connection, self.object);
	end;
end;