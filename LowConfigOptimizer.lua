
LCO = {};
LCO.panel = CreateFrame("frame", "LowConfigOptimizerFrame", UIParent );
LCO.panel.name = "LowConfigOptimizer";

InterfaceOptions_AddCategory(LCO.panel);

LCO.panel:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
LCO.panel:RegisterEvent("PLAYER_ENTERING_WORLD"); -- Fired when saved variables are loaded
function LCO.panel:OnEvent(event, arg1)
	if (event == "ADDON_LOADED" and arg1 == "LowConfigOptimizer") then
		if (LCOconfig == nil) then
			LCOconfig = {}
			LCOconfig.delay = 2
			LCOconfig.minFPS = 30
			LCOconfig.maxFPS = 50
			LCOconfig.minScale = 0.5
			LCOconfig.raidScale = 0.7
			LCOconfig.pvpScale = 0.7
			LCOconfig.djScale = 0.7
			LCOconfig.arenaScale = 0.7
			LCOconfig.raidEnable = false
			LCOconfig.pvpEnable = false
			LCOconfig.djEnable = false
			LCOconfig.arenaEnable = false
		else
		end
		CreateSlider()
	elseif (event == "PLAYER_ENTERING_WORLD") then
		LCO.ticker = CheckForLaunchingTicker()
	end
end
LCO.panel:SetScript("OnEvent", LCO.panel.OnEvent);



function LCO.panel.okay()
	xpcall(function()
		LCO.ticker = CheckForLaunchingTicker()
	end, geterrorhandler())
end	

function LCO.panel.default()
	xpcall(function()
			LCOconfig.delay = 2
			LCOconfig.minFPS = 30
			LCOconfig.maxFPS = 50
			LCOconfig.minScale = 0.5
			LCOconfig.raidScale = 0.7
			LCOconfig.pvpScale = 0.7
			LCOconfig.djScale = 0.7
			LCOconfig.arenaScale = 0.7
			LCOconfig.raidEnable = false
			LCOconfig.pvpEnable = false
			LCOconfig.djEnable = false
			LCOconfig.arenaEnable = false
	end, geterrorhandler())
end	


local SimpleRound = function(val,valStep)
    return floor(val/valStep)*valStep
end
LCO_sliderCount = 0 
local CreateBasicSlider = function(parent, name, title, minVal, maxVal, valStep, valueBase, doCheckbox)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(valStep)
    slider.text = _G[name.."Text"]
    slider.text:SetText(title)
    slider.textLow = _G[name.."Low"]
    slider.textHigh = _G[name.."High"]
    slider.textLow:SetText(floor(minVal))
    slider.textHigh:SetText(floor(maxVal))
    slider.textLow:SetTextColor(0.4,0.4,0.4)
	slider.textHigh:SetTextColor(0.4,0.4,0.4)
	slider:SetObeyStepOnDrag(true)
	slider:SetPoint ("topleft", LCO.panel, "topleft", 40, -50 + LCO_sliderCount * -40)
	LCO_sliderCount = LCO_sliderCount + 1
	slider:SetValue(valueBase)
	editbox:SetSize(50,30)
  editbox:ClearAllPoints()
	editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
	editbox:SetText(valueBase)
	editbox:SetCursorPosition(0)
	editbox:SetAutoFocus(false)
	
	checkbox = nil
	if (doCheckbox) then
		checkbox = CreateFrame("CheckButton", "$parentCheckBox", LCO.panel, "ChatConfigCheckButtonTemplate")
		checkbox:SetSize(30,30)
		checkbox:ClearAllPoints()
		checkbox:SetPoint("RIGHT", slider, "LEFT", -5, 0)
	end
	slider:SetScript("OnValueChanged", function(self,value)
		self.editbox:SetText(SimpleRound(value, valStep))
    end)
    editbox:SetScript("OnTextChanged", function(self)
    local val = self:GetText()
    	if tonumber(val) then
         	self:GetParent():SetValue(val)
      	end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
      	local val = self:GetText()
      	if tonumber(val) then
         	self:GetParent():SetValue(val)
        	 self:ClearFocus()
      	end
    end)
	slider.editbox = editbox
	slider.checkbox = checkbox
    return slider
 end

 function CreateSlider()
  local SliderCheckDelay = CreateBasicSlider(LCO.panel, "SliderDelay", "Time between check (seconds)", 0.1, 5, 0.1, LCOconfig.delay, false)
  	SliderCheckDelay:HookScript("OnValueChanged", function(self,value)
	LCOconfig.delay = value
  end)

  local SliderMinFPS = CreateBasicSlider(LCO.panel, "SliderMinFPS", "Min FPS", 1, 120, 1, LCOconfig.minFPS, false)
  SliderMinFPS:HookScript("OnValueChanged", function(self,value)
	if (value >= SliderMaxFPS:GetValue()) then
		self:SetValue(SliderMaxFPS:GetValue() - 1)
	end
	LCOconfig.minFPS = value
  end)

  local SliderMaxFPS = CreateBasicSlider(LCO.panel, "SliderMaxFPS", "Max FPS", 1, 120, 1, LCOconfig.maxFPS, false)
  SliderMaxFPS:HookScript("OnValueChanged", function(self,value)
	if (value <= SliderMinFPS:GetValue()) then
		self:SetValue(SliderMinFPS:GetValue() + 1)
	end
	LCOconfig.maxFPS = value
  end)

  local SliderMinScale = CreateBasicSlider(LCO.panel, "SliderMinScale", "Min Scale", 0.1, 1, 0.1, LCOconfig.minScale, false)
  SliderMinScale:HookScript("OnValueChanged", function(self,value)
	LCOconfig.minScale = value
	local scale = GetCVar("RenderScale")
	if (tonumber(scale) < value) then
		SetCVar("RenderScale", value)
	end
  end)

  local SliderRaidScale = CreateBasicSlider(LCO.panel, "SliderRaidScale", "Raid Scale", 0.1, 1, 0.1, LCOconfig.raidScale, true)
  SliderRaidScale:HookScript("OnValueChanged", function(self,value)
	LCOconfig.raidScale = value
  end)
  SliderRaidScale.checkbox:SetChecked(LCOconfig.raidEnable)
  SliderRaidScale.checkbox:HookScript("OnClick", function(self)
	LCOconfig.raidEnable = self:GetChecked()
  end)


  local SliderDjScale = CreateBasicSlider(LCO.panel, "SliderDjScale", "Dungeon Scale", 0.1, 1, 0.1, LCOconfig.djScale, true)
  SliderDjScale:HookScript("OnValueChanged", function(self,value)
	LCOconfig.djScale = value
  end)
  SliderDjScale.checkbox:SetChecked(LCOconfig.djEnable)
  SliderDjScale.checkbox:HookScript("OnClick", function(self)
	LCOconfig.djEnable = self:GetChecked()
  end)

  local SliderPvPScale = CreateBasicSlider(LCO.panel, "SliderPvPScale", "PvP Scale", 0.1, 1, 0.1, LCOconfig.pvpScale, true)
  SliderPvPScale:HookScript("OnValueChanged", function(self,value)
	LCOconfig.pvpScale = value
  end)
  SliderPvPScale.checkbox:SetChecked(LCOconfig.pvpEnable)
  SliderPvPScale.checkbox:HookScript("OnClick", function(self)
	LCOconfig.pvpEnable = self:GetChecked()
  end)

  
  local SliderArenaScale = CreateBasicSlider(LCO.panel, "SliderArenaScale", "Arena Scale", 0.1, 1, 0.1, LCOconfig.arenaScale, true)
  SliderArenaScale:HookScript("OnValueChanged", function(self,value)
	LCOconfig.arenaScale = value
  end)
  SliderArenaScale.checkbox:SetChecked(LCOconfig.arenaEnable)
  SliderArenaScale.checkbox:HookScript("OnClick", function(self)
	LCOconfig.arenaEnable = self:GetChecked()
  end)
end

function CreateTicker()
	return C_Timer.NewTicker(LCOconfig.delay, function()
		inInstance, instanceType = IsInInstance()
			local framerate = GetFramerate();
			if (IsFlying() == false and framerate < LCOconfig.minFPS) then
				local scale = GetCVar("RenderScale")
				scale = scale - 0.1
				if scale < LCOconfig.minScale then scale = LCOconfig.minScale end
				SetCVar("RenderScale", scale)
			end
			if (framerate > LCOconfig.maxFPS) then
				local scale = GetCVar("RenderScale")
				scale = scale + 0.2
				if scale > 1 then scale = 1 end
				SetCVar("RenderScale", scale)
			end
	end)
end


function SetForcedScale()
	local i, t = IsInInstance()
	local newScale = 0.5
	if (t == "raid") then
		newScale = LCOconfig.raidScale
	elseif (t == "party") then
		newScale = LCOconfig.djScale
	elseif (t == "pvp") then
		newScale = LCOconfig.pvpScale
	elseif (t == "arena") then
		newScale = LCOconfig.arenaScale
	end
	SetCVar("RenderScale", newScale)
end

function CheckForLaunchingTicker()
	local i, t = IsInInstance()
	local ret = nil
	if (LCO.ticker) then
		LCO.ticker:Cancel()
	end
	if (t == "raid" and LCOconfig.raidEnable == false) then
		ret = CreateTicker()
	elseif (t == "party" and LCOconfig.djEnable == false) then
		ret = CreateTicker()
	elseif (t == "pvp" and LCOconfig.pvpEnable == false) then
		ret = CreateTicker()
	elseif (t == "arena" and LCOconfig.arenaEnable == false) then
		ret = CreateTicker()
	elseif (t == "none") then
		ret = CreateTicker()
	else
		SetForcedScale()
	end
	return ret
end

