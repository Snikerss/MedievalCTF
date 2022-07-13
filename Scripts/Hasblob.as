bool hasBlob( CBlob@ this, const string& in name )
{
    CBlob@ handsBlob = this.getCarriedBlob();

    if (handsBlob !is null && handsBlob.getName() == name) {
        return true;
    }

    return this.getInventory().getCount(name) > 0;
}