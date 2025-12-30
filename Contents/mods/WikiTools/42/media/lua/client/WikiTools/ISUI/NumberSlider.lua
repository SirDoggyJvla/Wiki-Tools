-- needed libs
require "ISUI/ISPanel"

---@class NumberSlider : ISPanel
---@field defaultValue number
---@field min number
---@field max number
---@field step number
---@field shift number
local NumberSlider = ISPanel:derive("NumberSlider")

function NumberSlider:initialise()
    ISPanel.initialise(self)
    self:create()
end

function NumberSlider:getValue()
    return tonumber(self.valueBox:getInternalText()) or self.defaultValue
end

function NumberSlider:onValueChange_slider(value)
    -- self.slider:setCurrentValue(value, true)
    self.valueBox:setText(tostring(value))
end

function NumberSlider:onValueChange_valueBox(valueBox)
    local value = valueBox:getInternalText()

    -- verify string is not empty and doesn't end with a dot
    if value == "" or value:sub(-1) == "." then
        return
    end

    value = tonumber(value) -- try to convert to number
    if value then
        self.slider:setCurrentValue(value) -- update slider if value is not nil
    end
end

function NumberSlider:create()
    local boxWidth = self.width/3

    -- slider
    local slider = ISSliderPanel:new(0, 0, self.width - boxWidth, self.height, self, self.onValueChange_slider)
    slider:initialise()
    self:addChild(slider)
    self.slider = slider

    -- value box
    local valueBox = ISTextEntryBox:new(tostring(self.defaultValue), self.width - boxWidth, 0, boxWidth, self.height)
    valueBox.onTextChangeFunction = self.onValueChange_valueBox ---@diagnostic disable-line
    valueBox.target = self
    valueBox:initialise()
    self:addChild(valueBox)
    valueBox:setOnlyNumbers(true)
    self.valueBox = valueBox

    slider:setValues(self.min, self.max, self.step, self.shift)
    slider:setCurrentValue(self.defaultValue)
end

function NumberSlider:new(x, y, width, height, defaultValue, min, max, step, shift)
    local o = {}
    o = ISPanel:new(x, y, width, height) --[[@as NumberSlider]]
    setmetatable(o, self)
    self.__index = self

    -- default value
    o.defaultValue = defaultValue
    o.min = min or 0
    o.max = max or 1
    o.step = step or 0.01
    o.shift = shift or 0.1

    o.background = false

    return o
end

return NumberSlider