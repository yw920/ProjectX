local reg = "[^ ]+"

local verts = {}

local trangles = {}

local adjacent = {}

for line in io.lines("/Users/yanwei/Desktop/ProjectX/model.obj") do
    local input = {}
    for splits in string.gmatch(line, reg) do
        input[#input + 1] = splits
    end

    if input[1] == "v" then
        verts[#verts + 1] = {
            x = tonumber(input[2]),
            y = tonumber(input[3]),
            z = tonumber(input[4])
        }
    end

    if input[1] == "f" then
        local v = {}
        for i = 2, 4 do
            v[#v + 1] = tonumber(input[i])
        end
        local len = #trangles
        trangles[len + 1] = {
            vdx1 = v[1],
            vdx2 = v[2],
            vdx3 = v[3]
        }

        for i = 1, 3 do
            local idx = v[i]
            local adj = adjacent[idx]
            if not adj then
                adjacent[idx] = {len+1}
            else
                adj[#adj+1] = len+1
            end
        end
    end
end

local aim = 1
local num = 0

local m = #verts
local n = #trangles

print(num)
