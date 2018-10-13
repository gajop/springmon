----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Copy this file to the luaui/widgets folder

-- Set this line to the springmon installation folder
SPRINGMON_DIR = "libs/springmon/"

-- Do NOT modify the following lines
function widget:GetInfo()
    return {
        name      = "springmon",
        desc      = "Spring file monitor and autoreloader",
        author    = "gajop",
        license   = "MIT",
        layer     = -999,
		enabled   = true,
		handler   = true,
		api       = true,
		hidden    = true,
    }
end

if Script.GetName() == "LuaUI" then
	VFS.Include(SPRINGMON_DIR .. "luaui/widgets/api_springmon.lua", nil, VFS.DEF_MODE)
end
