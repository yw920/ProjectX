local reg = "[^ ]+"

local verts = {}

local trangles = {}

local adjacent = {}

local alpha = 80

local function PMinus(p2, p1)
    local p = {}
    p.x = p2.x - p1.x
    p.y = p2.y - p1.y
    p.z = p2.z - p1.z
    return p
end

local function CalcNormal(face)
    local vdx1 = verts[face.vdx1]
    local vdx2 = verts[face.vdx2]
    local vdx3 = verts[face.vdx3]

    local v10 = PMinus(vdx2, vdx1)
    local v20 = PMinus(vdx3, vdx1)

    local n0 = v10.y * v20.z - v10.z * v20.y
    local n1 = v10.z * v20.x - v10.x * v20.z
    local n2 = v10.x * v20.y - v10.y * v20.x

    local len2 = n0 * n0 + n1 * n1 + n2 * n2
    if len2 >= 0 then
        local len = math.sqrt(len2)
        n0 = n0 / len
        n1 = n1 / len
        n2 = n2 / len
        return {x = n0, y = n1, z = n2}
    end
    local a
    assert(false)
end

for line in io.lines("/Users/bytedance/Desktop/ProjectX/model.obj") do
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

        table.sort(
            v,
            function(a, b)
                return a < b
            end
        )

        local ids = {}
        ids[1] = v[1] .. "_" .. v[2]
        ids[2] = v[1] .. "_" .. v[3]
        ids[3] = v[2] .. "_" .. v[3]

        for i = 1, 3 do
            local adj = adjacent[ids[i]]
            if not adj then
                adjacent[ids[i]] = {len + 1}
            else
                adj[#adj + 1] = len + 1
            end
        end
    end
end

local cases = 0
for id, faceIndexes in pairs(adjacent) do
    assert(#faceIndexes == 2)
    local normal1 = CalcNormal(trangles[faceIndexes[1]])
    local normal2 = CalcNormal(trangles[faceIndexes[2]])

    local dot = normal1.x * normal2.x + normal1.y * normal2.y + normal1.z * normal2.z

    local dis1 = normal1.x * normal1.x + normal1.y * normal1.y + normal1.z * normal1.z
    local dis2 = normal2.x * normal2.x + normal2.y * normal2.y + normal2.z * normal2.z
    local cos = dot / (math.sqrt(dis1) * math.sqrt(dis2))
    local b = math.acos(cos)
    local an = math.acos(cos) * 180 / math.pi
    if alpha > 80 then
        cases = cases + 1
        local face1 = trangles[faceIndexes[1]]
        verts[face1.vdx1] = {x = 0, y = 0, z = 0}
        verts[face1.vdx2] = {x = 0, y = 0, z = 0}
        verts[face1.vdx3] = {x = 0, y = 0, z = 0}

        local face2 = trangles[faceIndexes[2]]
        verts[face2.vdx1] = {x = 0, y = 0, z = 0}
        verts[face2.vdx2] = {x = 0, y = 0, z = 0}
        verts[face2.vdx3] = {x = 0, y = 0, z = 0}
    end
end

local output = io.open("/Users/bytedance/Desktop/ProjectX/output.obj", "w")

local fmt = "v %f %f %f \n"
for i, v in pairs(verts) do
    output:write(string.format(fmt, v.x, v.y, v.z))
end

local fmt = "f %d %d %d \n"
for i, tran in pairs(trangles) do
    output:write(string.format(fmt, tran.vdx1, tran.vdx2, tran.vdx3))
end
