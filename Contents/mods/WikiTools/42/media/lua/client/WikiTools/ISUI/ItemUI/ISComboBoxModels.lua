require "ISUI/ISComboBox"

---@class ISComboBoxModels : ISComboBox
---@field listingType string
---@field listedItems table<string, {type: string, object: Item}|{type: string}>
---@field noSelectionText string
local ISComboBoxModels = ISComboBox:derive("ISComboBoxModels")



---Determine if the weapon rotation hack is needed for the given model.
---@param fullType string
---@return boolean
function ISComboBoxModels:getWeaponRotationHack(fullType)
    local item = self.listedItems[fullType]
    if not item then return false end

    local object = item.object
    if not object then return false end

    local sprite = object:getWeaponSprite()
    if not sprite then return false end

    return true
end



---Get the list of models available in the script manager.
---@return string[]
function ISComboBoxModels:getModelList()
    -- parse model scripts
    local scripts = getScriptManager():getAllModelScripts()
    local sorted = {} --[[@as string[] ]]
	for i=0,scripts:size()-1 do repeat
        local script = scripts:get(i)
        local fullType = script:getFullType()

        -- ignore body models
        if fullType == "Base.FemaleBody" or fullType == "Base.MaleBody" then
            break
        end
        sorted[#sorted + 1] = fullType
    until true end
    table.sort(sorted)
    return sorted
end

---@return string[]
function ISComboBoxModels:getItemList()
    local items = getScriptManager():getAllItems()
    local sorted = {} --[[@as string[] ]]
    for i=0,items:size()-1 do
        local item = items:get(i)
        local fullType = item:getModuleName() .. "." .. item:getName()
        sorted[#sorted + 1] = fullType
    end
    table.sort(sorted)
    return sorted
end

---Get the item model for the given item.
---@param item Item
---@return string|nil
function ISComboBoxModels:getItemModel(item)
    local model = item:getWorldStaticModel()
    if model then return model end

    model = item:getStaticModel()
    if model then return model end

    model = item:getWeaponSprite()
    if model then return model end

    return nil
end

---Get the model based on the listing type and selected item.
---@param fullType string
---@return string|nil
function ISComboBoxModels:getModel(fullType)
    local item = self.listedItems[fullType]
    if not item then return end
    local type = item.type

    -- try to fetch the proper model based on the listing type
    local model
    if type == "modelScript" then
        model = fullType -- the full type itself is the model script
    elseif type == "itemScript" then
        local object = item.object --[[@as Item]] 
        model = self:getItemModel(object)
    end

    return model
end


function ISComboBoxModels:updateListing(listingType)
    self:clear()

    self.listingType = listingType
    self:populateList()
end

function ISComboBoxModels:populateList()
    local listingType = self.listingType
    print(listingType)
    if listingType == "All models" then
        local sorted = self:getModelList()

        -- add to combo
        local listedItems = {}
        for i = 1,#sorted do
            local scriptName = sorted[i]
            self:addOption(scriptName)
            listedItems[scriptName] = {type="modelScript"}
        end
        self.listedItems = listedItems
        self.noSelectionText = "Select model"
    elseif listingType == "All items" then
        -- parse items
        local items = self:getItemList()

        local listedItems = {}
        for i = 1,#items do
            local fullType = items[i]
            local item = getScriptManager():getItem(fullType)
            self:addOption(fullType)
            listedItems[fullType] = {type="itemScript", object=item}
        end
        self.listedItems = listedItems
        self.noSelectionText = "Select item"
    end

    self.selected = 0 -- default option
end

---Needed for typings to not go insane.
---@param ... any
---@return ISComboBoxModels
function ISComboBoxModels:new(...)
    local o = ISComboBox.new(self, ...) --[[@as ISComboBoxModels]]
    o.listingType = "All items"
    o:populateList()
    return o
end

return ISComboBoxModels