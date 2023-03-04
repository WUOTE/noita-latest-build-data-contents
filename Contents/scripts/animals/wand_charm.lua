dofile_once("data/scripts/lib/utilities.lua")

function wand_has_any_cards_in_it( wand_entity )

	local c = EntityGetAllChildren( wand_entity )

	if ( c ~= nil ) then
		for a,b in ipairs( c ) do
			local comp = EntityGetFirstComponentIncludingDisabled( b, "ItemActionComponent" )
			if ( comp ~= nil ) then
				return true
			end
		end
	end

	return false
end

----

function material_area_checker_success( pos_x, pos_y )
	-- print("wand charm")
	
	local entity_pick_up_this_item = GetUpdatedEntityID()

	-- convert empty wand to a golden wand nugget 
	-- this may bug out, but we can test it during the weekend
	if( EntityHasTag( entity_pick_up_this_item, "wand" ) and wand_has_any_cards_in_it( entity_pick_up_this_item ) == false ) then
		local entity_id = GetUpdatedEntityID()
		local x, y = EntityGetTransform( entity_id )

		shoot_projectile( entity_pick_up_this_item, "data/entities/particles/gold_pickup_large.xml", x, y, 0, 0 )

		for i=1,4 do
			EntityLoad( "data/entities/items/pickup/goldnugget_200.xml", x, y )
		end

		EntityKill( entity_id )
		return
	end

	local has_sampo = false

	if( EntityHasTag( entity_pick_up_this_item, "this_is_sampo" ) ) then
		EntityAddTag( entity_ghost, "this_is_sampo" )
		-- remove CameraBoundComponent
		has_sampo = true
	end

	local entity_ghost = 0
	if( has_sampo ) then
		entity_ghost = EntityLoad( "data/entities/animals/wand_ghost_with_sampo.xml", pos_x, pos_y )
	else
		entity_ghost = EntityLoad( "data/entities/animals/wand_ghost_charmed.xml", pos_x, pos_y )
	end

	-- make pick up only this item - via ItemPickUpperComponent::only_pick_this_entity

	local itempickup = EntityGetFirstComponent( entity_ghost, "ItemPickUpperComponent" )
	if( itempickup ) then
		ComponentSetValue2( itempickup, "only_pick_this_entity", entity_pick_up_this_item )
		GamePickUpInventoryItem( entity_ghost, entity_pick_up_this_item, false )
		-- print( "called item pick up ")
	end

	-- check that we hold the item
	local items = GameGetAllInventoryItems( entity_ghost )
	local has_item = false
	
	if( items ~= nil ) then
		for i,v in ipairs(items) do
			if( v == entity_pick_up_this_item ) then
				has_item = true
			end
		end
	end

	-- if we don't have the item kill us for we are too dangerous to be left alive
	if( has_item == false ) then
		EntityKill( entity_ghost )
	end
end

