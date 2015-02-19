--<<Techies Allahu Akbar Auto Suicide on Killable Target d000000h>>--
--<<Tutorial Comes from NOVA>>--
--<<Some codes come from Axe Blink Ulti By Moones>>--
require("libs.Utils")  -- Honestly, just go here - https://github.com/Rulfy/ensage-wip/blob/master/Libraries/Utils.lua and read all the functions.
require("libs.ScriptConfig") --This one is so I can set a hotkey and the user can easily change it on Ensage

--Config -- Just copy it and change the keys, you can also have things like TYPE_NUMBER (Good for changing a delay, or text position for example)
config = ScriptConfig.new()
config:SetParameter("ComboKey", "H", config.TYPE_HOTKEY) 
config:SetParameter("StopKey", "S", config.TYPE_HOTKEY) 
config:Load()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Some variables we gotta set (Well we don't have to, just makes our lives easier) 
local ComboKey     = config.ComboKey   -- So when we refer to our key we can just say "ComboKey", rather than config.ComboKey everytime
local StopKey      = config.StopKey    -- If we want to cancel the combo
local active	   = false             --Initially the Combo will not be active until we press a hotkey

local registered   = false            --Used when closing and opening the script 

--We don't really need these this time, but 90% of the time they are really useful :)
local range 	= 1200                 --The range of our script, lets just make it the blink dagger range for this example
local target    = nil                  --Initially there should be no target unless we try to find one

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--TEXT INGAME (If you wanna set the location of the text then change the numbers on the line under this one)
local x,y = 1350, 50  -- x = x axis || y = y axis 
local monitor = client.screenSize.x/1600
local font = drawMgr:CreateFont("font","Verdana",12,300)  --CreateFont(name, fontname, tall, weight)

local statusText = drawMgr:CreateText(x*monitor,y*monitor,0x5DF5F5FF,"Techies Allahu Akbar || Press " .. string.char(ComboKey) .. " || to blink suicide.",font) statusText.visible = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--When the script loads up, this happens
function onLoad()
	if PlayingGame() then  --if I'm playing the game then... (Note this PlayingGame() function comes from Utils)
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Techies then 
			script:Disable()
		else
			registered = true
			statusText.visible = true   --The text is now ENABLED because we are playing, and I am Techies
			script:RegisterEvent(EVENT_TICK,Main)  --This assigns the game tick to function Main(tick)
			script:RegisterEvent(EVENT_KEY,Key)   --This assigns keys to function Key
			script:UnregisterEvent(onLoad)  --Unregisters this function so it doesn't keep checking once you are registered. More details at bottom of page.
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--What pressing a key does
function Key(msg,code)
	if client.chat or client.console or client.loading then return end --Just so talking on chat for example doesn't set off your hotkeys
	
	if code == ComboKey then  -- If I press D then my script is "Active"
		active = true   
		statusText = drawMgr:CreateText(x*monitor,y*monitor,0x5DF5F5FF,"Techies Allahu Akbar || Now Active",font)
	end
	
	if code == StopKey then     -- If I press S then my script is not "Active"
		active = false               
		statusText = drawMgr:CreateText(x*monitor,y*monitor,0x5DF5F5FF,"Techies Allahu Akbar || Now Inactive",font)		
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Now that we've sorted out all the initiation stuff, let's get into the actual script 


function Main(tick)  --The tick is a function that is run constantly
    if not SleepCheck() then return end

    local me = entityList:GetMyHero() --Gets my hero, useful for getting a lot of information
    if not me then return end  --If the player is not me, then the tick function would end here.
	
--Now lets get what we need for the Combo (Note, all of these use "me")
    local Blink = me:FindItem("item_blink")
    local Suicide = me:GetAbility(3) 
	local Damages = {500, 650, 850, 1150}
	local Blinkrange = 1200

--Now the actual Combo
    if active then --If I've pressed the ComboKey, then this is true, as soon as I press the StopKey, this becomes false and stops the combo :)
	
       if me.alive then --If im alive
	   
	   local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})
	   local Castpoint = 0
	   lags = client.latency/1000
	   dmg = Damages[Suicide.level]
			for i,v in ipairs(enemies) do
				if not v:IsIllusion() then
					if v.visible and v.alive and v.health > 0 then
					local healthtokill = math.floor(v.health - dmg + lags*v.healthRegen)
						if healthtokill <= 0 then
							if GetDistance2D(me,v) <= Blinkrange then 
							me:SafeCastItem(Blink.name,v.position)
							me:SafeCastAbility(Suicide,v) 
							end
						end
					end					
	return
    end
end
	end   		
    end
	
end

--When the game ends
function onClose()
	collectgarbage("collect")
	if registered then
	    statusText.visible = false --Make sure to turn your status text off after script closes
            script:UnregisterEvent(Main)
    	    script:UnregisterEvent(Key)
	    registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose) 
script:RegisterEvent(EVENT_TICK,onLoad) -- At the beginning TICK is assigned to onload (to keep checking until registered)