s16 maxMat( CBlob@ this )
{
    s16 upgrade_1 = this.get_u16("upgrade_1_cost");
    s16 upgrade_2 = this.get_u16("upgrade_2_cost");
    return upgrade_1 + upgrade_2;
}

s16 upgradeAmount( CBlob@ this, int currentlevel )
{
    if (currentlevel == 0) {
        return this.get_u16("upgrade_1_cost");
    }
    else if (currentlevel == 1) {
        return this.get_u16("upgrade_2_cost");
    }
    else {
        return 0;
    }
}

s16 lastUgradeAmount( CBlob@ this, int currentlevel )
{
    s16 amount = 0;

    while (currentlevel > 0) {
        amount += upgradeAmount(this,--currentlevel);
    }

    return amount;
}

s16 matForUpgrade( CBlob@ this )
{
    u8 upgrade_level = this.get_u8("upgrade_level");
    s16 mat_amount = this.get_u16("mat");
    s16 last = lastUgradeAmount(this,upgrade_level);
    return mat_amount - last;
}

s16 matTilUpgrade( CBlob@ this )
{
    u8 upgrade_level = this.get_u8("upgrade_level");
    s16 mat_amount = this.get_u16("mat") - lastUgradeAmount(this, upgrade_level);
    return upgradeAmount(this,upgrade_level) - mat_amount;
}