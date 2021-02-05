script_name('AU')
script_author('Leviathan')
require "lib.moonloader"
local imgui = require 'imgui'
local key = require 'vkeys'
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
action = imgui.ImBool(false)
insurance = imgui.ImBool(false)
window = imgui.ImBool(false)

--------AutoUpdate
update_state = false
local script_vers = 0.0
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/Jleviathan/au/main/update.ini"
local update_path = getWorkingDirectory() .. "/AU/AuUpdate.ini"

local script_url = ""
local script_path = thisScript().path
------------------

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

local menu = 0
local pmenu = 0

--[[
function imgui.OnDrawFrame()
	if window.v then
		 imgui_style()
		 imgui.ShowCursor = true
	imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(640, 400), imgui.Cond.FirstUseEver)
	imgui.Begin('AutoSchool', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
	
	-----меню
	if menu_render then
	imgui.BeginChild("##child1", imgui.ImVec2(200,350),true)
			if imgui.Button(u8'Меню',imgui.ImVec2(170,30)) then 
				menu = 1
				menu_render = false
				pmenu_render = true
				end
			if imgui.Button(u8'Биндер',imgui.ImVec2(170,30)) then
				menu = 2
			end
			if imgui.Button(u8'Настройки',imgui.ImVec2(170,30)) then
				menu = 3
			end
			imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()
			if imgui.Button(u8'О скрипте', imgui.ImVec2(170,30),true) then 
				menu = 5
			end
		imgui.EndChild()
	end
	-----------------
	
	-----подменю
	if pmenu_render then
		if menu == 1 then
			imgui.BeginChild("##child1", imgui.ImVec2(200,350),true)
				if imgui.Button(u8'Собеседование',imgui.ImVec2(170,30)) then pmenu = 1 end
				if imgui.Button(u8'Рук.Составу',imgui.ImVec2(170,30)) then pmenu = 2 end
				if imgui.Button(u8'Лекции',imgui.ImVec2(170,30)) then pmenu = 3 end
				imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()
				if imgui.Button(u8'Назад',imgui.ImVec2(170,30),true) then 
					menu_render = true 
					pmenu_render = false
				end

				if imgui.Button(u8'О скрипте', imgui.ImVec2(170,30),true) then 
					menu = 5
				end
			imgui.EndChild()
	
		end
	end
	-----------------
		imgui.SameLine()
			
		imgui.BeginChild("pmenu", imgui.ImVec2(400,350),true)

				if pmenu == 1 then
						imgui.Columns(2,'Sobes',false)
						imgui.Button(u8'Приветсвие', imgui.ImVec2(180,30))
						imgui.NextColumn()
						if imgui.Button(u8'Принять', imgui.ImVec2(180,30)) then
						end
				
				elseif menu == 5 then
					imgui.Columns(3,'Info',false)
					imgui.NextColumn()
					imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()
					imgui.Image(image, imgui.ImVec2(115,115))
					imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()
					imgui.CenterTextColoredRGB('Версия скрипта - {FF0000}v0.1')
				end
		imgui.EndChild()
		
		imgui.End()
	end
end
]]

function imgui_style()
 imgui.SwitchContext()
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local ImVec2 = imgui.ImVec2

style.WindowPadding = ImVec2(7, 7)
style.WindowRounding = 6.0
style.ChildWindowRounding = 6.0
style.FramePadding = ImVec2(5, 5)
style.FrameRounding = 4.0
style.ItemSpacing = ImVec2(12, 8)
style.ItemInnerSpacing = ImVec2(8, 6)
style.IndentSpacing = 25.0
style.ScrollbarSize = 15.0
style.ScrollbarRounding = 9.0
style.GrabMinSize = 5.0
style.GrabRounding = 3.0
style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
style.ButtonTextAlign = imgui.ImVec2(0.5,0.5)

colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ChildWindowBg] = ImVec4(0.72, 0, 100, 0.20) 
colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.TitleBg] = ImVec4(0.72, 0, 80, 1.00) 
colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
colors[clr.TitleBgActive] = ImVec4(0.72, 0, 100, 1.00) 
colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
colors[clr.Button] = ImVec4(0.72, 0, 100, 0.20)
colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.CloseButton] = ImVec4(0.72, 0, 100, 1.00)
colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function setMarker(type, x, y, z, radius, color)
    deleteCheckpoint(marker)
    removeBlip(checkpoint)
    checkpoint = addBlipForCoord(x, y, z)
    marker = createCheckpoint(type, x, y, z, 1, 1, 1, radius)
    changeBlipColour(checkpoint, color)
    lua_thread.create(function()
    repeat
        wait(0)
        local x1, y1, z1 = getCharCoordinates(PLAYER_PED)
        until getDistanceBetweenCoords3d(x, y, z, x1, y1, z1) < radius or not doesBlipExist(checkpoint)
        deleteCheckpoint(marker)
        removeBlip(checkpoint)
        addOneOffSound(0, 0, 0, 1149)
    end)
end

function main()
		if isSampLoaded() or isSampAvailable() then
			sampAddChatMessage(string.format('{00fff2}AU {ff0000}| {ffffff}Loaded'),0xffffff)
			end
	downloadUrlToFile(update_url, update_path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updateIni = inicfg.load(nil, update_path)
				if tonumber(updateIni.info.vers) > script_vers then
					sampAddChatMessage("{00fff2}AU {ff0000}| Доступно обновление", -1)
					update_state = true
				end
				os.remove(update_path)
			end
		end)
	while true do 
		wait(0)
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
	end
	
	while true do
		wait(0)
		sampRegisterChatCommand('exam',exam)
		res, handle = getCharPlayerIsTargeting(playerHandle)
		if res and wasKeyPressed(key.VK_X) then
			resid, id = sampGetPlayerIdByCharHandle(handle)
			Pid = id
			nick = sampGetPlayerNickname(id)
			window.v = not window.v
		end
		imgui.Process = window.v
	end
end
--[[
function exam()
	--marker = createCheckpoint(type, x, y, z, 1, 1, 1, radius)
	--if
	setMarker(2, -2055.0007, -169.2017, 35.0668, 5, 0xFFFFFFFF)
	--setMarker(2, -2051.6182, -202.7786, 35.0688, 5, 0xFFFFFFFF)
	--setMarker(2, -2052.6123, -199.4037, 35.0694, 5, 0xFFFFFFFF)
	--setMarker(2, -2052.4482, -239.1835, 35.0654, 5, 0xFFFFFFFF)
	
end
]]
function imgui.OnDrawFrame()
	if window.v then
		imgui_style()
		imgui.ShowCursor = true
	local p1, p2 = 250, 340
	imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 1.08, imgui.GetIO().DisplaySize.y / 1.2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(p1, p2), imgui.Cond.FirstUseEver)
	resuld, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	name = sampGetPlayerNickname(id)
	local TitleName
	TitleName = u8'AS | Игрок '..nick..'['..tostring(Pid)..']'
	
	imgui.Begin(TitleName, window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		
		imgui.BeginChild("##child1", imgui.ImVec2(p1-15,p2-40),true)
			imgui.CenterTextColoredRGB('Выберите действие')
			imgui.Separator()

			if imgui.Button(u8'Наземный транспорт',imgui.ImVec2(p1-30,25)) then
				but = 1
				lua_thread.create(function()
					sampAddChatMessage(string.format("Здравствуйте, я сотрудник Лицензионного Центра "..string.gsub(name,"_"," ").." и я буду проводить у Вас экзамен."),0xffffff)
					wait(2000)
					sampAddChatMessage(string.format("Предъявите пожалуйста Вашу ID-Карту."),0xffffff)
					wait(2000)
					sampAddChatMessage(string.format("/n Введите команду: /pass ["..id.."]"),0xffffff)
					wait(100)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Критерии: {ff0000}18+ лет."), 0xffffff)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Для продолжения нажмите - {ff0000}Далее{ffffff}. Если не допущен - {ff0000}Отказать{ff0000}."), 0xffffff)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Чтобы прервать - {ff0000}Отмена{ffffff}."), 0xffffff)
					action.v = true
				end)
			end
		--[[	if imgui.Button(u8'Воздушный транспорт',imgui.ImVec2(p1-15,25)) then exam = 2 end
			if imgui.Button(u8'Мото транспорт',imgui.ImVec2(p1-15,25)) then exam = 3 end
			if imgui.Button(u8'Грузовой экзамен',imgui.ImVec2(p1-15,25)) then exam = 4 end
		  ]]
			imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()
			
			imgui.NewLine()
			imgui.Separator()
			if imgui.Button(u8'Лицензия на оружие',imgui.ImVec2(p1-30,25)) then
				lua_thread.create(function()
					but = 5
					sampAddChatMessage(string.format("Предъявите пожалуйста Вашу ID-Карту и Мед.карту."),0xffffff)
					wait(2000)
					sampAddChatMessage(string.format("/n Введите команду: /pass ["..id.."], мед. карта: /med ["..id.."]"),0xffffff)
					wait(100)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Критерии: {ff0000}18+ лет | Пройденый Мед. осмотр | 2 уровень"), 0xffffff)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Для продолжения нажмите - {ff0000}Далее{ffffff}. Если не допущен - {ff0000}Отказать{ff0000}."), 0xffffff)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Чтобы прервать - {ff0000}Отмена{ffffff}."), 0xffffff)
					action.v = true
				end)
			end
			if imgui.Button(u8'Лицензия на водный транспорт',imgui.ImVec2(p1-30,25)) then 
				lua_thread.create(function()
					but = 6		
					sampAddChatMessage(string.format("Предъявите пожалуйста Вашу ID-Карту и Мед.карту."),0xffffff)
					wait(2000)
					sampAddChatMessage(string.format("/n Введите команду: /pass ["..id.."], мед. карта: /med ["..id.."]"),0xffffff)
					wait(100)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Критерии: {ff0000}18+ лет | Пройденый Мед. осмотр | 2 уровень"), 0xffffff)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Для продолжения нажмите - {ff0000}Далее{ffffff}. Если не допущен - {ff0000}Отказать{ff0000}."), 0xffffff)
					sampAddChatMessage(string.format("{00fff2}AU {ff0000}| {ffffff}Чтобы прервать - {ff0000}Отмена{ffffff}."), 0xffffff)
					action.v = true
				end)
			end
		
			if imgui.Button(u8'Страховка',imgui.ImVec2(p1-30,25)) then 
				lua_thread.create(function()
					sampAddChatMessage(string.format("На какой срок вы хотите застраховать свой автомобиль: 10, 30 или 60 дней?"),0xffffff)
					but = 7
					insurance.v = true
				end)
			end
		imgui.EndChild()
		imgui.End()
	end

if insurance.v then 
		imgui_style()
	local p3, p4 = 350, 98
	imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 1.05), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(p3,p4),imgui.Cond.FirstUseEver)
	imgui.Begin('LF',action,imgui.WindowFlags.NoResize+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoScrollbar)

	if but == 7 then
			imgui.BeginChild('#action7',imgui.ImVec2(p3-20,p4-10),false)
				imgui.Columns(3,'but',false)
					if imgui.Button(u8'10',imgui.ImVec2(p3 - 250,35)) then
							ins = 1
							but = 0
							pbut = 7
							insurance.v = false		
						lua_thread.create(function()
							sampAddChatMessage(string.format('Хорошо, давайте вашу вашу ID-Карту, мед. карту и паспорт транспортного средства.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/n Показать ID-карту - /pass '..id..', мед.карту - /med '..id..', ПТС - /pts '..id..''),0xffffff)						
							action.v = true		
						end)
					end
					imgui.NextColumn()
					if imgui.Button(u8'30',imgui.ImVec2(p3 - 250,35)) then
							ins = 2
							but = 0
							pbut = 7
							insurance.v = false
						lua_thread.create(function()
							sampAddChatMessage(string.format('Хорошо, давайте вашу вашу ID-Карту, мед. карту и паспорт транспортного средства.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/n Показать ID-карту- /pass '..id..', мед.карту - /med '..id..', ПТС - /pts '..id..''),0xffffff)
							action.v = true
						end)
					end
					imgui.NextColumn()
					if imgui.Button(u8'60',imgui.ImVec2(p3 - 250,35)) then
							ins = 3
							but = 0
							pbut = 7
							insurance.v = false
						lua_thread.create(function()
							sampAddChatMessage(string.format('Хорошо, давайте вашу вашу ID-Карту, мед. карту и паспорт транспортного средства.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/n Показать ID-карту- /pass '..id..', мед.карту - /med '..id..', ПТС - /pts '..id..''),0xffffff)
							action.v = true
						end)
					end
				imgui.NextColumn()
				imgui.NextColumn()
				if imgui.Button(u8'Отмена',imgui.ImVec2(p3 - 250,35)) then insurance.v = false end
			imgui.EndChild()
	end
	imgui.End()
end
	
if action.v then
		imgui_style()
		local p1, p2 = 350, 55
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 1.03), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(p1,p2),imgui.Cond.FirstUseEver)
	imgui.Begin('',action,imgui.WindowFlags.NoResize+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoScrollbar)
------------------------
	if but == 1 then
			imgui.BeginChild('#action1',imgui.ImVec2(p1-20,p2-12),false)
				imgui.Columns(3,'but',false)
					if imgui.Button(u8'Далее',imgui.ImVec2(p1 - 250,p2 - 20)) then
						lua_thread.create(function()
							sampAddChatMessage(string.format('/me достал ручку и талон из кармана штанов'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me вписал имя и фамилию экзаменуемого, после чего передал талон'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/f Начал проводить экзамен на автомобиль у '..string.gsub(name,"_"," ")),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('Пройдёмте за мной на парковку, для сдачи практической части экзамена.'),0xffffff)
							wait(100)
							sampAddChatMessage(string.format('{00fff2}AU {ff0000}| {ffffff}Для продолжения нажмите - {ff0000}Далее{ffffff}'),0xffffff)	
							sampAddChatMessage(string.format('{00fff2}AU {ff0000}| {ffffff}Чтобы прервать - {ff0000}Отмена{ffffff}.'),0xffffff)
						pbut = 1
						but = 0
					end)	
				end
		
				imgui.NextColumn()
					if imgui.Button(u8'Отказать',imgui.ImVec2(p1 - 250,p2 - 20)) then 
						sampAddChatMessage(string.format('У Вас проблемы с документами, я не могу принять у Вас экзамен'),0xffffff)
					end
				imgui.NextColumn()
					if imgui.Button(u8'Отмена',imgui.ImVec2(p1 - 250,p2 - 20)) then action.v = false end
			
			imgui.EndChild()
	end
	
	if but == 5 then
			imgui.BeginChild('#action1',imgui.ImVec2(p1-20,p2-10),false)
				imgui.Columns(3,'but',false)
					if imgui.Button(u8'Далее',imgui.ImVec2(p1 - 250,p2 - 20)) then
						lua_thread.create(function()
							sampAddChatMessage(string.format('/do В левой руке находится дипломат с лицензиями.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me открыл кейс и вытащила из него нужную лицензию'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me взял в руку ручку, после чего заполнил лицензию'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/todo Вот Ваша лицензия, держите.*передав лицензию клиенту'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/selllic '..Pid..' 2'),0xffffff)
						but = 0
						action.v = false
					end)	
				end
		
				imgui.NextColumn()
					if imgui.Button(u8'Отказать',imgui.ImVec2(p1 - 250,p2 - 20)) then 
						sampAddChatMessage(string.format('У Вас проблемы с документами, я не могу продать Вам лицензию.'),0xffffff)
						action.v = false
					end
				imgui.NextColumn()
					if imgui.Button(u8'Отмена',imgui.ImVec2(p1 - 250,p2 - 20)) then action.v = false end
			
			imgui.EndChild()
	end
	
	
	if but == 6 then
			imgui.BeginChild('#action2',imgui.ImVec2(p1-20,p2-12),false)
				imgui.Columns(3,'but',false)
					if imgui.Button(u8'Далее',imgui.ImVec2(p1 - 250,p2 - 20)) then
						lua_thread.create(function()
							sampAddChatMessage(string.format('/do В левой руке находится дипломат с лицензиями.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me открыл кейс и вытащила из него нужную лицензию'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me взял в руку ручку, после чего заполнил лицензию'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/todo Вот Ваша лицензия, держите.*передав лицензию клиенту'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/selllic '..Pid..' 1'),0xffffff)
						but = 0
						action.v = false
					end)	
				end
		
				imgui.NextColumn()

				imgui.NextColumn()
					if imgui.Button(u8'Отмена',imgui.ImVec2(p1 - 250,p2 - 20)) then action.v = false end
			
			imgui.EndChild()
	end

------------------------------
	if pbut == 1 then 
			imgui.BeginChild('#action5',imgui.ImVec2(p1-20,p2-12),false)
				imgui.Columns(2,'but2',false)
					if imgui.Button(u8'Далее',imgui.ImVec2(p1 - 200,p2 - 20)) then
					
						lua_thread.create(function()
							sampAddChatMessage(string.format('Присаживайтесь на место водителя и ожидайте моих дальнейших указаний'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('Для начала пристегните ремень безопастности.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/n /me пристегнул ремень безопастности'),0xffffff)
							wait(3000)
							sampAddChatMessage(string.format('/me пристегнул ремень безопастности'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('Заводите двигатель, включайте фары и двигайтесь к метке "Старт" в центре площадки.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/n Завести двигатель можно нажав на клавишу [Ctrl], включить фары [Alt].'),0xffffff)
							pbut = 0
							action.v = false
						end)
					end
				imgui.NextColumn()
				if imgui.Button(u8'Отмена',imgui.ImVec2(p1 - 200,p2 - 20)) then action.v = false end
			imgui.EndChild()
	end

	if pbut == 7 then
			imgui.BeginChild('#action77',imgui.ImVec2(p1-20,p2-12),false)
				imgui.Columns(3,'pbut7',false)
						
					if imgui.Button(u8'Продолжить',imgui.ImVec2(p1 - 250,p2 - 20)) then
						but = 0
						pbut = 0
						action.v = false
						lua_thread.create(function()
							sampAddChatMessage(string.format('/me открыл кейс, после чего достал документы ,затем начал их заполнять'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/do Написал: '..nick..' | Страховка | '..os.date('%x')..' '..os.date('%H:%M')..'.'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me ниже поставил печать Autoschool-insurance, дату с подписью'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me после продажи страховки аккуратно сложил документы, после чего закрыл кейс'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('/me передал страховку клиенту'),0xffffff)
							wait(2000)
							sampAddChatMessage(string.format('Вот ваша страховка, держите.'),0xffffff)
							wait(1000)
							if ins == 1 then
								sampAddChatMessage(string.format('/insurance '..Pid..' 1'),0xffffff)
							elseif ins == 2 then
								sampAddChatMessage(string.format('/insurance '..Pid..' 2'),0xffffff)
							elseif ins  == 3 then
								sampAddChatMessage(string.format('/insurance '..Pid..' 3'),0xffffff)
							end
							
						end)
					end
					imgui.NextColumn()
					if imgui.Button(u8'Отказать',imgui.ImVec2(p1 - 250,p2 - 20)) then 
						sampAddChatMessage(string.format('У Вас проблемы с документами, я не могу продать Вам лицензию.'),0xffffff)
						action.v = false
					end
					imgui.NextColumn()
					if imgui.Button(u8'Отмена',imgui.ImVec2(p1 - 250,p2 - 20)) then action.v = false end
			imgui.EndChild()
	end
	imgui.End()
end



-----------------
end



--[[
далее

Соблюдайте указания стрелок на асфальте и объезжайте конусы змейкой.
Теперь поставьте машину в обозначеную область.
Тееперь езжайте по стрелкам вокруг конусов в сторону эстакады.
Подъезжайте к эстакаде и остановитесь перед линией.
Теперь осторожно проезжайте по мосту, затем возле надписи стоп остановитесь.
Отлично, теперь поставьте автомобиль на парковку!

После того как припарковались, нажмите
Сдал | не сдал | Отмена

]]
