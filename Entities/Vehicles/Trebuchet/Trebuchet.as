#include "VehicleCommon.as"
#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "GenericButtonCommon.as"
#include "Costs.as"

// Trebuchet logic

const u8 cooldown_time = 120;
const u8 charge_time = 120;
const f32 launch_power = 1.5f; // 1 = catapult

void onInit(CBlob@ this)
{
	this.set_s32("gold building amount", 100);

	AddIconToken("$Trebuchet_Shell$", "Trebuchetshell.png", Vec2f(16, 16), 0);

	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.0f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	
	Vehicle_AddAmmo(this, v,
	                    cooldown_time, // fire delay (ticks)
	                    1, // fire bullets amount
	                    1, // fire cost
	                    "mat_trebuchetshells", // bullet ammo config name
	                    "Explosive Shells", // name for ammo selection
	                    "trebuchet_shell", // bullet config name
	                    "CatapultFire", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vehicle_Fire_Style::custom,
	                    Vec2f(-6.0f, -8.0f), // fire position offset
	                    charge_time // charge time
	                   );


	this.getShape().SetOffset(Vec2f(0, -1));

	Vehicle_SetWeaponAngle(this, getAngle(this, v), v);

	string[] autograb_blobs = {"mat_trebuchetshells"};
	this.set("autograb blobs", autograb_blobs);

	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_trebuchetshells");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 16));
	this.SetMinimapRenderAlways(false);
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

		if (v.cooldown_time > 0)
		{
			v.cooldown_time--;
		}

		Vehicle_SetWeaponAngle(this, getAngle(this, v), v);

	}

}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();

	if (this.isAnimationEnded() && this.isAnimation("fire"))
	{
		blob.Tag("recharge");
	}
	else if (this.isAnimationEnded() && this.isAnimation("recharge"))
	{
		blob.Tag("default");
	}

    if (blob.hasTag("fire"))
    {
        blob.Untag("fire");
        this.SetAnimation("fire");
	}

	if (blob.hasTag("recharge"))
	{
		blob.Untag("recharge");
		this.SetAnimation("recharge");
	}

	if (blob.hasTag("default"))
	{
		blob.Untag("default");
		this.SetAnimation("default");
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (isOverlapping(this, caller) && !caller.isAttached())
	{
		if (caller.getTeamNum() == this.getTeamNum())
		{
			Vehicle_AddLoadAmmoButton(this, caller);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire blob"))
	{
		this.Tag("fire");
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		const u8 charge = params.read_u8();
		
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		
		// check for valid ammo
		if (blob.getName() != v.getCurrentAmmo().bullet_name){
			// output warning
			warn("Attempted to launch invalid object!");
			return;
		}
		
		Vehicle_onFire(this, v, blob, charge);
		Sound::Play("/CatapultFire.ogg", this.getPosition(), 1.00f, 1.00f);
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue)
{
	v.firing = v.firing || isActionPressed;

	bool hasammo = v.getCurrentAmmo().loaded_ammo > 0;

	u8 charge = v.charge;
	if ((charge > 0 || isActionPressed) && hasammo)
	{
		if (charge < v.getCurrentAmmo().max_charge_time && isActionPressed)
		{
			charge++;
			v.charge = charge;

			u8 t = Maths::Round(float(v.getCurrentAmmo().max_charge_time) * 0.66f);
			if ((charge < t && charge % 10 == 0) || (charge >= t && charge % 5 == 0))
				this.getSprite().PlaySound("/LoadingTick");

			chargeValue = charge;
			return false;
		}
		chargeValue = charge;
		return true;
	}

	return false;
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge)
{
	if (bullet !is null)
	{
		bool facing_left = this.isFacingLeft();
		u8 charge_prop = _charge;
		f32 spreading = facing_left ? -(XORRandom(10) - 5)*(charge_prop/100) : (XORRandom(20) - 10)*(charge_prop/100);

		f32 charge = 5.0f + 15.0f * (float(charge_prop) / float(v.getCurrentAmmo().max_charge_time));

		Vec2f vel = Vec2f(spreading, -charge*launch_power).RotateBy(getAngle(this, v));
		bullet.setVelocity(vel);

		bullet.setPosition(bullet.getPosition() + vel + Vec2f(facing_left ? 30.0f : -30.0f, -90.0f).RotateBy(this.getAngleDegrees()));
	}

	v.last_charge = _charge;
	v.charge = 0;
	v.cooldown_time = v.getCurrentAmmo().fire_delay;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
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

bool isAnotherRespawnClose(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is this && b.hasTag("respawn") && b.getNetworkID() < this.getNetworkID())
			{
				return true;
			}
		}
	}
	return false;
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

f32 getAngle(CBlob@ this, VehicleInfo@ v)
{

	bool facing_left = this.isFacingLeft();
	f32 angle = facing_left ? this.getAngleDegrees() - 70.0f : this.getAngleDegrees() + 70.0f;

	return angle;
}