if SERVER then
	resource.AddFile( "resource/fonts/Lato-Light.ttf" )
	return 
end

local config = {}

config.enableTimer = true
config.hudScale = 1.3
config.enableHunger = true

surface.CreateFont( "maxouuuuu_font16",
{
	font = "Lato Light", 
	size = 16 * config.hudScale,
	weight = 250,
	antialias = true,
	strikeout = true,
	additive = true,
} )

surface.CreateFont( "maxouuuuu_font18",
{
	font = "Lato Light", 
	size = 18 * config.hudScale,
	weight = 250,
	antialias = true,
	strikeout = true,
	additive = true,
} )

surface.CreateFont( "maxouuuuu_font24",
{
	font = "Lato Light", 
	size = 24 * config.hudScale,
	weight = 250,
	antialias = true,
	strikeout = true,
	additive = true,
} )

surface.CreateFont( "maxouuuuu_font32",
{
	font = "Lato Light", 
	size = 32 * config.hudScale,
	weight = 500,
	antialias = true,
	strikeout = true,
	additive = true,
} )

surface.CreateFont( "maxouuuuu_font48",
{
	font = "Lato Light", 
	size = 48 * config.hudScale,
	weight = 250,
	antialias = true,
	strikeout = true,
	additive = true,
} )

local blur = Material( "pp/blurscreen" )
local function drawBlur( x, y, w, h, layers, density, alpha )
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, layers do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		render.SetScissorRect( x, y, x + w, y + h, true )
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		render.SetScissorRect( 0, 0, 0, 0, false )
	end
end

local function drawLine( startPos, endPos, color )
	surface.SetDrawColor( color )
	surface.DrawLine( startPos[1], startPos[2], endPos[1], endPos[2] )
end

local function drawRectOutline( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( x, y, w, h )
end

local function formatCurrency( number )
	local output = number
	if number < 1000000 then
		output = string.gsub( number, "^(-?%d+)(%d%d%d)", "%1,%2" ) 
	else
		output = string.gsub( number, "^(-?%d+)(%d%d%d)(%d%d%d)", "%1,%2,%3" )
	end
	output = "€" .. output

	return output
end

local postFormatText = {}
local lastDigitNum = 0
local function formatText( text, size )
	postFormatText = {}
	lastDigitNum = 0

	surface.SetFont( "maxouuuuu_font16" )
	for i = 0, string.len( text ) do
		local w, h = surface.GetTextSize( string.sub( text, lastDigitNum, i ) )
		if w > size then
			postFormatText[ #postFormatText + 1 ] = string.sub( text, lastDigitNum, i )
			lastDigitNum = i + 1
		end
	end
	return postFormatText
end

local backgroundColor = Color( 0, 0, 0, 150 )
local currentMoney = 0
local currentHealth = 0
local currentArmor = 100
local agenda = ""
hook.Add( "HUDPaint", "maxouuuuu", function()
	if !LocalPlayer():Alive() then return end
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	LocalPlayer().DarkRPVars.money = LocalPlayer().DarkRPVars.money or 0
	LocalPlayer().DarkRPVars.salary = LocalPlayer().DarkRPVars.salary or 0

	//Player data 76561198167999933
	drawBlur( 5 * config.hudScale, ScrH() - 85 * config.hudScale, 202 * config.hudScale, 80 * config.hudScale, 3, 6, 255 )
	draw.RoundedBox( 0, 5 * config.hudScale, ScrH() - 85 * config.hudScale, 202 * config.hudScale, 80 * config.hudScale, backgroundColor )
	drawRectOutline( 5 * config.hudScale, ScrH() - 85 * config.hudScale, 202 * config.hudScale, 80 * config.hudScale, Color( 0, 0, 0, 75 ) )
	draw.RoundedBox( 0, 10 * config.hudScale, ScrH() - 80 * config.hudScale, 60 * config.hudScale, 70 * config.hudScale, Color( 0, 0, 0, 125 ) )
	drawRectOutline( 10 * config.hudScale, ScrH() - 80 * config.hudScale, 60 * config.hudScale, 70 * config.hudScale, Color( 0, 0, 0, 75 ) )
	//Bars
	draw.RoundedBox( 0, 72 * config.hudScale, ScrH() - 80 * config.hudScale, 130 * config.hudScale, 15 * config.hudScale, Color( 0, 0, 0, 125 ) )
	drawRectOutline( 72 * config.hudScale, ScrH() - 80 * config.hudScale, 130 * config.hudScale, 15 * config.hudScale, Color( 0, 0, 0, 75 ) )
	draw.RoundedBox( 0, 72 * config.hudScale, ScrH() - 64 * config.hudScale, 130 * config.hudScale, 15 * config.hudScale, Color( 0, 0, 0, 125 ) )
	drawRectOutline( 72 * config.hudScale, ScrH() - 64 * config.hudScale, 130 * config.hudScale, 15 * config.hudScale, Color( 0, 0, 0, 75 ) )
	//Filling of bars
	draw.RoundedBox( 0, 74 * config.hudScale, ScrH() - 78 * config.hudScale, math.Clamp( 126 * ( currentHealth / 100 ), 0, 126 ) * config.hudScale, 11 * config.hudScale, Color( 252, 96, 66, 255 ) )
	draw.RoundedBox( 0, 74 * config.hudScale, ScrH() - 62 * config.hudScale, math.Clamp( 126 * ( currentArmor / 100 ), 0, 126 ) * config.hudScale, 11 * config.hudScale, Color( 44, 130, 201, 255 ) )
	draw.SimpleText( LocalPlayer():Health(), "maxouuuuu_font16", 75 * config.hudScale, ScrH() - 65 * config.hudScale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( LocalPlayer():Armor(), "maxouuuuu_font16", 75 * config.hudScale, ScrH() - 49 * config.hudScale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	//Hunger
	if config.enableHunger then
		draw.RoundedBox( 0, 72 * config.hudScale, ScrH() - 67 * config.hudScale, math.Clamp( 130 * ( math.Round( LocalPlayer().DarkRPVars.Energy or 0 ) / 100 ), 0, 130 ) * config.hudScale, 2 * config.hudScale, Color( 44, 201, 44, 255 ) )
	end
	//Money
	if LocalPlayer().DarkRPVars then
		draw.RoundedBox( 0, 72 * config.hudScale, ScrH() - 48 * config.hudScale, 130 * config.hudScale, 38 * config.hudScale, Color( 0, 0, 0, 150 ) )
		draw.SimpleText( LocalPlayer().DarkRPVars.rpname or "", "maxouuuuu_font18", 74 * config.hudScale, ScrH() - 30 * config.hudScale, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( formatCurrency( math.Round( currentMoney ) ) .. " (" .. LocalPlayer().DarkRPVars.salary .. ")", "maxouuuuu_font18", 73 * config.hudScale, ScrH() - 14 * config.hudScale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		//Agenda
		if LocalPlayer():getAgendaTable() then
			agenda = LocalPlayer().DarkRPVars.agenda
			drawBlur( 5 * config.hudScale, 5 * config.hudScale, 300 * config.hudScale, 120 * config.hudScale, 3, 6, 255 )
			draw.RoundedBox( 0 * config.hudScale, 5 * config.hudScale, 5 * config.hudScale, 300 * config.hudScale, 120 * config.hudScale, backgroundColor )
			drawRectOutline( 5 * config.hudScale, 5 * config.hudScale, 300 * config.hudScale, 120 * config.hudScale, Color( 0, 0, 0, 75 ) )
			draw.RoundedBox( 0 * config.hudScale, 7 * config.hudScale, 7 * config.hudScale, 296 * config.hudScale, 20 * config.hudScale, Color( 0, 0, 0, 125 ) )
			drawRectOutline( 7 * config.hudScale, 7 * config.hudScale, 296 * config.hudScale, 20 * config.hudScale, Color( 0, 0, 0, 75 ) )
			draw.SimpleText( "AGENDA", "maxouuuuu_font18", 153 * config.hudScale, 25 * config.hudScale, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			
			//Format agenda
			surface.SetFont( "maxouuuuu_font16" )
			local w, h = surface.GetTextSize( agenda or "agenda" )
			if w > 280 then
				for i, text in pairs( formatText( agenda, 280 ) ) do
					draw.SimpleText( text or "", "maxouuuuu_font16", 10 * config.hudScale, 45 + ( ( i - 1 ) * ( 15 ) ) * config.hudScale, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
				end
			else
				draw.SimpleText( agenda or "", "maxouuuuu_font16", 10 * config.hudScale, 45 * config.hudScale, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
			end
		end
	end
end )

hook.Add( "InitPostEntity", "maxouuuuu_portrait", function()
	local portrait = vgui.Create( "DModelPanel" )
	portrait:SetPos( 10 * config.hudScale, ScrH() - 80 * config.hudScale )
	portrait:SetSize( 60 * config.hudScale, 70 * config.hudScale )
	portrait:SetModel( LocalPlayer():GetModel() )
	portrait.Think = function()
		if not LocalPlayer():Alive() then
			portrait:SetSize( 0, 0 )
		else
			portrait:SetSize( 60 * config.hudScale, 70 * config.hudScale )
		end
		portrait:SetModel( LocalPlayer():GetModel() )
	end
	portrait.LayoutEntity = function()
		return false
	end
	portrait:SetFOV( 40 )
	portrait:SetCamPos( Vector( 25, -15, 62 ) )
	portrait:SetLookAt( Vector( 0, 0, 62 ) )
	portrait.Entity:SetEyeTarget( Vector( 200, 200, 100 ) )
end )

hook.Add( "Initialize", "maxouuuuu_smoother", function()
	hook.Add( "Think", "maxouuuuu_smoother", function()
		LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
		LocalPlayer().DarkRPVars.money = LocalPlayer().DarkRPVars.money or 0
		if LocalPlayer():Health() != currentHealth then
			currentHealth = Lerp( 0.025, currentHealth, LocalPlayer():Health() )
		end
		if LocalPlayer():Armor() != currentArmor then
			currentArmor = Lerp( 0.025, currentArmor, LocalPlayer():Armor() )
		end
		if LocalPlayer().DarkRPVars.money != currentMoney then
			currentMoney = Lerp( 0.05, currentMoney, LocalPlayer().DarkRPVars.money )
		end
	end )
end )

//HIDE DEFAULT HUD
local hideHUDElements = {
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_Agenda"] = true,
}
hook.Add("HUDShouldDraw", "HideDefaultDarkRPHud", function(name)
	if hideHUDElements[name] then return false end
end)

local hide = {}
hide[ "CHudHealth" ] = true
hide[ "CHudBattery" ] = true
hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if hide[ name ] then
		return false
	end
end )