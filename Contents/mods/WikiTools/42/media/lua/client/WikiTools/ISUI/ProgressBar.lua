-- needed libs
require "ISUI/ISPanel"

---@class ProgressBar : ISPanel
---@field value number
---@field maxValue number
---@field font UIFont
local ProgressBar = ISPanel:derive("ProgressBar")


function ProgressBar:initialise()
    ISPanel.initialise(self)
    -- self:create()
end

function ProgressBar:setValue(value)
    self.value = value
end

function ProgressBar:setMaxValue(maxValue)
    self.maxValue = maxValue
end

function ProgressBar:render()
    ISPanel.render(self)

    local progress = math.min(self.value / self.maxValue, 1.0)
    local barWidth = math.floor(self.width * progress)

    -- draw the progress bar
    self:drawRect(0, 0, barWidth, self.height, 1, 0, 1, 0)

    -- draw the border
    local borderColor = {r=1, g=1, b=1, a=1}
    self:drawRectBorderStatic(0, 0, self.width, self.height, borderColor.r, borderColor.g, borderColor.b, borderColor.a)

    -- draw counter text
    local counterText = string.format("%d / %d", self.value, self.maxValue)
    local fontHeight = TextManager.instance:getFontHeight(self.font)
    local textX = (self.width - TextManager.instance:MeasureStringX(self.font, counterText)) / 2
    local textY = (self.height - fontHeight) / 2
    self:drawText(counterText, textX, textY, 1, 1, 1, 1, self.font)
end

-- function ProgressBar:create()
--     -- body
-- end

---@return ProgressBar
function ProgressBar:new(x, y, width, height, maxValue)
    local o = {}
    o = ISPanel:new(x, y, width, height) --[[@as ProgressBar]]
    setmetatable(o, self)
    self.__index = self

    o.value = 0
    o.maxValue = maxValue
    o.font = UIFont.Small

    return o
end

return ProgressBar