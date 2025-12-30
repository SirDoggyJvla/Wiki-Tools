-- needed libs
require "ISUI/ISPanel"
local NumberSlider = require "WikiTools/ISUI/NumberSlider"

---@class ColorSelector : ISPanel
---@field color table<string, number>
---@field font UIFont
---@field sliderCounts number
---@field sliders_space number
---@field slider_height number
---@field redSlider NumberSlider
---@field greenSlider NumberSlider
---@field blueSlider NumberSlider
---@field alphaSlider NumberSlider|nil
local ColorSelector = ISPanel:derive("ColorSelector")

function ColorSelector:initialise()
    ISPanel.initialise(self)
    self:create()
end

function ColorSelector:render()
    ISPanel.render(self)

    -- draw the slider color on the first third
    local sliderWidth = self.width/3
    local x, y = sliderWidth/6, self.height/6

    local color = self:getColor()
    local box_width = sliderWidth - x*3
    self:drawRect(x, y, box_width, self.height - y*2, color.a, color.r, color.g, color.b)
    local borderColor = self.redSlider.borderColor
    self:drawRectBorderStatic(x, y, box_width, self.height - y*2, borderColor.r, borderColor.g, borderColor.b, borderColor.a)

    local fontHeight = TextManager.instance:getFontHeight(self.font)

    local text_x = x + box_width + 20
    self:drawText("R", text_x, self.redSlider.y + (self.slider_height - fontHeight)/2, 1, 0, 0, 1, self.font)
    self:drawText("G", text_x, self.greenSlider.y + (self.slider_height - fontHeight)/2, 0, 1, 0, 1, self.font)
    self:drawText("B", text_x, self.blueSlider.y + (self.slider_height - fontHeight)/2, 0, 0, 1, 1, self.font)
    if self.alphaSlider then
        self:drawText("A", text_x, self.alphaSlider.y + (self.slider_height - fontHeight)/2, 1, 1, 1, 1, self.font)
    end
end

function ColorSelector:getColor()
    local color = {
        r = tonumber(self.redSlider:getValue()) or 0,
        g = tonumber(self.greenSlider:getValue()) or 0,
        b = tonumber(self.blueSlider:getValue()) or 0,
    }

    if self.alphaSlider then
        color.a = tonumber(self.alphaSlider.slider.currentValue) or 1
    else
        color.a = 1
    end

    return color
end


function ColorSelector:create()
    local sliderWidth = self.width*2/3
    local sliderHeight = self.slider_height - 1

    -- red slider
    ---@type number, number
    local x, y = self.width/3, 2
    local redSlider = NumberSlider:new(x, y, sliderWidth, sliderHeight, self.color.r)
    redSlider:initialise()
    self:addChild(redSlider)
    self.redSlider = redSlider

    -- green slider
    y = y + sliderHeight + self.sliders_space
    local greenSlider = NumberSlider:new(x, y, sliderWidth, sliderHeight, self.color.g)
    greenSlider:initialise()
    self:addChild(greenSlider)
    self.greenSlider = greenSlider

    -- blue slider
    y = y + sliderHeight + self.sliders_space
    local blueSlider = NumberSlider:new(x, y, sliderWidth, sliderHeight, self.color.b)
    blueSlider:initialise()
    self:addChild(blueSlider)
    self.blueSlider = blueSlider

    -- alpha slider
    if self.color.a then
        y = y + sliderHeight + self.sliders_space
        local alphaSlider = NumberSlider:new(x, y, sliderWidth, sliderHeight, self.color.a)
        alphaSlider:initialise()
        self:addChild(alphaSlider)
        self.alphaSlider = alphaSlider
    end
end

function ColorSelector:new(x, y, width, height, startColor, _alpha)
    local o = {}
    o = ISPanel:new(x, y, width, height) --[[@as ColorSelector]]
    setmetatable(o, self)
    self.__index = self

    -- start color
    o.color = startColor or {r=1, g=1, b=1, a=1}
    o.sliderCounts = 4

    -- remove alpha if not needed
    if not _alpha then
        o.color.a = nil
        o.sliderCounts = o.sliderCounts - 1
    end

    o.backgroundColor = {r=0, g=0, b=0, a=1}

    o.font = UIFont.Small

    -- UI settings
    o.sliders_space = 10
    o.slider_height = math.floor((height - (o.sliderCounts-1)*o.sliders_space)/3)

    return o
end



return ColorSelector