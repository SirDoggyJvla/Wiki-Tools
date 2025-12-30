-- needed libs
require "ISUI/ISPanel"
local CharacterOutfit3D = require "WikiTools/ISUI/CharacterOutfitUI/CharacterOutfit3D"
local ColorSelector = require "WikiTools/ISUI/ColorSelector"
local NumberSlider = require "WikiTools/ISUI/NumberSlider"
local ProgressBar = require "WikiTools/ISUI/ProgressBar"

local module = require "WikiTools/module"

---CACHE
local BUTTON_WIDTH, BUTTON_HEIGHT = 100, 25
local BORDER_X, BORDER_Y = 25, 25


---@class CharacterOutfitUI : ISPanel
---@field filenamePattern string
---@field screenshotDelay number
---@field lastScreenshotTime number
---@field outfits table<number, {outfit:string, gender:string}>
---@field model_x integer
---@field model_y integer
---@field model_w integer
---@field model_h integer
---@field renderOutfits table<number, {outfit:string, gender:string}>
---@field iteration integer
---@field maxIterations integer
---@field model3D CharacterOutfit3D
---@field closeButton ISButton
---@field logPanel ISRichTextPanel
---@field parse_outfits ISButton
---@field colorSelector ColorSelector
---@field progressBar ProgressBar
---@field deltaSelector NumberSlider
local CharacterOutfitUI = ISPanel:derive("CharacterOutfitUI")





---[[=====================================]]
--- RENDERING
---[[=====================================]]

---Updates the background color and takes screenshots of outfits at a timed interval.
function CharacterOutfitUI:prerender()
    ISPanel.prerender(self)

    local bgColor = self.colorSelector:getColor()
    bgColor.a = 1
    self.model3D:setBackgroundColor(bgColor)

    if not self.renderOutfits then
        return
    end

    --- RENDER NEXT OUTFIT
    local i = self.iteration
    local outfit = self.renderOutfits[i]
    if not outfit then
        self.renderOutfits = nil
        self.lastScreenshotTime = nil
        return
    end

    local filename = self:getFilename(outfit)

    -- verify that the time delta was reached before screenshot
    local currentTime = getTimestampMs() / 1000
    if not self.lastScreenshotTime then
        -- set outfit to model view
        local female = outfit.gender == "female"
        self.model3D:setOutfitName(outfit.outfit, female)

        self:log(filename)
        self.progressBar:setValue(i)

        self.lastScreenshotTime = currentTime
    elseif (currentTime - self.lastScreenshotTime) > self.deltaSelector:getValue() then
        -- take screenshot
        self:takeScreenshot(filename)

        -- increase iteration counter
        self.iteration = self.iteration + 1
        self.lastScreenshotTime = nil
        if i >= self.maxIterations then
            self.renderOutfits = nil
            return
        end
    end
end



---[[=====================================]]
--- UTILS
---[[=====================================]]

---Retrieve all the outfits from the game.
---@return table<number, {outfit:string, gender:string}>
function CharacterOutfitUI:getOutfits()
    local maleOutfits = getAllOutfits(false)
    local femaleOutfits = getAllOutfits(true)

    -- store outfits in a single list
    local outfits = {}
    for i = 0, maleOutfits:size() - 1 do
        local outfit = maleOutfits:get(i)
        table.insert(outfits, {outfit = outfit, gender = "male"})
    end
    for i = 0, femaleOutfits:size() - 1 do
        local outfit = femaleOutfits:get(i)
        table.insert(outfits, {outfit = outfit, gender = "female"})
    end

    return outfits
end

---Format a template parameters written as `{param}` into a string. 
---@param template string
---@param params table
---@return string
---@return integer
function CharacterOutfitUI:formatTemplate(template, params)
    return template:gsub("{(%w+)}", params)
end

---Get the filename from the provided params.
---@param params table
---@return string
---@return integer
function CharacterOutfitUI:getFilename(params)
    return self:formatTemplate(self.filenamePattern, params)
end

---Take a screenshot which saves inside the cache folder `Zomboid/Screenshots` with the filename.
---@param filename string
function CharacterOutfitUI:takeScreenshot(filename)
    getCore():TakeFullScreenshot(filename)
end



---[[=====================================]]
--- BUTTONS AND UI ELEMENTS REACTIONS
---[[=====================================]]

---Close the UI.
function CharacterOutfitUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    module.UIinstance = nil
end

---Log a message to the log panel.
---@param message string
function CharacterOutfitUI:log(message)
    self.logPanel.text = message .. "\n" .. self.logPanel.text
    self.logPanel:paginate()
end

function CharacterOutfitUI:parseOutfits()
    -- intialize rendering
    self.renderOutfits = self.outfits
    self.iteration = 1
end



---[[=====================================]]
--- INSTANCE SETUP
---[[=====================================]]

function CharacterOutfitUI:initialise()
    ISPanel.initialise(self)
    self:create()
end

function CharacterOutfitUI:create()
    -- close button
    local closeButton = ISButton:new(self.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "Close", self, self.close)
    closeButton:initialise()
    self:addChild(closeButton)
    self.closeButton = closeButton

    --- create 3D model scene
    local model_x, model_y = self.model_x, self.model_y
    local model_w, model_h = self.model_w, self.model_h
    local model3D = CharacterOutfit3D:new(model_x, model_y, model_w, model_h)
    model3D:initialise()
    self:addChild(model3D)
    self.model3D = model3D

    -- color background selector
    local color_w, color_h = 400, 150
    local color_x, color_y = model_x + model_w + BORDER_X, self.height - BORDER_Y - color_h
    local colorSelector = ColorSelector:new(color_x, color_y, color_w, color_h, {r=0, g=1, b=0, a=1}, false)
    colorSelector:initialise()
    self:addChild(colorSelector)
    self.colorSelector = colorSelector

    -- log panel
    local log_x, log_y = color_x, BORDER_Y
    local log_w, log_h = 200, self.height - BORDER_Y*3 - color_h
    local logPanel = ISRichTextPanel:new(log_x, log_y, log_w, log_h)
    logPanel:initialise()

    logPanel.backgroundColor = {r=0, g=0, b=0, a=1}
    logPanel.autosetheight = false
    logPanel.clip = true
    logPanel:addScrollBars()

    self.clearText = "Logs"
    logPanel.text = self.clearText
    logPanel:paginate()

    self:addChild(logPanel)
    self.logPanel = logPanel

    -- parse outfits button
    local parse_outfits = ISButton:new(log_x + log_w + BORDER_X, log_y, BUTTON_WIDTH, BUTTON_HEIGHT, "Parse outfits", self, self.parseOutfits)
    parse_outfits:initialise()
    self:addChild(parse_outfits)
    self.parse_outfits = parse_outfits

    -- stop button
    local stop_x, stop_y = log_x + log_w + BORDER_X, log_y + BUTTON_HEIGHT + BORDER_Y
    local stop_button = ISButton:new(stop_x, stop_y, BUTTON_WIDTH, BUTTON_HEIGHT, "Stop", self, function(self) self.renderOutfits = nil; self.lastScreenshotTime = nil end)
    stop_button:initialise()
    self:addChild(stop_button)
    self.stop_button = stop_button

    -- time delta selector label
    local deltaLabel = ISLabel:new(stop_x, stop_y + BUTTON_HEIGHT + BORDER_Y - 20, 20, "Delay (s):", 1, 1, 1, 1, UIFont.Small, true)
    deltaLabel:initialise()
    self:addChild(deltaLabel)
    self.deltaLabel = deltaLabel

     -- time delta selector
    local delta_x, delta_y = stop_x, stop_y + BUTTON_HEIGHT + BORDER_Y
    local delta_w, delta_h = color_w, 25
    local deltaSelector = NumberSlider:new(delta_x, delta_y, delta_w, delta_h, self.screenshotDelay, 0, 20, 0.1, 1)
    deltaSelector:initialise()
    self:addChild(deltaSelector)
    self.deltaSelector = deltaSelector

    -- progress bar
    local progress_x, progress_y = delta_x, delta_y + delta_h + BORDER_Y
    local progress_w, progress_h = color_w, 25
    local progressBar = ProgressBar:new(progress_x, progress_y, progress_w, progress_h, 1)
    progressBar:initialise()
    self:addChild(progressBar)
    self.progressBar = progressBar
    progressBar:setMaxValue(#self.outfits)

    -- filename text box
    local filename_x, filename_y = progress_x, progress_y + progress_h + BORDER_Y
    local filename_w, filename_h = color_w, 25
    local filenameBox = ISTextEntryBox:new(self.filenamePattern, filename_x, filename_y, filename_w, filename_h)
    filenameBox:initialise()
    self:addChild(filenameBox)
    self.filenameBox = filenameBox
end

---Create a new instance of CharacterOutfitUI.
---@return CharacterOutfitUI
function CharacterOutfitUI:new()
    local o = {}
    o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight()) --[[@as CharacterOutfitUI]]
    setmetatable(o, self)
    self.__index = self

    o.filenamePattern = "OutfitParser/Outfit {outfit} {gender}.png"
    o.model_x, o.model_y = BORDER_X, BORDER_Y
    o.model_w, o.model_h = getCore():getScreenHeight() - BORDER_Y*2, getCore():getScreenHeight() - BORDER_Y*2

    o.screenshotDelay = 1 -- seconds

    o.outfits = o:getOutfits()
    o.maxIterations = #o.outfits

    o.backgroundColor.a = 0.8

    return o
end


return CharacterOutfitUI