local LOG_SECTION = "springmon"

-- local widgetHandler = WG.SB_widgetHandler

-- maps absolute path -> widget name
local widgetPathToName = {}

local function FileChanged(command)
    local path = command.path
    local widgetName = widgetPathToName[path]
    if not widgetName then
        Spring.Log(LOG_SECTION, LOG.WARNING,
            "No widget found for file: " .. tostring(path) .. ". Reload manually")
        return
    end
    Spring.Log(LOG_SECTION, LOG.NOTICE, 
        "Reloading widget: " .. tostring(widgetName) .. "...")
    widgetHandler:DisableWidget(widgetName)
    widgetHandler:EnableWidget(widgetName)
end

-- TODO: belongs to Path.Recurse lib
local function Recurse(path, f, opts)
	opts = opts or {}
	for _, file in pairs(VFS.DirList(path), "*", opts.mode) do
		f(file)
	end
	for _, dir in pairs(VFS.SubDirs(path, "*", opts.mode)) do
		if opts.apply_folders then
			f(dir)
		end
		Recurse(dir, f, opts)
	end
end

local function TrackFiles()
    -- track only the relevant Lua context dir, e.g. "LuaUI" or "LuaRules"
    local luaContextDir = Script.GetName()
    Spring.Log(LOG_SECTION, LOG.NOTICE, "Watching files for changes...")
    Recurse(luaContextDir, function(f)
        local absPath = VFS.GetFileAbsolutePath(f)
        local archiveName = VFS.GetArchiveContainingFile(f)
        if archiveName == Game.gameName then
            Spring.Log(LOG_SECTION, LOG.NOTICE, f .. " -> " .. tostring(absPath) .. " | " .. tostring(archiveName))
            WG.Connector.Send("WatchFile", {
                path = absPath
            })
        end
    end, {
        mode = VFS.ZIP
    })
end

local function LoadWidgetList()
    for name, w in pairs(widgetHandler.knownWidgets) do
        local vfsFilePath = w.filename
        local absPath = VFS.GetFileAbsolutePath(vfsFilePath)
        local archiveName = VFS.GetArchiveContainingFile(vfsFilePath)
        if archiveName == Game.gameName then
            widgetPathToName[absPath] = name
        end
    end
end

function widget:Initialize()
    WG.Connector.Register("FileChanged", FileChanged)
    LoadWidgetList()
    TrackFiles()
end
