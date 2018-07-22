script_name('RPColor')
script_author("Nishikinov")
require "lib.moonloader"
local sampev = require 'lib.samp.events'
local inicfg = require "inicfg"
local ini = inicfg.load(nil, 'rpcolor')

if not doesFileExist('moonloader\\config\\rpcolor.ini') then
  if not doesDirectoryExist('moonloader\\config') then
    createDirectory('moonloader\\config')
  end
	local ini = {
		settings = {
			currentcolor = 'E75480',
			defaultcolor = 'E75480', -- ����������� ����: D0AEEB
		}
	}
	inicfg.save(ini, 'rpcolor')
end

function sampev.onServerMessage(color, text)
	if color == -413892353 or color == -793842689 then
		sampAddChatMessage("{"..ini.settings.currentcolor.."}"..text, -1)
		print(ini.settings.currentcolor)
		print(color)
		return false
	end
end

function chatColor(color)
  local color = string.match(color, '(.*)')
  if color ~= '' then
		sampAddChatMessage("���� �� ���� ������� ��: ".."{"..color.."}"..color, -1)
		ini.settings.currentcolor = color
		inicfg.save(ini, 'rpcolor')
  else
    sampAddChatMessage("���� �� ���� ������� �� {"..ini.settings.defaultcolor.."}�����������", -1)
		ini.settings.currentcolor = ini.settings.defaultcolor
		inicfg.save(ini, 'rpcolor')
  end
end

function main()
	wait(0)
	sampRegisterChatCommand("rpcolor", chatColor)
end
