script_name('RPColor')
script_author("Nishikinov")
require "lib.moonloader"
local sampev = require 'lib.samp.events'
local inicfg = require "inicfg"

if not doesFileExist('moonloader\\config\\rpcolor.ini') then
  if not doesDirectoryExist('moonloader\\config') then
    createDirectory('moonloader\\config')
  end
	local ini = {
		settings = {
			currentcolor = 'E75480',
			defaultcolor = 'E75480', -- Стандартный цвет: D0AEEB
		}
	}
	inicfg.save(ini, 'rpcolor')
end

local ini = inicfg.load(nil, 'rpcolor')

function samp.onPlayerChatBubble(playerId, color, distance, duration, message)
	if sampIsPlayerConnected(playerId) and tostring(color) == "-413892353" then
		emul_rpc('onPlayerChatBubble', { tonumber(playerId), -1, 15, 5000, tostring("(( "..message.." ))") })
	end
end

function sampev.onServerMessage(color, text)
	if color == -413892353 or color == -793842689 then
		sampAddChatMessage("{"..ini.settings.currentcolor.."}"..text, -1)
		return false
	elseif text:find('{E75480}') then
		text = string.gsub(text, '({E75480})', "")
		if text:find('{E75480},') then
			text = string.gsub(text, '(".*")', "{ffffff}%1{"..ini.settings.currentcolor.."}")
		end
		sampAddChatMessage(text, -1)
		return false
	end
end

function chatColor(color)
  local color = string.match(color, '(.*)')
  if color ~= '' then
		sampAddChatMessage("Цвет РП чата изменен на: ".."{"..color.."}"..color, -1)
		ini.settings.currentcolor = color
		inicfg.save(ini, 'rpcolor')
  else
    sampAddChatMessage("Цвет РП чата изменен на {"..ini.settings.defaultcolor.."}стандартный", -1)
		ini.settings.currentcolor = ini.settings.defaultcolor
		inicfg.save(ini, 'rpcolor')
  end
end

function main()
	wait(0)
	sampRegisterChatCommand("rpcolor", chatColor)
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {
     	['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end
