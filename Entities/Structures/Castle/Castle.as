void onInit(CBlob@ this)
{
    this.getSprite().SetZ(-50.0f);
    this.Tag("builder always hit");
    this.getShape().getConsts().mapCollisions = false;
    
    this.set_TileType("background tile", CMap::tile_castle_back);
}

void onTick(CBlob@ this)
{
    if (this.getTickSinceCreated() == 1)
	{
		Vec2f tilepos = this.getPosition() + Vec2f(-4, 0);
		getMap().server_SetTile(tilepos, CMap::tile_castle_back);
	}
}