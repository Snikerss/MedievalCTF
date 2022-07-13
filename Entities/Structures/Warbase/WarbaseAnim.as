#include "Helpers.as"

const Vec2f upgradeButtonPos(-16.0f, -8.0f);

void onInit( CSprite@ this )
{
    this.SetZ( -50.0f ); // push to background
    CBlob@ warbase = this.getBlob();
    const string filename = CFileMatcher("/WARbase.png").getFirst();
    const int warbase_team = warbase.getTeamNum();
    const int warbase_skin = warbase.getSkinNum();
    //upgrade sprites
	Vec2f tunnel_offset(3,4);
    Vec2f table_offset(32,4);
    {
		
		
		CSpriteLayer@ tunnel = this.addSpriteLayer( "tunnel", filename , 24, 24, warbase_team, warbase_skin );

	
        if (tunnel !is null)
        {
            Animation@ anim = tunnel.addAnimation( "default", 0, true );
            anim.AddFrame(49);
            
            tunnel.SetOffset( tunnel_offset );
            tunnel.SetVisible(false);
        }
	
        CSpriteLayer@ upgrade_table = this.addSpriteLayer( "upgrade_table", filename , 24, 24, warbase_team, warbase_skin );

        if (upgrade_table !is null)
        {
            Animation@ anim = upgrade_table.addAnimation( "default", 0, false );
            anim.AddFrame(38);
            anim.AddFrame(39);
            anim.AddFrame(48);
            
            upgrade_table.SetVisible(true);
            
            upgrade_table.SetOffset( table_offset );
        }
	}
    //tower sprites
    {
        CSpriteLayer@ tower_cap = this.addSpriteLayer( "tower_cap", filename , 32, 32, warbase_team, warbase_skin );

        if (tower_cap !is null)
        {
            Animation@ anim = tower_cap.addAnimation( "default", 0, false );
            anim.AddFrame(16);
            anim.AddFrame(24);
        }

        CSpriteLayer@ tower = this.addSpriteLayer( "tower", filename , 32, 32, warbase_team, warbase_skin );

        if (tower !is null)
        {
            Animation@ anim = tower.addAnimation( "default", 0, false );
            anim.AddFrame(17);
            anim.AddFrame(18);
            anim.AddFrame(25);
            anim.AddFrame(26);
            tower.SetVisible(false);
        }

        CSpriteLayer@ tower_flagpole = this.addSpriteLayer( "tower_flagpole", "Entities/Special/flag.png" , 16, 32, warbase_team, warbase_skin );

        if (tower_flagpole !is null)
        {
            Animation@ anim = tower_flagpole.addAnimation( "default", 0, false );
            anim.AddFrame(3);
        }

        CSpriteLayer@ tower_flag = this.addSpriteLayer( "tower_flag", "Entities/Special/flag.png" , 32, 16, warbase_team, warbase_skin );

        if (tower_flag !is null)
        {
            Animation@ anim = tower_flag.addAnimation( "default", 3, true );
            anim.AddFrame(0);
            anim.AddFrame(2);
            anim.AddFrame(4);
            anim.AddFrame(6);
        }
    }
    //food sprites
    {
        Vec2f food_offset = Vec2f(0,0);
        CSpriteLayer@ food1 = this.addSpriteLayer( "food1", filename , 32, 16, warbase_team, warbase_skin );

        if (food1 !is null)
        {
            Animation@ anim = food1.addAnimation( "default", 0, false );
            anim.AddFrame(24);
            food1.SetVisible(false);
            food1.SetOffset( food_offset + Vec2f(7.0f,6.0f) );
        }

        CSpriteLayer@ food2 = this.addSpriteLayer( "food2", filename , 32, 16, warbase_team, warbase_skin );

        if (food2 !is null)
        {
            food2.SetOffset( food_offset + Vec2f(5.0f,14.0f) );
            Animation@ anim = food2.addAnimation( "default", 0, false );
            anim.AddFrame(25);
            food2.SetVisible(false);
        }

        CSpriteLayer@ food3 = this.addSpriteLayer( "food3", filename , 16, 16, warbase_team, warbase_skin );

        if (food3 !is null)
        {
            Animation@ anim = food3.addAnimation( "default", 0, false );
            anim.AddFrame(52);
            food3.SetVisible(false);
            food3.SetOffset( food_offset + Vec2f(0.0f,-7.0f) );
        }
    }
    //barracks sprites
    {
        Vec2f barracks_offset = Vec2f(88,-8);
        CSpriteLayer@ barracks_unbuilt = this.addSpriteLayer( "barracks_unbuilt", filename , 96, 16, warbase_team, warbase_skin );

        if (barracks_unbuilt !is null)
        {
            Animation@ anim = barracks_unbuilt.addAnimation( "default", 0, false );
            anim.AddFrame(13);
            barracks_unbuilt.SetVisible(true);
            barracks_unbuilt.SetOffset( barracks_offset + Vec2f(0.0f, 16.0f) );
            barracks_unbuilt.SetRelativeZ(-50.0);
        }

        CSpriteLayer@ barracks = this.addSpriteLayer( "barracks", filename , 96, 48, warbase_team, warbase_skin );

        if (barracks !is null)
        {
            Animation@ anim = barracks.addAnimation( "default", 0, false );
            anim.AddFrame(1);
            barracks.SetVisible(false);
            barracks.SetOffset( barracks_offset + Vec2f(0.0f, 0.0f) );
            barracks.SetRelativeZ(-50.0);
        }

        CSpriteLayer@ barracks_weapons = this.addSpriteLayer( "barracks_weapons", filename, 32, 32, warbase_team, warbase_skin );

        if (barracks_weapons !is null)
        {
            Animation@ anim = barracks_weapons.addAnimation( "default", 0, false );
            anim.AddFrame(6);
            barracks_weapons.SetVisible(false);
            barracks_weapons.SetOffset( barracks_offset + Vec2f(-3.0f, 9.0f) );
            barracks_weapons.SetRelativeZ(-50.0);
        }

        CSpriteLayer@ barracks_bench = this.addSpriteLayer( "barracks_bench", filename , 32, 32, warbase_team, warbase_skin );

        if (barracks_bench !is null)
        {
            Animation@ anim = barracks_bench.addAnimation( "default", 0, false );
            anim.AddFrame(14);
            barracks_bench.SetVisible(false);
            barracks_bench.SetOffset( Vec2f(115.0f, 0.0f));
            barracks_bench.SetRelativeZ(1.0);
        }
    }
    warbase.set_u8("old_upgrade_level", 100); //hack, makes client sync frames
    onTick( this ); //update to get offsets etc working
}

void onTick( CSprite@ this )
{
    //tower anim

    if ((getGameTime()) % 10 == 0)
    {
        CBlob@ warbase = this.getBlob();
        u8 old_upgrade_level = warbase.get_u8("old_upgrade_level_sprite");
        u8 upgrade_level = warbase.get_u8("upgrade_level");

        if (upgrade_level != old_upgrade_level)
        {
            warbase.set_u8("old_upgrade_level_sprite", upgrade_level);
            SetupLayers( this, upgrade_level, false );
        }
        else
        {
            f32 health = warbase.getHealth();
            f32 oldhealth = warbase.get_f32("warbase old health"); //prevent potential collisions
            f32 defaulthp = warbase.getInitialHealth();

            if (health != oldhealth)
            {
                if (health < defaulthp * 0.6f)
                {
                    SetupLayers( this, upgrade_level, true );
                }
                else
                {
                    SetupLayers( this, upgrade_level, false );
                }

                warbase.set_f32("warbase old health", health);
            }
            
            if (upgrade_level < 2)
			{
				SetupUpgradeTable(this);
			}
			else
			{
				SetupTunnelLayer(this);
			}
        }
    }

    //food anim

    if ((getGameTime() + 3) % 10 == 0)
    {
        CBlob@ warbase = this.getBlob();
        s16 old_food = warbase.get_u16("old_food");
        s16 food = warbase.get_u16("food");

        if (food != old_food)
        {
            warbase.set_u16("old_food",food);
            CSpriteLayer@ food1 = this.getSpriteLayer( "food1" );

            if (food1 !is null)
            {
                if (food > 350) {
                    food1.SetVisible(true);
                }
                else {
                    food1.SetVisible(false);
                }
            }

            CSpriteLayer@ food2 = this.getSpriteLayer( "food2" );

            if (food2 !is null)
            {
                if (food > 0) {
                    food2.SetVisible(true);
                }
                else {
                    food2.SetVisible(false);
                }
            }

            CSpriteLayer@ food3 = this.getSpriteLayer( "food3" );

            if (food3 !is null)
            {
                if (food > 100) {
                    food3.SetVisible(true);
                }
                else {
                    food3.SetVisible(false);
                }
            }
        }
    }
}


void onRender( CSprite@ this )
{
    CBlob@ warbase = this.getBlob();
    CBlob@ localPlayerBlob = getLocalPlayerBlob();

    if (localPlayerBlob !is null && 
     (((localPlayerBlob.getPosition() - warbase.getPosition()).Length() < localPlayerBlob.getRadius() + 64.0f) && 
       (getHUD().hasButtons() && !getHUD().hasMenus())))
    {
        Vec2f pos2d = warbase.getScreenPos();
        const uint level = warbase.get_u8("upgrade_level");
		CCamera@ camera = getCamera();
		f32 zoom = camera.targetDistance;
        int top = pos2d.y + zoom*warbase.getHeight() + 160.0f;
        const uint margin = 7;
        Vec2f dim;
        string label = "Level 10000";
        GUI::GetTextDimensions( label , dim );
        dim.x += 2.0f * margin;
        dim.y += 2.0f * margin;
        dim.y *= 2.0f;
        f32 leftX = -dim.x;
        int current = 0, max = 0;

		// DRAW UPGRADE LEVELS

        if (level == 0)
        {
            current = warbase.get_u16("mat");
            max = warbase.get_u16("upgrade_1_cost");
        }
        else if (level == 1)
        {
            current = warbase.get_u16("mat") - warbase.get_u16("upgrade_1_cost");
            max = warbase.get_u16("upgrade_2_cost");
        }

		if (level < 2)
		{
			for (uint i = 0; i < 3; i++)
			{
				label = "Level " + (i+1);
				Vec2f upperleft(pos2d.x-dim.x/2 + leftX, top - 2*dim.y);
				Vec2f lowerright(pos2d.x+dim.x/2 + leftX, top - dim.y);
				bool isNextLevel = (i == level+1);
				f32 progress = 0.0f;

				if (i == 0) {
					progress = 1.0f;
				}
				else if (isNextLevel) {
					progress = float(current) / float(max);
				}
				else if (i <= level) {
					progress = 1.0f;
				}

				GUI::DrawProgressBar( upperleft,lowerright, progress );
				int base_frame = 10 + i;
				GUI::DrawIcon("Rules/WAR/WarGUI.png", base_frame, Vec2f(48,32), upperleft + Vec2f(0,0), 1.0f, warbase.getTeamNum());
				GUI::DrawText( label, Vec2f(upperleft.x + margin, upperleft.y + margin), level == i ? SColor(255, 255, 255, 255) : SColor(255, 120, 120, 120) );

				if (isNextLevel) {
					GUI::DrawText( "" + current + " / " + max, Vec2f(upperleft.x + margin, upperleft.y + dim.y/2.0f + margin ), color_white );
				}

				leftX += dim.x + 2.0f;
			}
		}

    }  // E
}


void SetupLayers( CSprite@ this, u8 upgrade_level, bool damaged )
{
    Vec2f cap_offset = Vec2f(0,-32);
    CSpriteLayer@ tower_cap = this.getSpriteLayer( "tower_cap" );

    if (tower_cap !is null)
    {
        tower_cap.SetOffset( cap_offset + Vec2f(0.0f,(-16.0f * upgrade_level)) );
        tower_cap.SetRelativeZ(-10.0);
        tower_cap.animation.frame = damaged ? 1 : 0;
    }

    Vec2f flag_offset = Vec2f(-4,-24 + (-8*s32(upgrade_level)));
    CSpriteLayer@ tower_flagpole = this.getSpriteLayer( "tower_flagpole" );

    if (tower_flagpole !is null)
    {
        tower_flagpole.SetOffset( cap_offset + flag_offset + Vec2f(16.0f,(-12.0f * upgrade_level)) );
        tower_flagpole.SetRelativeZ(-10.0);
    }

    CSpriteLayer@ tower_flag = this.getSpriteLayer( "tower_flag" );

    if (tower_flag !is null)
    {
        tower_flag.SetOffset( cap_offset + flag_offset + Vec2f(28.0f, -4 + (-12.0f * upgrade_level)) );
        tower_flag.SetRelativeZ(-11.0);
    }

    CSpriteLayer@ tower = this.getSpriteLayer( "tower" );

    if (tower !is null)
    {
        if (upgrade_level > 0)
        {
            tower.SetVisible(true);
            tower.SetOffset( cap_offset + Vec2f(0.0f, 32.0f +(-16.0f * upgrade_level)) );
            tower.SetRelativeZ(-10.0);
            tower.animation.frame = (upgrade_level-1) + (damaged ? 2 : 0);
        }
        else
        {
            tower.SetVisible(false);
        }
    }

    //barracks anim
    {
        CSpriteLayer@ barracks_unbuilt = this.getSpriteLayer( "barracks_unbuilt" );

        if (barracks_unbuilt !is null)
        {
            if (upgrade_level == 0) 
            {
                barracks_unbuilt.SetVisible(true);
            }
            else 
            {
                barracks_unbuilt.SetVisible(false);
            }
        }

        CSpriteLayer@ barracks = this.getSpriteLayer( "barracks" );

        if (barracks !is null)
        {
            if (upgrade_level > 0)
            {
                barracks.SetVisible(true);
            }
            else 
            {
                barracks.SetVisible(false);
            }
        }

        CSpriteLayer@ barracks_weapons = this.getSpriteLayer( "barracks_weapons" );

        if (barracks_weapons !is null)
        {
            if (upgrade_level > 0) 
            {
                barracks_weapons.SetVisible(false);
            }
            else 
            {
                barracks_weapons.SetVisible(false);
            }
        }

        CSpriteLayer@ barracks_bench = this.getSpriteLayer( "barracks_bench" );

        if (barracks_bench !is null)
        {
            if (upgrade_level > 1) 
            {
                barracks_bench.SetVisible(true);
            }
            else 
            {
                barracks_bench.SetVisible(false);
            }
        }
    }

	//upgrade table anim
	if (upgrade_level < 2)
	{
		SetupUpgradeTable(this);
	}
	else
	{
	 SetupTunnelLayer(this);
	}

}

void SetupUpgradeTable(CSprite@ this)
{
	CBlob@ warbase = this.getBlob();
	u8 upgrade_level = warbase.get_u8("upgrade_level");
	
	u16 mat = warbase.get_u16("mat");
	u16 oldmat = warbase.get_u16("old mat");
	
	if (oldmat != mat)
	{
		f32 mat_amount = matForUpgrade(warbase);
		f32 upgrade_amount = upgradeAmount( warbase, upgrade_level );
		
		CSpriteLayer@ table = this.getSpriteLayer( "upgrade_table" );
		if (table !is null)
		{
			if (mat_amount > 0)
			{
				table.SetVisible(true);
				table.animation.frame = Maths::Floor(mat_amount / upgrade_amount * 2.9f);
			}
			else
			{
				table.SetVisible(false);
			}
		}
		
		warbase.set_u16("old mat", mat);
	}
}

void SetupTunnelLayer(CSprite@ this)
{
	CSpriteLayer@ table = this.getSpriteLayer( "upgrade_table" );
	if (table !is null)
	{
		table.SetVisible(false);
	}
	
	
	CSpriteLayer@ tunnel = this.getSpriteLayer( "tunnel" );
	if (tunnel !is null)
	{
		tunnel.SetVisible(true);
	}
	
}
