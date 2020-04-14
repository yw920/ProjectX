local reg = "[^ ]+"

local verts = {}

local trangles = {}

local adjacent = {}

local smoothVerts = {}

local weights = {}

local alpha = 70

local spread = true

local t = {...}

local inputDir = t[1]
local outputDir = t[2]

local function PMinus(p2, p1)
    local p = {}
    p.x = p2.x - p1.x
    p.y = p2.y - p1.y
    p.z = p2.z - p1.z
    return p
end

local function PAdd(p1, p2)
    local p = {}
    p.x = p2.x + p1.x
    p.y = p2.y + p1.y
    p.z = p2.z + p1.z
    return p
end

local function PDevide(p1, devide)
    p1.x = p1.x / devide
    p1.y = p1.y / devide
    p1.y = p1.y / devide
end

local function PNormalize(p, isreferece)
    local len2 = p.x * p.x + p.y * p.y + p.z * p.z
    if len2 > 0 then
        local len = math.sqrt(len2)
        if isreferece then
            p.x = p.x / len
            p.y = p.y / len
            p.z = p.z / len
            return
        end

        local ret = {}
        ret.x = p.x / len
        ret.y = p.y / len
        ret.z = p.z / len
        return ret
    end
    assert(false)
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
    assert(false)
end

for line in io.lines(inputDir) do
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

        weights[len + 1] = 1

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

local needSmoothFace = {}

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
    if an > alpha then
        cases = cases + 1
        needSmoothFace[faceIndexes[1]] = true
        needSmoothFace[faceIndexes[2]] = true
        weights[faceIndexes[1]] = 1
        weights[faceIndexes[2]] = 1
    end
end

local tempVerts = {}
for faceIndex, _ in pairs(needSmoothFace) do
    local face = trangles[faceIndex]
    local vdx = {face.vdx1, face.vdx2, face.vdx3}
    table.sort(
        vdx,
        function(a, b)
            return a < b
        end
    )
    local info1 = adjacent[vdx[1] .. "_" .. vdx[2]]
    local info2 = adjacent[vdx[1] .. "_" .. vdx[3]]
    local info3 = adjacent[vdx[2] .. "_" .. vdx[3]]

    local idxex = {}
    idxex[1] = faceIndex
    idxex[2] = info1[1] ~= faceIndex and info1[1] or info1[2]
    idxex[3] = info2[1] ~= faceIndex and info2[1] or info2[2]
    idxex[4] = info3[1] ~= faceIndex and info3[1] or info3[2]
    local face1 = trangles[idxex[2]]
    local face2 = trangles[idxex[3]]
    local face3 = trangles[idxex[4]]

    local faces = {face, face1, face2, face3}
    local tempPoints = {vdx1 = {x = 0, y = 0, z = 0}, vdx2 = {x = 0, y = 0, z = 0}, vdx3 = {x = 0, y = 0, z = 0}}
    for i = 1, #faces do
        for j = 1, 3 do
            tempPoints["vdx" .. j].x = tempPoints["vdx" .. j].x + verts[faces[i]["vdx" .. j]].x * weights[idxex[i]]
            tempPoints["vdx" .. j].y = tempPoints["vdx" .. j].y + verts[faces[i]["vdx" .. j]].y * weights[idxex[i]]
            tempPoints["vdx" .. j].z = tempPoints["vdx" .. j].z + verts[faces[i]["vdx" .. j]].z * weights[idxex[i]]
        end
    end
    for j = 1, 3 do
        tempPoints["vdx" .. j].x = tempPoints["vdx" .. j].x / 4
        tempPoints["vdx" .. j].y = tempPoints["vdx" .. j].y / 4
        tempPoints["vdx" .. j].z = tempPoints["vdx" .. j].z / 4
    end

    for i = 1, 3 do
        if not spread then
            tempVerts[face["vdx" .. i]] = {
                x = tempPoints["vdx" .. i].x,
                y = tempPoints["vdx" .. i].y,
                z = tempPoints["vdx" .. i].z
            }
        else
            verts[face["vdx" .. i]] = {
                x = tempPoints["vdx" .. i].x,
                y = tempPoints["vdx" .. i].y,
                z = tempPoints["vdx" .. i].z
            }
        end
    end
end

local output = io.open(outputDir, "w")

local fmt = "v %f %f %f\n"
for i, v in pairs(verts) do
    local temp = tempVerts[i]
    if temp then
        output:write(string.format(fmt, temp.x, temp.y, temp.z))
    else
        output:write(string.format(fmt, v.x, v.y, v.z))
    end
end

local fmt = "f %d %d %d\n"
for i, tran in pairs(trangles) do
    output:write(string.format(fmt, tran.vdx1, tran.vdx2, tran.vdx3))
end
