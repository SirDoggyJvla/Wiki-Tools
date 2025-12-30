-- needed libs
require "Vehicles/ISUI/ISUI3DScene"

---@class Wiki3DScene : ISUI3DScene
---@field javaObject UI3DScene
---@field parent ItemUI
---@field currentModel string
local Wiki3DScene = ISUI3DScene:derive("Wiki3DScene")

--- fromLua HELPERS (the number is the number of arguments)

function Wiki3DScene:fromLua0(methodName)
    self.javaObject:fromLua0(methodName)
end

function Wiki3DScene:fromLua1(methodName, arg1)
    self.javaObject:fromLua1(methodName, arg1)
end

function Wiki3DScene:fromLua2(methodName, arg1, arg2)
    self.javaObject:fromLua2(methodName, arg1, arg2)
end

function Wiki3DScene:fromLua3(methodName, arg1, arg2, arg3)
    self.javaObject:fromLua3(methodName, arg1, arg2, arg3)
end

function Wiki3DScene:fromLua4(methodName, arg1, arg2, arg3, arg4)
    self.javaObject:fromLua4(methodName, arg1, arg2, arg3, arg4)
end

--- SCENE MODIFICATIONS

---Create a model in the 3D scene.
---```JAVA
---createModel(id, modelScriptName)
---```
---@param id string
---@param scriptName string
function Wiki3DScene:setModel(id, scriptName, weaponRotationHack)
    if not self.currentModel or self.currentModel ~= scriptName then
        self:removeModel(id) -- remove first the model if already exists

        -- add new model
        self.currentModel = scriptName
        self:fromLua2("createModel", id, scriptName)
        self:setModelUseWorldAttachment(true, id) -- always do that

        self:setModelWeaponRotationHack(weaponRotationHack, id)
    end
end

---Remove the model from the 3D scene.
---@param id string
function Wiki3DScene:removeModel(id)
    if self.currentModel then
        self.currentModel = nil
        self:fromLua1("removeModel", id)
    end
end

function Wiki3DScene:setModelUseWorldAttachment(bool, id)
    self:fromLua2("setModelUseWorldAttachment", id, bool)
end

function Wiki3DScene:setModelWeaponRotationHack(bool, id)
    self:fromLua2("setModelWeaponRotationHack", id, bool)
end

function Wiki3DScene:setDrawGridAxes(bool)
    self:fromLua1("setDrawGrid", bool)
    self:fromLua1("setDrawGridAxes", bool)
end

function Wiki3DScene:setAttach(attach)
    attach = "world"
    self:fromLua3("placeAttachmentAtOrigin", "worldModel", attach, true)
end

function Wiki3DScene:getModelScript()
    -- The game does it this way internally, but somehow this doesn't work in our case

    -- local count = self:fromLua0("getModelCount")
    -- print(count)
    -- if count then
    --     for i=1,count do
    --         local modelScript = self:fromLua1("getModelScript", i-1)
    --         print(modelScript)
    --     end
    -- end

    -- return self:fromLua1("getModelScript", 0)

    -- So we use a simpler method below
    -- tbf idk why the game doesn't even use that in the first place
    return ScriptManager.instance:getModelScript(self.currentModel)
end


--- ACTION REACTIONS

function Wiki3DScene:onTickFromLua1(bool, method)
    self:fromLua1(method, bool)
end

--- INSTANCE SETUP

function Wiki3DScene:setBackgroundColor(color)
    self.backgroundColor = color
end

---Setup the default 3D view.
function Wiki3DScene:setupScene()
    self:setView("UserDefined")
    self:fromLua3("setViewRotation", 30.0, 45.0 + 90.0, 0.0)
    self:fromLua1("setGridPlane", "XZ")

    self:fromLua1("setMaxZoom", 20)
	self:fromLua1("setZoom", 10)
	-- self:fromLua1("setGizmoScale", 1.0 / 5.0)

    self:fromLua1("setDrawGrid", false)

    self:fromLua0("clearAABBs")
    self:fromLua0("clearAxes")
end

---@return Wiki3DScene
function Wiki3DScene:new(x, y, width, height)
	local o = ISUI3DScene.new(self, x, y, width, height) --[[@as Wiki3DScene]]
	o.background = true
	o.backgroundColor = {r=0, g=1, b=0, a=1}
    -- o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	return o
end


return Wiki3DScene