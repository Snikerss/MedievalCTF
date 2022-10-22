#include "VehicleCommon.as"

void onInit(CBlob@ this)
{
    Vehicle_Setup(this,
	              60.0f, // move speed
	              0.31f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );

	

	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
        return;

    Vehicle_AddAmmo(this, v,    
	                    0, // fire delay (ticks)
	                    0, // fire bullets amount
	                    0, // fire cost
	                    "", // bullet ammo config name
	                    "", // name for ammo selection
	                    "", // bullet config name
	                    "", // fire sound
	                    "", // empty fire sound
	                    Vehicle_Fire_Style::custom,
	                    Vec2f(0.0f, 0.0f), // fire position offset
	                    0 // charge time
	                   );

    Vehicle_SetupGroundSound(this, v, "WoodenWheelsRolling",  // movement sound
	                         1.0f, // movement sound volume modifier   0.0f = no manipulation
	                         1.0f // movement sound pitch modifier     0.0f = no manipulation
	                        );

	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(25.0f, 10.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(14.0f, 10.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(3.0f, 10.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-8.0f, 10.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-20.0f, 10.0f)); if (w !is null) w.SetRelativeZ(10.0f); }

	this.set_f32("map dmg modifier", 50.0f);

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 70, 32);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(55.0f);
		front.SetOffset(Vec2f(-7, -4));
	}
}

void onTick(CBlob@ this)
{
    if (this.hasAttached() || this.getTickSinceCreated() < 30)
    {
        VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
        Vehicle_StandardControls(this, v);
    }

}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge){}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue){return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    if((this.getTeamNum() == blob.getTeamNum()) && ((blob.getControls() !is null || blob.hasTag("player")) && (blob.getBrain() !is null)))
	    return false;
    else
        return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	attachedPoint.offsetZ = 1.0f;
	Vehicle_onAttach(this, v, attached, attachedPoint);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onDetach(this, v, detached, attachedPoint);
}

// Blame Fuzzle.
bool isOverlapping(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}
