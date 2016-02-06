local R=function(a,b,c,d,e) return function() return RunConsoleCommand(a,b,c,d,e) end end
local M=function(x) return function() return RunGameUICommand(x) end end
local C=function(x) return function() return JoinServer(x) end end
local NOT=function(f) return function(...) return not f(...) end end

local DividerR = CreateClientConVar("menu2_color_r",0):GetInt()
local DividerG = CreateClientConVar("menu2_color_g",150):GetInt()
local DividerB = CreateClientConVar("menu2_color_b",130):GetInt()

surface.CreateFont("menu2_button",{
	font = "Roboto Medium",
	size = 24,
})

surface.CreateFont("menu2_text",{
	font = "Roboto Medium",
	size = 16,
})

local function iconbrowser()
	local frame = vgui.Create("DFrame")
	frame:SetSize(400,300)
	frame:SetPos(5,ScrH()-305)
	frame:SetTitle("Icon Browser")
	frame:MakePopup()
	local path_pnl = vgui.Create("EditablePanel",frame)
	path_pnl:Dock(TOP)
	path_pnl:DockMargin(4,0,4,4)
	path_pnl:SetTall(24)
	local path = vgui.Create("DTextEntry",path_pnl)
	path:SetText("")
	path:Dock(FILL)
	path:SetEditable(false)
	local copy = vgui.Create("DButton",path_pnl)
	copy:Dock(RIGHT)
	copy:SetWide(24)
	copy:SetImage("icon16/page_copy.png")
	copy:SetText("")
	function copy:DoClick()
		SetClipboardText(path:GetText())
	end
	local browser = vgui.Create("DIconBrowser",frame)
	browser:Dock(FILL)
	browser:DockMargin(4,0,4,4)
	function browser:OnChange()
		path:SetText(self:GetSelectedIcon())
	end
end

concommand.Add("iconbrowser",iconbrowser)

local mainmenu = {
	{""},
	{"resume_game",					gui.HideGameUI,                      "icon16/joystick.png"				,show=IsInGame},
	{"disconnect",					M"disconnect",                      "icon16/disconnect.png"				,show=IsInGame},
	{"reconnect",					R"retry",                      		"icon16/connect.png"				,show=WasInGame},
	{"server_players",				M"openplayerlistdialog",        	"icon16/group_delete.png"			,show=IsInGame},
	
	{"",show=WasInGame},
	{"new_game",					M"opencreatemultiplayergamedialog", "icon16/server.png"					},
	{"legacy_browser",				M"openserverbrowser",               "icon16/world.png"					},


	{""},
	{"Join Metastruct #1",			C"g1.metastruct.org",       "icon16/server.png"					},
	{"Join Metastruct #2",			C"g2.metastruct.org",       "icon16/server.png"					},
	{"Join FlexBox",				C"xenora.net:27018",        "icon16/server.png"					},
	{"Join Intertech",				C"31.186.251.45",        	"icon16/server.png"					},

	{""},
	{"Change Background",			ChangeBackground,			"icon16/picture.png"				},
	{"Reload Menu",					 function() include'includes/menu.lua' hook.Call("MenuStart") end,		"icon16/arrow_refresh.png"	},
	
	{""},
	{"options",						M"openoptionsdialog",               "icon16/wrench.png"					},
	{"GameUI_Console",				R"showconsole",                   	"icon16/application_xp_terminal.png"},
	
	{""},
	{"GameUI_Quit",					M"quitnoconfirm",                   "icon16/door.png"					},
	{""},
}
-- addons
-- games
-- language
-- settings
-- lua cache?
-- workshop search
-- con filter out
-- console open
-- devmode quicktoggle
-- favorites and their status on main menu?
-- browser? / overlay?
-- client.vdf browser/editor
-- 

local isours
if pnlMainMenu and pnlMainMenu:IsValid() then pnlMainMenu:Remove() end

local bg = vgui.Create("menu2_background")
bg:ScreenshotScan( "backgrounds/" )

_G.pnlMainMenu = bg
local menulist_wrapper = vgui.Create('DPanelList',bg,'menulist_wrapper')
menulist_wrapper:EnableVerticalScrollbar(true)
menulist_wrapper:SetWide(350)
menulist_wrapper:Dock(LEFT)
menulist_wrapper:DockMargin(32,32,32,32)

local div_hack = vgui.Create'EditablePanel'
div_hack:SetTall(52)
div_hack:SetZPos(-20000)
menulist_wrapper:AddItem(div_hack)

local lastscroll = menulist_wrapper.VBar:GetScroll()



local addonslist
function CreateAddons()
	
	if addonslist and addonslist:IsValid() then addonslist:Remove() addonslist=nil end
	
	addonslist = vgui.Create('DForm',menulist_wrapper,'addonslist')
	addonslist:Dock(TOP)
	addonslist:SetName"#manage_addons"
	addonslist:SetExpanded(false)
	
	addonslist:SetCookieName"addonslist"
	addonslist:LoadCookies()
	
	menulist_wrapper:AddItem(addonslist)
	menulist_wrapper:InvalidateLayout(true)
	addonslist:InvalidateLayout(true)
	addonslist.Header:SetIcon 'icon16/plugin.png'
	addonslist.Header:SetFont("menu2_text")
	function addonslist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,Color(DividerR,DividerG,DividerB))
	end
	

	local btn = vgui.Create("DButton",addonslist,'addonslist_button')
		addonslist:AddItem(btn)
		btn:SetText("#addons.enableall")
		btn:SetIcon 'icon16/add.png'
		btn:SetFont("menu2_text")
		
		function btn.DoClick(btn)
			for k,v in next,engine.GetAddons() do
				steamworks.SetShouldMountAddon(v.wsid or v.file,true)
			end
			isours = true
			steamworks.ApplyAddons()
			isours = true
			
			CreateMenu()

		end
	local btn = vgui.Create("DButton",addonslist,'addonslist_button')
		addonslist:AddItem(btn)
		btn:SetText("#addons.disableall")
		btn:SetIcon 'icon16/delete.png'
		btn:SetFont("menu2_text")
		
		function btn.DoClick(btn)
			for k,v in next,engine.GetAddons() do
				steamworks.SetShouldMountAddon(v.wsid or v.file,false)
			end
			isours = true
			steamworks.ApplyAddons()
			isours = true
			CreateMenu()
		end
	local btn = vgui.Create("DButton",addonslist,'addonslist_button')
		addonslist:AddItem(btn)
		btn:SetText("#addons.uninstallall")
		btn:SetIcon 'icon16/stop.png'
		btn:SetFont("menu2_text")
		function btn.DoClick(btn)
			for k,v in next,engine.GetAddons() do
				if v.wsid then
					print("Unsubscribe",v.wsid)
					steamworks.Unsubscribe(v.wsid)
				end
			end
			isours = true steamworks.ApplyAddons() isours = true
			CreateMenu()
		end

	local function AddButton(data,title,mounted,downloaded,wsid,filepath)
		
		local btn = vgui.Create("DCheckBoxLabel",addonslist,'addonslist_button')
			addonslist:AddItem(btn)
			btn:SetText(title or filepath)
			btn:SetChecked(mounted)
			btn:SetBright(true)
			btn:SetDisabled(not downloaded)
			btn.Label:SetFont("menu2_text")
			btn:SizeToContents()
			function btn:OnChange(val)
				print("mount",filepath,val)
				local old = steamworks.ShouldMountAddon(wsid)
				steamworks.SetShouldMountAddon(wsid,val)
				isours = true steamworks.ApplyAddons() isours = true
				local new = steamworks.ShouldMountAddon(wsid)
				btn:SetChecked(new)
				if old==new then
					print("Warning: ","could not toggle",filepath)
				end
			end
			btn.Label.DoRightClick=function()
				local m =DermaMenu()
					m:AddOption("#addon.unsubscribe",function()
						print("Unsubscribe",wsid)
						steamworks.Unsubscribe(wsid)
					end)
					m:AddOption("#copy",function()
						SetClipboardText('http://steamcommunity.com/sharedfiles/filedetails/?id='..wsid)
					end)
				m:Open()
			end
	
		btn:InvalidateLayout(true)
		--btn:Dock(TOP)
	end

	local t=engine.GetAddons()
	table.sort(t,function(a,b)
		if a.mounted==b.mounted then
			if a.wsid and b.wsid then
				return a.wsid<b.wsid
			elseif a.title and b.title then
				return a.title<b.title
			else
				return a.file<b.file
			end
		else
			return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
		end
	end)
	for _,data in next,t do
		AddButton(data,data.title,data.mounted,data.downloaded,data.wsid,data.file)
	end
	
	
	
	menulist_wrapper.VBar:SetScroll(lastscroll)
	
end



local settingslist
function CreateExtraSettings()
	
	if settingslist and settingslist:IsValid() then settingslist:Remove() settingslist=nil end
	
	settingslist = vgui.Create('DForm',menulist_wrapper,'settingslist')
	settingslist:Dock(TOP)
	settingslist:SetName"Extra Settings"
	settingslist:SetExpanded(false)
	settingslist.Header:SetIcon 'icon16/cog.png'
	settingslist.Header:SetFont("menu2_text")
	settingslist:SetCookieName"settingslist"
	settingslist:LoadCookies()

	function settingslist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,Color(DividerR,DividerG,DividerB))
	end
	
	menulist_wrapper:AddItem(settingslist)
	menulist_wrapper:InvalidateLayout(true)
	settingslist:InvalidateLayout(true)
	
	local function AddCheck(txt,cvar)
		
		local 
			c = vgui.Create( 'DCheckBoxLabel',settingslist,'settingslist_check')
				settingslist:AddItem(c)
			c:SetText( txt )
			c:SetConVar(cvar)
			c:SetBright(true)
			c.Label:SetFont("menu2_text")
			c:SizeToContents()
			c:InvalidateLayout(true)
		return c
	end

	local x = vgui.Create( 'DLabel',settingslist)
	x:SetText"Loading Screen"
	x:SetFont("menu2_text")
	settingslist:AddItem(x)
	AddCheck( "Enable","lua_loading_screen")
	AddCheck( "Transparency","lua_loading_screen_transp")
	AddCheck( "Try hiding","lua_loading_screen_hide")
	local x = vgui.Create( 'DLabel',settingslist)
	x:SetText"Download / Upload"
	x:SetFont("menu2_text")
	settingslist:AddItem(x)
	AddCheck( "Allow DL","cl_allowdownload")
	AddCheck( "Allow UL","cl_allowupload")
	AddCheck( "FastDL debug","download_debug")
	local x = vgui.Create( 'DLabel',settingslist)
	x:SetText" "
	x:SetFont("menu2_text")
	settingslist:AddItem(x)
	
end




local gameslist
function CreateGames()
	
	if gameslist and gameslist:IsValid() then gameslist:Remove() gameslist=nil end
	
	gameslist = vgui.Create('DForm',menulist_wrapper,'gameslist')
	gameslist:Dock(TOP)
	gameslist:SetName"#mounted_games"
	gameslist:SetExpanded(false)
	gameslist.Header:SetIcon 'icon16/joystick.png'
	gameslist.Header:SetFont("menu2_text")
	gameslist:SetCookieName"gameslist"
	gameslist:LoadCookies()

	function gameslist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,Color(DividerR,DividerG,DividerB))
	end
	
	menulist_wrapper:AddItem(gameslist)
	menulist_wrapper:InvalidateLayout(true)
	gameslist:InvalidateLayout(true)
	
	local function AddButton(data,title,mounted,owned,installed,depot)
		
		local btn = vgui.Create("DCheckBoxLabel",gameslist,'gameslist_button')
			gameslist:AddItem(btn)
			btn:SetText(title)
			btn:SetChecked(mounted)
			btn:SetBright(true)
			btn:SetDisabled(not owned or not installed)
			btn.Label:SetFont("menu2_text")
			btn:SizeToContents()
			function btn:OnChange(val)
				engine.SetMounted(depot,val)
				btn:SetChecked(IsMounted(depot))
			end
	
		btn:InvalidateLayout(true)
		--btn:Dock(TOP)
	end

	local t=engine.GetGames()
	table.sort(t,function(a,b)
		if a.mounted==b.mounted then
			if a.mounted then
				return a.depot<b.depot
			else
				return ((a.installed and a.owned) and 0 or 1)<((b.installed and b.owned) and 0 or 1)
			end
		else
			return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
		end
	end)
	for _,data in next,t do
		AddButton(data,data.title,data.mounted,data.owned,data.installed,data.depot)
	end
	
	CreateAddons()
	
end



local menulist
local creating
local function _CreateMenu()
	creating = false
	
	lastscroll = menulist_wrapper.VBar:GetScroll()
	
	if menulist and menulist:IsValid() then menulist:Remove() menulist=nil end
	
	menulist = vgui.Create('DForm',menulist_wrapper,'menulist')
	menulist:Dock(TOP)
	menulist:SetName""
	menulist.Header:SetIcon 'icon16/house.png'
	menulist:SetCookieName"menulist"
	menulist:LoadCookies()
	
	function menulist:Paint(w,h)
		draw.RoundedBox(4,0,0,w,20,Color(DividerR,DividerG,DividerB))
	end
	
	menulist_wrapper:AddItem(menulist)
	menulist_wrapper:InvalidateLayout(true)
	menulist:InvalidateLayout(true)
	
	local function AddButton(data,text,menucmd,icon)
		
		if data.show and not data:show() then return end
		
		if text=="" and not menucmd then
			local div = vgui.Create'EditablePanel'
			div:SetTall(1)
			menulist:AddItem(div)
			return
		end
		
		local btn = vgui.Create("DButton",menulist,'menulist_button')
			menulist:AddItem(btn)
			btn:SetText("#"..text)
			btn:SetFont"menu2_button"
			btn:SizeToContents()
		btn.DoClick=function()
			menucmd()
			btn:SetSelected(false)
		end
		if icon and #icon>0 then
			btn:SetImage(icon)
		end
		btn:InvalidateLayout(true)
		
		btn:SetTextInset( 16+ 16, 0 )
		btn:SetContentAlignment(4)
		
		local tall = btn:GetTall()+4
		tall=tall<32 and 32 or tall
		btn:SetTall(tall)
		--btn:Dock(TOP)
	end

	for _,data in next,mainmenu do
		AddButton(data,data[1],data[2],data[3])
	end
	
	CreateExtraSettings()
	CreateGames()
	
	menulist:InvalidateLayout(true)
	
end

function CreateMenu()
	if creating then return end
	creating = true
	timer.Simple(0.2,function()
		_CreateMenu()
	end)
end

--CreateMenu()

hook.Add( "GameContentsChanged", "CreateMenu", function(mount,addon)
	if mount then return end
	
	-- EEK
	if not mount and not addon then return end
	
	if isours then isours = false return end

	CreateMenu()
	
end )

hook.Add( "InGame", "CreateMenu", function(is)
	CreateMenu()
end )

hook.Add( "ConsoleVisible", "CreateMenu", function(is)
	
	if IsDeveloper() then 
		CreateMenu()
	end
	
end )

hook.Add( "MenuStart", "CreateMenu", function(status)
	CreateMenu()
end )

hook.Add( "LoadingStatus", "CreateMenu", function(status)
	--CreateMenu()
end )