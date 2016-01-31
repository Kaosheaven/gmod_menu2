
local MenuGradient = Material( "../html/img/gradient.png", "nocull smooth" )

local Images = {}

local mat = Material("../backgrounds/gm_construct_m_1280002.jpg","nocull smooth")

local Active = {
		Ratio = mat:GetInt( "$realwidth" ) / mat:GetInt( "$realheight" ),
		Size = 1,
		Angle = 0,
		AngleVel = -( 5 / 30 ),
		SizeVel = ( 0.3 / 30 ),
		Alpha = 255,
		DieTime = 30,
		mat = mat
	}
local Outgoing = nil

local function Think( tbl )

	tbl.Angle = tbl.Angle + ( tbl.AngleVel * FrameTime() )
	tbl.Size = tbl.Size + ( ( tbl.SizeVel / tbl.Size) * FrameTime() )

	if ( tbl.AlphaVel ) then
		tbl.Alpha = tbl.Alpha - tbl.AlphaVel * FrameTime()
	end

	if ( tbl.DieTime > 0 ) then
		tbl.DieTime = tbl.DieTime - FrameTime()

		if ( tbl.DieTime <= 0 ) then
			ChangeBackground()
		end
	end

end

local function Render( tbl )

	surface.SetMaterial( tbl.mat )
	surface.SetDrawColor( 255, 255, 255, tbl.Alpha )

	local w = ScrH() * tbl.Size * tbl.Ratio
	local h = ScrH() * tbl.Size

	local x = ScrW() * 0.5
	local y = ScrH() * 0.5

	surface.DrawTexturedRectRotated( x, y, w, h, tbl.Angle )

end

function DrawBackground()

	if ( !IsInGame() ) then

		if ( Active ) then
			Think( Active )
			Render( Active )
		end

		if ( Outgoing ) then

			Think( Outgoing )
			Render( Outgoing )

			if ( Outgoing.Alpha <= 0 ) then
				Outgoing = nil
			end

		end

	end

	surface.SetMaterial( MenuGradient )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 1024, ScrH() )

end

function ClearBackgroundImages( img )

	Images = {}

end

function AddBackgroundImage( img )

	table.insert( Images, img )

end

local LastGamemode = "none"

function ChangeBackground()

	local img = table.Random( Images )
	
	if ( !img ) then return end

	Outgoing = Active
	if ( Outgoing ) then
		Outgoing.AlphaVel = 255
	end

	local mat = Material( img, "nocull smooth" )
	if ( !mat || mat:IsError() ) then return end

	Active = {
		Ratio = mat:GetInt( "$realwidth" ) / mat:GetInt( "$realheight" ),
		Size = 1,
		Angle = 0,
		AngleVel = -( 5 / 30 ),
		SizeVel = ( 0.3 / 30 ),
		Alpha = 255,
		DieTime = 30,
		mat = mat
	}

	if ( Active.Ratio < ScrW() / ScrH() ) then

		Active.Size = Active.Size + ( ( ScrW() / ScrH() ) - Active.Ratio )

	end

end

----

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
end

function PANEL:ScreenshotScan( folder )
	local bReturn = false

	local Screenshots = file.Find( folder .. "*.*", "GAME" )
	for k, v in RandomPairs( Screenshots ) do
		AddBackgroundImage( folder .. v )
		bReturn = true
	end

	return bReturn
end

function PANEL:Paint()
	DrawBackground()

	if ( self.IsInGame != IsInGame() ) then

		self.IsInGame = IsInGame()

		if ( self.IsInGame ) then
			if ( IsValid( self.InnerPanel ) ) then self.InnerPanel:Remove() end
		end

	end
end


function PANEL:RefreshGamemodes()
	local json = util.TableToJSON( engine.GetGamemodes() )
	self:UpdateBackgroundImages()
end

function PANEL:UpdateBackgroundImages()
	ClearBackgroundImages()

	if ( !self:ScreenshotScan( "gamemodes/" .. engine.ActiveGamemode() .. "/backgrounds/" ) ) then
		self:ScreenshotScan( "backgrounds/" )
	end

	ChangeBackground()
end

vgui.Register( "menu2_background", PANEL, "EditablePanel" )