const string target_player_id = "target_player_id";

void onInit(CBlob@ this)
{
    this.getSprite().SetZ(-50.0f);
    this.getShape().getConsts().mapCollisions = false;
    
    this.set_TileType("background tile", CMap::tile_castle_back);

    this.addCommandID("shoot");

	this.set_u16(target_player_id, 0);
    this.set_bool("spawned", false);
    this.Tag("builder always hit");

    this.SetLight(true);
	this.SetLightRadius(164.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

    this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("MinimapCastle.png", 0, Vec2f(14, 12));
	this.SetMinimapRenderAlways(true);
}

void onTick(CBlob@ this)
{
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
    else if (targetBlob !is null)
    {
            this.getCurrentScript().tickFrequency = 1;

            f32 targetDistance;
            f32 shootDistance = 512.0f;
            const bool visibleTarget = isVisible(this, targetBlob, targetDistance);
            u32 gameTime = getGameTime();
            if(visibleTarget && targetDistance < shootDistance)
            {
                if (this.get_u32("next shot") < gameTime)
                {
                    this.SendCommand(this.getCommandID("shoot"));
                    this.set_bool("spawned", false);

                    this.set_u32("next shot", gameTime + 30);
                }
            }

            if (targetBlob.hasTag("dead") || !visibleTarget)
			{
				this.set_u16(target_player_id, 0);
				this.Sync(target_player_id, true);
			}
        else
        {
            this.set_u16(target_player_id, 0);
			this.Sync(target_player_id, true);
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
                        Vec2f vel = Vec2f(23.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
                        arrow.setVelocity(vel);
                        arrow.server_SetTimeToDie(2.0f);
                    }
                }
                this.set_bool("spawned", true);
            }
        }
    }
}

CBlob@ getNewTarget(CBlob @blob, const bool seeThroughWalls = false, const bool seeBehindBack = false)
{
	CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = blob.getPosition();

	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ target = players[i];
		Vec2f pos2 = target.getPosition();
		f32 distance;

		if (target !is blob && blob.getTeamNum() != target.getTeamNum()
		        && (pos2 - pos).getLength() < 700.0f
		        && !target.hasTag("dead")
		        && isVisible(blob, target, distance))
		{
			blob.set_Vec2f("last pathing pos", target.getPosition());
			return target;
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

    Vec2f aim_vec = (this.getPosition() - Vec2f(0.0f, 10.0f)) - (targetblob.getPosition() + Vec2f(0.0f, -4.0f) + targetblob.getVelocity() * 2.0f);;
    f32 angle = (-(aim_vec).getAngle() + 180.0f);

	return angle;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    if((this.getTeamNum() == blob.getTeamNum()))
	    return false;
    else
        return true;
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}