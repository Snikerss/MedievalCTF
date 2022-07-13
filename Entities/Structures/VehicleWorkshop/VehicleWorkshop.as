#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "TeamIconToken.as"
#include "Requirements_Tech.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	InitWorkshop(this);
}

void InitWorkshop(CBlob@ this)
{
    InitCosts(); //read from cfg

	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(8, 8));

    this.set_string("shop description", "Construct");

    int team_num = this.getTeamNum();

	////////////////////////////////////////////////////////	Vehicles	//////////////////////////////////////////////////
    {
		string cata_icon = getTeamIcon("catapult", "VehicleIcons.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "Catapult", cata_icon, "catapult", cata_icon + "\n\n\n" + Descriptions::catapult, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::catapult);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	{
		string ballista_icon = getTeamIcon("ballista", "VehicleIcons.png", team_num, Vec2f(32, 32), 1);
		ShopItem@ s = addShopItem(this, "Ballista", ballista_icon, "ballista", ballista_icon + "\n\n\n" + Descriptions::ballista, false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::ballista);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::ballista_gold);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
	}
	{
		string longboat_icon = getTeamIcon("longboat", "VehicleIcons.png", team_num, Vec2f(32, 32), 4);
		ShopItem@ s = addShopItem(this, "Longboat", longboat_icon, "longboat", longboat_icon + "\n\n\n" + Descriptions::longboat, false, true);
		s.crate_icon = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::longboat);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::longboat_wood);
	}
	{
		string warboat_icon = getTeamIcon("warboat", "VehicleIcons.png", team_num, Vec2f(32, 32), 2);
		ShopItem@ s = addShopItem(this, "War Boat", warboat_icon, "warboat", warboat_icon + "\n\n\n" + Descriptions::warboat, false, true);
		s.crate_icon = 2;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::warboat);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::warboat_gold);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
	}
	{
		string trebuchet_icon = getTeamIcon("trebuchet", "TrebuchetIcon.png", team_num, Vec2f(63, 83), 0);
		ShopItem@ s = addShopItem(this, "Trebuchet", trebuchet_icon, "trebuchet", trebuchet_icon + "\n\n\n\n\n\n\n\n\n\n" + "Type of catapult that uses a long arm to throw a projectile. Shoots far and hurts, you can pick it up", false, true);
		s.crate_icon = 4;
		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", 300);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 1000);
	}
	{
		string cannon_icon = getTeamIcon("cannon", "CannonIcon.png", team_num, Vec2f(24, 12), 0);
		ShopItem@ s = addShopItem(this, "Cannon", cannon_icon, "cannon", cannon_icon + "\n\n\n" + "Powerful weapon with long recharging, be careful with it", false, true);
		s.crate_icon = 4;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	////////////////////////////////////////////////////////////	Ammo	/////////////////////////////////////////////////////////////////////////
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + Descriptions::ballista_ammo, false, false);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::ballista_ammo);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Shells", "$mat_bomb_bolts$", "mat_bomb_bolts", "$mat_bomb_bolts$\n\n\n" + Descriptions::ballista_bomb_ammo, false, false);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::ballista_bomb_ammo);
	}
	{
		string mat_trebuchet_shells_icon = getTeamIcon("mat_trebuchetshells", "MaterialTrebuchetShells.png", team_num, Vec2f(16, 16), 3);
		ShopItem@ s = addShopItem(this, "Trebuchet Shells", mat_trebuchet_shells_icon, "mat_trebuchetshells", mat_trebuchet_shells_icon + "\n\n\n" + "Trebuchet ammo, strong enough to destroy enemy face and base");
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		string mat_cannonball_icon = getTeamIcon("mat_cannonball", "MaterialCannonball.png", team_num, Vec2f(16, 16), 0);
		ShopItem@ s = addShopItem(this, "Cannonball", mat_cannonball_icon, "mat_cannonball", mat_cannonball_icon + "\n\n\n" + "Cannon ammo, dont explode on your own base");
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop buy"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		bool spawnToInventory = params.read_bool();
		bool spawnInCrate = params.read_bool();
		bool producing = params.read_bool();
		string blobName = params.read_string();
		u8 s_index = params.read_u8();

		{
			this.getSprite().PlaySound("/ConstructShort");
		}
	}
}