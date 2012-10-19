local Util = require "imagesize.util"

local MIME_TYPE = "image/x-ms-bmp"

-- Size a Windows-ish BitMaP image
-- Adapted from code contributed by Aldo Calpini <a.calpini@romagiubileo.it>
local function size (stream, options)
    local buf = stream:read(26)
    if not buf or buf:len() ~= 26 then
        return nil, nil, "file isn't big enough to contain a BMP header"
    end

    return Util.get_uint32_le(buf, 19), Util.get_uint32_le(buf, 23), MIME_TYPE
end

return size
-- vi:ts=4 sw=4 expandtab
