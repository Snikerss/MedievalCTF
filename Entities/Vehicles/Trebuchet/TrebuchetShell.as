#include "Hitters.as"
#include "Explosion.as"

const u32 timer_max = 10000;

void onInit(CBlob@ this)
{
    this.set_f32("map_damage_radius", 16.0f);
    this.set_f32("map_damage_ratio", 160.0f);
	
	this.set_string("custom_explosion_sound", "Keg.ogg");

    this.set_u32("timer", 0);

    this.getShape().SetRotationsAllowed(true);

    this.set_u32("timer", getGameTime() + timer_max + XORRandom(15));

    this.Tag("projectile");
}

void onTick(CBlob@ this)
{
    if (getGameTime() > this.get_u32("timer"))
    {
        this.server_Die();
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (this.getTickSinceCreated() > 5 && (solid ? true : (blob !is null && blob.isCollidable())))
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	Explode(this, this.get_f32("map_damage_radius"), this.get_f32("map_damage_ratio"));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}