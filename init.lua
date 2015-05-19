--
-- Generate flying islands
--


local mh = worldedit.manip_helpers


--- worldedit.sphere modified
local function create_sphere(pos, radius, hollow)
	local manip, area = mh.init_radius(pos, radius)

	local data = mh.get_empty_data(area)

	-- Fill selected area with node
	local dirt_id = minetest.get_content_id("default:dirt")
	local stone_id = minetest.get_content_id("default:stone")
	local coal_id = minetest.get_content_id("default:stone_with_coal")
	local iron_id = minetest.get_content_id("default:stone_with_iron")
	local water_id = minetest.get_content_id("default:water_source")
	local min_radius, max_radius = radius * (radius - 1), radius * (radius + 1)
	local offset_x, offset_y, offset_z = pos.x - area.MinEdge.x, pos.y - area.MinEdge.y, pos.z - area.MinEdge.z
	local stride_z, stride_y = area.zstride, area.ystride
	local count = 0
	for z = -radius, radius do
		-- Offset contributed by z plus 1 to make it 1-indexed
		local new_z = (z + offset_z) * stride_z + 1
		for y = -radius, radius do
			local new_y = new_z + (y + offset_y) * stride_y
			for x = -radius, radius do
				local squared = x * x + y * y + z * z
				if squared <= max_radius and (not hollow or squared >= min_radius) then
					-- Position is on surface of sphere
					local i = new_y + (x + offset_x)
					
					local random_node = math.random(0,40)
					-- Insert ores
					if random_node <= 10 then
						data[i] = stone_id
					elseif random_node > 10 and random_node <= 15 then
						data[i] = coal_id
					elseif random_node == 16 then
						data[i] = iron_id
					else
						data[i] = dirt_id
					end
					count = count + 1
				end
			end
		end
	end

	mh.finish(manip, data)

	return count
end

-- facedir: 0/1/2/3 (head node facedir value)
local function make_island(pos, facedir, length)
	-- Make the island itself
	local radius = math.random(1,30)-- Set to change max and min radis : radius = math.random(<min_radius>,<max_radius>)
	print("create sphere")
	create_sphere(pos, radius, false)
	worldedit.dome(pos, radius, "air", false)
	
	-- Add trees
	for l1 = -(radius/2), radius/2 do
		for l2 = -(radius/2), radius/2 do
			if math.random(0,20) == 0 then
				default.grow_tree({x=pos.x+l1, y=pos.y, z=pos.z+l2}, math.random(0,1))
			end
		end
	end
end


local function generate_island(minp, maxp, seed)
	local height_min = -50000
	local height_max = 50000
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed+500)
	local max_num_islands = math.floor(volume / (16*16*16))
	for i=1,max_num_islands do
		if pr:next(0, 750) == 0 then
			local x0 = pr:next(minp.x, maxp.x)
			local y0 = pr:next(minp.y, maxp.y)
			local z0 = pr:next(minp.z, maxp.z)
			local p0 = {x=x0, y=y0, z=z0}
			make_island(p0, pr:next(0,3), pr:next(3,15))
		end
	end
end


minetest.register_on_generated(generate_island)
