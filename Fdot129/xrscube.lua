local i = 0
local obj = nil
local mat = nil

function onLoad()
  print("[INFO]: Load")
  obj = self --implicit
end

function onFixedUpdate()
  if (i == 0) then i = 1 print("[INFO]: Fixed Update") end
  mat = obj.getMaterialsInChildren()[1]
  mat.set("_Translation", obj.getPosition())
  mat.set("_Rotation", obj.getRotation())
  mat.set("_Scale", obj.getScale())
end