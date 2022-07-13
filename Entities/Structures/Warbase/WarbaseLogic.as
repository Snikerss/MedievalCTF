#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "MakeSeed.as"
#include "Descriptions.as"
#include "ShopCommon.as"
#include "Requirements.as"
#include "StandardControlsCommon.as"
#include "GenericButtonCommon.as"
#include "TunnelCommon.as"
#include "KnockedCommon.as"
#include "Hasblob.as"
#include "Helpers.as"

const Vec2f upgradeButtonPos(-16.0f, -8.0f);


void InitWorkshop( CBlob@ this )
{
	this.set_Vec2f("shop menu size", Vec2f(5,1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Wood", "$mat_wood$", "mat_wood", "Receive 250 wood for 50 gold", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem(this, "Stone", "$mat_stone$", "mat_stone", "Receive 250 stone for 125 gold", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 125 );
	}
	{
		ShopItem@ s = addShopItem(this, "Stone with Coins", "$mat_stone$", "mat_stone", "Receive 250 stone for 125 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 125 );
	}
	{
		ShopItem@ s = addShopItem(this, "Gold", "$mat_gold$", "mat_gold", "Receive 250 gold for 2000 wood", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 2000 );
	}
	{
		ShopItem@ s = addShopItem(this, "Gold with coins", "$mat_gold$", "mat_gold", "Receive 250 gold for 250 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 250 );
	}
}

void onInit( CBlob@ this )
{
    //workshop
	InitWorkshop(this);

    //spawn
    InitClasses(this);
    this.CreateRespawnPoint( "base", Vec2f(0.0f, -4.0f) );

    //light
    this.SetLight( true );
    this.SetLightRadius( 164.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );
    this.getSprite().getConsts().accurateLighting = true;

    // commands
    this.addCommandID("travel");
	this.addCommandID("travel none");
	this.addCommandID("travel to");
	this.addCommandID("server travel to");
    this.addCommandID("store inventory");
    this.addCommandID("dump mat");
    this.addCommandID("seed menu");
    this.addCommandID("seed bushy");
    this.addCommandID("seed grain");
    this.addCommandID("convert grain");

    // tags
	this.Tag("travel tunnel");
    this.Tag("teamlocked tunnel");
    this.Tag("respawn");

    //icons
	AddIconToken( "$WAR_BASE$", "Rules/WAR/WarGUI.png", Vec2f(48,32), 12 );
    AddIconToken( "$seed$", "Seed.png", Vec2f(8,8), 0 );
	AddIconToken("$TRAVEL_LEFT$", "GUI/MenuItems.png", Vec2f(32, 32), 23);
	AddIconToken("$TRAVEL_RIGHT$", "GUI/MenuItems.png", Vec2f(32, 32), 22);
    AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);


    // buttons
    this.set_Vec2f("change class button pos", Vec2f(-1, 5));
    this.set_Vec2f("travel button pos", Vec2f(-1, -10));
    this.set_Vec2f("upgrade button pos", Vec2f(-16, -8));
    this.set_Vec2f("shop offset", Vec2f(-30, -20));
    this.inventoryButtonPos = Vec2f(25, 10);
    this.set_Vec2f("store inventory button pos", Vec2f(12.5f, -10));

    this.getShape().SetStatic(true);
    this.getShape().getConsts().mapCollisions = false;

    //upgrade
    this.set_string("upgrade_mat", "mat_gold");
    this.set_u8("upgrade_level", 0);
    this.set_u8("old_upgrade_level", 100);
    this.set_u8("old_upgrade_level_sprite", 100);
    this.set_u16("upgrade_1_cost", 100);
    this.set_u16("upgrade_2_cost", 200);

    this.set_u16("food", 0);
    this.set_u16("old_food", -1);
    this.set_s16("food_to_spawn", 1);

    this.set_u16("mat", 0);
    this.set_u16("old mat", 0);
    this.set_s16("mat for upgrade", matForUpgrade( this )); //set up the mat for upgrade property
    this.set_s16("upgrade amount", upgradeAmount( this, this.get_u8("upgrade_level") ));

    this.set_u8("seed pine amount", 0);
    this.set_u8("seed bushy amount", 0);
    this.set_u8("seed grain amount", 0);
    this.set_u8("seed pine max", 3);
    this.set_u8("seed bushy max", 2);
    this.set_u8("seed grain max", 5);
    
    //hp stuff
    u8 default_hp = u8(this.getInitialHealth());
    this.set_u8("max_hp", default_hp);

    // minimap
    this.SetMinimapVars("GUI/Minimap/MinimapWarbase.png", 0, Vec2f(20, 15));
    this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
    this.SetMinimapRenderAlways(true);

    // attachment
    this.getAttachments().getAttachmentPointByName("WORKBENCH").offset = Vec2f(-30, 8);
    this.getAttachments().getAttachmentPointByName("VEHICLEWORKSHOP").offset = Vec2f(-115, 8);

    this.set_bool("isVehicleworkshopAttached", false);

    if(getNet().isServer())
    {
        CBlob@ workbench = server_CreateBlob("workbench", this.getTeamNum(), this.getPosition());
        if (workbench !is null){ this.server_AttachTo(workbench, "WORKBENCH"); }
    }

}

void onTick( CBlob@ this )
{
    const int team = this.getTeamNum();
    this.SetFacingLeft(true);
    const int gametime = getGameTime() + team; //!	
	const int performance_opt = 14;

    if(gametime % performance_opt == 0)
    {
        getMap().server_AddSector(this.getPosition() + Vec2f(-40,16), this.getPosition() - Vec2f(-130,48), "no build", "", this.getNetworkID());
    }

    if ((gametime % performance_opt == 0))
    {
        if (getNet().isServer())
        {
            s16 mat_amount = this.get_u16("mat");
            
            s16 upgrade_1 = this.get_u16("upgrade_1_cost");
            s16 upgrade_2 = this.get_u16("upgrade_2_cost");
            
            u8 old_level = this.get_u8("upgrade_level");
            u8 upgrade_level = (mat_amount >= upgrade_1 + upgrade_2) ? 2 : (mat_amount >= upgrade_1 ? 1 : 0);
            
            
            this.set_u8("old__level", old_level);
            this.set_u8("upgrade_level", upgrade_level);
            this.Sync("upgrade_level", true);
            //accumulate seeds
            u8 seed_count;

            if ( gametime % 128*performance_opt == 0 )
            {
                seed_count = this.get_u8("seed pine amount");

                if (seed_count < this.get_u8("seed pine max")) {
                    this.set_u8("seed pine amount",seed_count+1);
                    this.Sync("seed pine amount", true);
                }
            }

            if ( gametime % 128*performance_opt == 0 )
            {
                seed_count = this.get_u8("seed bushy amount");

                if (seed_count < this.get_u8("seed bushy max")) {
                    this.set_u8("seed bushy amount",seed_count+1);
                    this.Sync("seed bushy amount", true);
                }
            }

            if ( gametime % 86*performance_opt == 0 )
            {
                seed_count = this.get_u8("seed grain amount");

                if (seed_count < this.get_u8("seed grain max") ) {
                    this.set_u8("seed grain amount",seed_count+1);
                    this.Sync("seed grain amount", true);
                }
            }

            this.set_s16("mat for upgrade", matForUpgrade( this )); //set up the mat for upgrade property
            this.set_s16("upgrade amount", upgradeAmount( this, upgrade_level ));

        } // server
		this.set_bool("shop available", this.get_u8("upgrade_level") >= 2);

    }

	if (getNet().isServer())
	{
		if (gametime % 400 == 0)
			PickUpIntoStorage(this);
	}

    if((getNet().isServer()))
    {
        if(this.get_u8("upgrade_level") >= 2 && !this.get_bool("isVehicleworkshopAttached"))
        {
            this.set_bool("isVehicleworkshopAttached", true);

            CBlob@ vehicleworkshop = server_CreateBlob("vehicleworkshop", this.getTeamNum(), this.getPosition());
            if (vehicleworkshop !is null) { this.server_AttachTo(vehicleworkshop, "VEHICLEWORKSHOP"); }
        }
    }

    if (enable_quickswap)
	{
		//quick switch class
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null && blob.isMyPlayer())
		{
			if (
				canChangeClass(this, blob) && blob.getTeamNum() == this.getTeamNum() && //can change class
				blob.isKeyJustReleased(key_use) && //just released e
				isTap(blob, 4) && //tapped e
				blob.getTickSinceCreated() > 1 //prevents infinite loop of swapping class
			) {
				CycleClass(this, blob);
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    if (!canSeeButtons(this, caller)) return;

	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		caller.CreateGenericButton("$change_class$",  this.get_Vec2f("change class button pos"), this, buildSpawnMenu, getTranslatedString("Swap Class"));
	}

    if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{
		CInventory @inv = caller.getInventory();
		if (inv is null) return;

		if (inv.getItemsCount() > 0)
		{
            CBitStream params;
            params.write_u16( caller.getNetworkID() );
			caller.CreateGenericButton("$store_inventory$", this.get_Vec2f("store inventory button pos"), this, this.getCommandID("store inventory"), getTranslatedString("Store"), params);
		}
	}


    if (this.get_u8("upgrade_level") > 0)
    {
        CBitStream params;
        params.write_u16( caller.getNetworkID() );
        caller.CreateGenericButton( "$seed$", Vec2f(-40, 2), this, this.getCommandID("seed menu"), "Seed nursery", params );
	}
	
    if (this.get_u8("upgrade_level") < 2) // upgrade button
    {
        CBitStream params;
        params.write_u16( caller.getNetworkID() );
        CButton@ button = caller.CreateGenericButton( "$" + this.get_string("upgrade_mat") + "$", upgradeButtonPos, this, this.getCommandID("dump mat"), "Use mat to upgrade", params );
        if (button !is null)
        {
            button.deleteAfterClick = false;
            button.SetEnabled( hasBlob( caller, this.get_string("upgrade_mat") ) );
        }
    }

    if (this.get_u8("upgrade_level") >= 2)
    {

    if (!canSeeButtons(this, caller)) return;

	if (this.isOverlapping(caller) &&
	        this.hasTag("travel tunnel") &&
	        (!this.hasTag("teamlocked tunnel") || this.getTeamNum() == caller.getTeamNum()) &&
	        //CANNOT travel when stunned
			!(isKnockable(caller) && isKnocked(caller))
		)
	    {
		    MakeTravelButton(this, caller, this.get_Vec2f("travel button pos"), "Travel", "Travel (requires Transport Tunnels)");
	    }
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    bool isServer = getNet().isServer();
    
    onRespawnCommand( this, cmd, params );
    onTunnelCommand(this, cmd, params);
	
    if(isServer)
    {
        if (cmd == this.getCommandID("store inventory"))
        {
            CBlob@ caller = getBlobByNetworkID(params.read_u16());
            if (caller !is null)
            {
                CInventory @inv = caller.getInventory();
                if (caller.getConfig() == "builder")
                {
                    CBlob@ carried = caller.getCarriedBlob();
                    if (carried !is null)
                    {
                        // TODO: find a better way to check and clear blocks + blob blocks || fix the fundamental problem, blob blocks not double checking requirement prior to placement.
                        if (carried.hasTag("temp blob"))
                        {
                            carried.server_Die();
                        }
                    }
                }
                if (inv !is null)
                {
                    while (inv.getItemsCount() > 0)
                    {
                        CBlob @item = inv.getItem(0);
                        caller.server_PutOutInventory(item);
                        this.server_PutInInventory(item);
                    }
                }
            }
        }
    }

    
    if (cmd == this.getCommandID("dump mat"))
    {
        CBlob@ caller = getBlobByNetworkID( params.read_u16() );
        CInventory@ inv = caller.getInventory();

        if (inv !is null)
        {
            if (isServer)
            {
                PutCarriedInInventory( caller, this.get_string("upgrade_mat") ); // put carried mat in inventory before dumping so its easier to do if you dont have it in inv
                int mat_count = Maths::Min(matTilUpgrade(this),Maths::Min(100,inv.getCount(this.get_string("upgrade_mat"))));

                if (mat_count > 0)
                {
                    inv.server_RemoveItems(this.get_string("upgrade_mat"), mat_count);
                    this.set_u16("mat",this.get_u16("mat")+mat_count);
                    this.Sync("mat", true );
                }
            }

            // disable button if used up mat or upgrade level full
            if (inv.getCount(this.get_string("upgrade_mat")) == 0 || this.get_u8("upgrade_level") >= 2)
            {
                CButton@ button = getHUD().getButtonWithCommandID(cmd);
                
                if (button !is null)
                {
                    button.SetEnabled( false );  // FIXME: this function is broken
                }
            }
	
        }
    }
    else if (cmd == this.getCommandID("seed menu"))
    {
        u16 callerID = params.read_u16();
        CBlob@ caller = getBlobByNetworkID( callerID );

        if (caller !is null && caller.isMyPlayer())
        {
            MakeSeedMenu( this, caller );
        }
    }

    else if (isServer && cmd == this.getCommandID("seed bushy"))
    {
        giveSeedCMD(this, "seed bushy amount", "tree_bushy", 400, 2, 16, params );
    }
    else if (isServer && cmd == this.getCommandID("seed grain"))
    {
        giveSeedCMD(this, "seed grain amount", "grain_plant", 300, 1, 8, params );
    }
    else if (isServer && cmd == this.getCommandID("convert grain"))
    {
        const u16 callerID = params.read_u16();
        CBlob@ caller = getBlobByNetworkID( callerID );
        ConvertGrainIntoSeed( this, caller );
    }
}

bool getTunnelsForButtons(CBlob@ this, CBlob@[]@ tunnels)
{
	CBlob@[] list;
	getBlobsByTag("travel tunnel", @list);
	Vec2f thisPos = this.getPosition();

	// add left tunnels
	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x < thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = 0; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];
				if ((tunnel.getPosition() - thisPos).getLength() < distToBlob)
				{
					tunnels.insert(tunnelInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				tunnels.push_back(blob);
		}
	}

	tunnels.push_back(null);	// add you are here

	// add right tunnels
	const uint tunnelIndStart = tunnels.length;

	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x >= thisPos.x)
		{
			bool added = false;
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = tunnelIndStart; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];
				if ((tunnel.getPosition() - thisPos).getLength() > distToBlob)
				{
					tunnels.insert(tunnelInd, blob);
					added = true;
					break;
				}
			}
			if (!added)
				tunnels.push_back(blob);
		}
	}
	return tunnels.length > 0;
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 1.01f + caller.getRadius());
}

CButton@ MakeTravelButton(CBlob@ this, CBlob@ caller, Vec2f buttonPos, const string &in label, const string &in cantTravelLabel)
{
	CBlob@[] tunnels;
	const bool gotTunnels = getTunnels(this, @tunnels);
	const bool travelAvailable = gotTunnels;
	if (!travelAvailable)
		return null;
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton(8, buttonPos, this, this.getCommandID("travel"), gotTunnels ? getTranslatedString(label) : getTranslatedString(cantTravelLabel), params);
	if (button !is null)
	{
		button.SetEnabled(true);
	}
	return button;
}

void Travel(CBlob@ this, CBlob@ caller, CBlob@ tunnel)
{
	if (caller !is null && tunnel !is null)
	{

		if (caller.isAttached())   // attached - like sitting in cata? move whole cata
		{
			const int count = caller.getAttachmentPointCount();
			for (int i = 0; i < count; i++)
			{
				AttachmentPoint @ap = caller.getAttachmentPoint(i);
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null)
				{
					occBlob.setPosition(tunnel.getPosition());
					occBlob.setVelocity(Vec2f_zero);
					//occBlob.getShape().PutOnGround();
				}
			}
		}
		// move caller
		caller.setPosition(tunnel.getPosition());
		caller.setVelocity(Vec2f_zero);
		//caller.getShape().PutOnGround();

		if (caller.isMyPlayer())
		{
			Sound::Play("Travel.ogg");
		}
		else
		{
			Sound::Play("Travel.ogg", this.getPosition());
			Sound::Play("Travel.ogg", caller.getPosition());
		}

		//stunned on going through tunnel
		//(prevents tunnel spam and ensures traps get you)
		if (isKnockable(caller))
		{
			//if you travel, you lose invincible
			caller.Untag("invincible");
			caller.Sync("invincible", true);

			//actually do the knocking
			setKnocked(caller, 30, true);
		}
	}
}

void onTunnelCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("travel") )
	{
		const u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		CBlob@[] tunnels;
		if (caller !is null && getTunnels(this, @tunnels))
		{
			// instant travel cause there is just one place to go
			if (tunnels.length == 1)
			{
				Travel(this, caller, tunnels[0]);
			}
			else
			{
				if (caller.isMyPlayer())
					BuildTunnelsMenu(this, callerID);
			}
		}
	}
	else if (cmd == this.getCommandID("travel to"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ tunnel = getBlobByNetworkID(params.read_u16());
		if (caller !is null && tunnel !is null
	    && (this.getPosition() - caller.getPosition()).getLength() < (this.getRadius() + caller.getRadius()) * 2.0f)
		{
			if (getNet().isServer())
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				params.write_u16(tunnel.getNetworkID());
				this.SendCommand(this.getCommandID("server travel to"), params);
				Travel(this, caller, tunnel);
			}
		}
		else if (caller !is null && caller.isMyPlayer())
			caller.getSprite().PlaySound("NoAmmo.ogg", 0.5);
	}
	else if (cmd == this.getCommandID("server travel to"))
	{
		if (getNet().isClient())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			CBlob@ tunnel = getBlobByNetworkID(params.read_u16());
			Travel(this, caller, tunnel);
		}
	}
	else if (cmd == this.getCommandID("travel none"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && caller.isMyPlayer())
			getHUD().ClearMenus();
	}
}

void BuildTunnelsMenu(CBlob@ this, const u16 callerID)
{
    const int BUTTON_SIZE = 2;
	CBlob@[] tunnels;
	getTunnelsForButtons(this, @tunnels);

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), this, Vec2f((tunnels.length) * BUTTON_SIZE, BUTTON_SIZE), getTranslatedString("Pick tunnel to travel"));
	if (menu !is null)
	{
		CBitStream exitParams;
		exitParams.write_netid(callerID);
		menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("travel none"), exitParams);
		menu.SetDefaultCommand(this.getCommandID("travel none"), exitParams);

		for (uint i = 0; i < tunnels.length; i++)
		{
			CBlob@ tunnel = tunnels[i];
			if (tunnel is null)
			{
				menu.AddButton("$CANCEL$", getTranslatedString("You are here"), Vec2f(BUTTON_SIZE, BUTTON_SIZE));
			}
			else
			{
				CBitStream params;
				params.write_u16(callerID);
				params.write_u16(tunnel.getNetworkID());
				menu.AddButton(getTravelIcon(this, tunnel), getTranslatedString(getTravelDescription(this, tunnel)), this.getCommandID("travel to"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
			}
		}
	}
}

string getTravelIcon(CBlob@ this, CBlob@ tunnel)
{
	if (tunnel.getName() == "warbase")
		return "$WAR_BASE$";

	if (tunnel.getPosition().x > this.getPosition().x)
		return "$TRAVEL_RIGHT$";

	return "$TRAVEL_LEFT$";
}

string getTravelDescription(CBlob@ this, CBlob@ tunnel)
{
	if (tunnel.getName() == "warbase")
		return "Return to base";

	if (tunnel.getPosition().x > this.getPosition().x)
		return "Travel right";

	return "Travel left";
}

void MakeSeedMenu( CBlob@ this, CBlob@ caller )
{
    if (caller is null) {
        return;
    }

    bool hasGrain = (caller.getInventory().getItem("grain") !is null);
    CGridMenu@ menu = CreateGridMenu( caller.getScreenPos() + Vec2f(0,-50), this, Vec2f( hasGrain ? 3 : 2, 1), "Seed nursery" );

    if (menu !is null)
    {
        CBitStream params;
        params.write_u16( caller.getNetworkID() );

		u8 num;
		num = this.get_u8("seed grain amount");
		{
			CGridButton@ button = menu.AddButton( "$grain$", "Grain Seeds", this.getCommandID("seed grain"), params );

			if (button !is null)
			{
				button.SetNumber(num);
				button.SetEnabled(num > 0);
			}
		}
        num = this.get_u8("seed bushy amount");
        {
            CGridButton@ button = menu.AddButton( "$tree_pine$", "Pine Tree Seeds", this.getCommandID("seed bushy"), params );

            if (button !is null)
            {
                button.SetNumber(num);
                button.SetEnabled(num > 0);
            }
        }

        // make seeds from grain

        if (hasGrain)
        {
            CGridButton@ button = menu.AddButton( "$grain$", "Make seeds from grain", this.getCommandID("convert grain"), params );
        }
    }
}

void giveSeedCMD(CBlob@ this, string propertyName, string blobName, int growtime, u8 spriteIndex, u8 radius, CBitStream@ params )
{
    u8 seed_count = this.get_u8(propertyName);

    if (seed_count > 0)
    {
        u16 callerID = params.read_u16();
        CBlob@ caller = getBlobByNetworkID( callerID );
        CInventory@ inv = caller.getInventory();

        if (inv !is null)
        {
            CBlob@ seed = server_MakeSeed( caller.getPosition(), blobName, growtime, spriteIndex, radius );

            if (seed !is null)
            {
                this.set_u8( propertyName, seed_count - 1 );
                this.Sync( propertyName, true );

                if(caller.getCarriedBlob() is null) {
                    caller.server_Pickup(seed);
                }
                else {
                    caller.server_PutInInventory(seed);
                }
            }
        }
    }
}

void ConvertGrainIntoSeed( CBlob@ this, CBlob@ caller )
{
    if (caller is null) {
        return;
    }

    CInventory@ inv = caller.getInventory();
    CBlob@ grainBlob = inv.getItem("grain");

    while (grainBlob !is null)
    {
        u8 amount = this.get_u8("seed grain amount");
        this.set_u8("seed grain amount", amount + 5);
        caller.server_PutOutInventory( grainBlob );
        grainBlob.server_Die();
        @grainBlob = inv.getItem("grain");
    }

    this.Sync("seed grain amount", true);
}

void PickUpIntoStorage( CBlob@ this )
{
	CBlob@[] blobsInRadius;	   
	CMap@ map = this.getMap();
	if (map.getBlobsInRadius( this.getPosition(), this.getRadius()*2.4f, @blobsInRadius )) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			const string name = b.getName();
			if (b !is this && !b.isInInventory() && !b.isAttached() && b.isOnGround()
				&& (b.hasTag("material") /*|| b.hasTag("food")*/ || name == "grain")
				&& !map.rayCastSolid(this.getPosition(), b.getPosition()))
			{
				this.server_PutInInventory(b);
			}
		}
	}
}

void PutCarriedInInventory( CBlob@ this, const string& in carriedName )
{
    CBlob@ handsBlob = this.getCarriedBlob();

    if (handsBlob !is null && handsBlob.getName() == carriedName) {
        this.server_PutInInventory(handsBlob);
    }
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	this.getSprite().PlaySound("/BaseTake");
}