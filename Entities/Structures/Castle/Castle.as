const string target_player_id = "target_player_id";

void onInit(CBlob@ this)
{
    this.getSprite().SetZ(-50.0f);
    this.getShape().getConsts().mapCollisions = false;
    
    this.set_TileType("background tile", CMap::tile_empty);

    this.addCommandID("shoot");

    this.set_bool("spawned", false);
	this.set_u16(target_player_id, 0);
    this.set_bool("spawned", false);
    this.Tag("builder always hit");

    this.SetLight(true);
	this.SetLightRadius(164.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
}

void onTick(CBlob@ this)
{
    if (this.getTickSinceCreated() >= 1 && this.getTickSinceCreated() <= 10)
	{
		Vec2f tilepos = this.getPosition() + Vec2f(-4, 0);
		getMap().server_SetTile(tilepos, CMap::tile_castle_back);
	}

    u16 target = this.get_u16(target_player_id);
    CBlob@ targetBlob = getBlobByNetworkID(target);

    this.getCurrentScript().tickFrequency = 12;

    if(target == 0)
    {
        @targetBlob = getNewTarget(this, true, true);
        if(targetBlob !is null)
        {
            this.set_u16(target_player_id, targetBlob.getNetworkID());
            this.Sync(target_player_id, true);
        }
    }
    else
    {
        if(targetBlob !is null)
        {
            this.getCurrentScript().tickFrequency = 1;

            f32 distance;
            f32 shootDistance = 512.0f;
            const bool visibleTarget = isVisible(this, targetBlob, distance);
            u32 gameTime = getGameTime();
            if(visibleTarget && distance < shootDistance)
            {
                if (this.get_u32("next shot") < gameTime)
                {
                    this.SendCommand(this.getCommandID("shoot"));
                    this.set_bool("spawned", false);

                    this.set_u32("next shot", gameTime + 30);
                }
            }

            if (LoseTarget(this, targetBlob))
			{
				this.set_u16(target_player_id, 0);
				this.Sync(target_player_id, true);
			}
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if(cmd == this.getCommandID("shoot"))
    {
        if(getNet().isServer())
        {
            if(!this.get_bool("spawned"))
            {
                for(int i = 0; i<5; i++)
                {
                    CBlob@ arrow = server_CreateBlobNoInit("arrow");

                    if(arrow !is null)
                    {
                        arrow.Init();

                        arrow.IgnoreCollisionWhileOverlapped(this);
                        arrow.server_setTeamNum(this.getTeamNum());

                        Vec2f pos = this.getPosition()- Vec2f(0.0f, 32.0f) + Vec2f(XORRandom(4096) / 64.0f, XORRandom(4096) / 64.0f);
                        arrow.setPosition(pos);

                        f32 angle = getAimAngle(this);
                        angle += ((XORRandom(512) - 256) / 132.0f);
                        Vec2f vel = Vec2f(25.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
                        arrow.setVelocity(vel);
                        arrow.server_SetTimeToDie(2.0f);
                    }
                }
                this.set_bool("spawned", true);
            }
        }
    }
}

bool LoseTarget(CBlob@ this, CBlob@ targetblob)
{
	if ((getGameTime() % 10 == 0) && targetblob.hasTag("dead"))
	{
		this.set_u16(target_player_id, 0);
		this.Sync(target_player_id, true);

		return true;
	}
	return false;
}

CBlob@ getNewTarget(CBlob @blob, const bool seeThroughWalls = false, const bool seeBehindBack = false)
{
	CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = blob.getPosition();
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		Vec2f pos2 = potential.getPosition();
		f32 distance;
		if (potential !is blob && blob.getTeamNum() != potential.getTeamNum()
		        && (pos2 - pos).getLength() < 700.0f
		        && !potential.hasTag("dead")
		        && (XORRandom(200) == 0 || isVisible(blob, potential, distance))
		   )
		{
			blob.set_Vec2f("last pathing pos", potential.getPosition());
			return potential;
		}
	}
	return null;
}

bool isVisible(CBlob@ blob, CBlob@ targetblob, f32 &out distance)
{
	Vec2f col;
	bool visible = !getMap().rayCastSolid(blob.getPosition(), targetblob.getPosition() + targetblob.getVelocity() * 2.0f, col);
	distance = (blob.getPosition() - col).getLength();
	return visible;
}

f32 getAimAngle(CBlob@ this)
{
	CBlob@ targetblob = getBlobByNetworkID(this.get_u16(target_player_id)); //target's blob

	f32 angle = 0;
	bool facing_left = this.isFacingLeft();

	bool failed = true;

	if (targetblob !is null)
	{
		Vec2f aim_vec = (this.getPosition() - Vec2f(0.0f, 10.0f)) - (targetblob.getPosition() + Vec2f(0.0f, -4.0f) + targetblob.getVelocity() * 2.0f);

		if ((!facing_left && aim_vec.x < 0) ||
		        (facing_left && aim_vec.x > 0))
		{

			angle = (-(aim_vec).getAngle() + 180.0f);
			if (facing_left)
			{
				angle += 180;
			}
		}
		else
		{
			this.SetFacingLeft(!facing_left);
		}
	}

	return angle;
}