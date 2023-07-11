
-- campinfo
RoleResKey = {}

RoleType = {
    [1] = 'user',
    [2] = 'ai',
}

RoleStatus = {
    [0] = 'idle',
    [1] = 'playing',
    [2] = 'none',
    [3] = 'lost',
    [4] = 'leave',
}

ABILITY_STR_ATTRS = {
    ['name'] = 'name',
    ['desc'] = 'description',
}

ABILITY_FLOAT_ATTRS = {
    ['cost']='ability_cost',
    ['cd']='cold_down_time',
    ['damage']='ability_damage',
    ['range']='ability_cast_range',
    ['cast_time']='ability_cast_point',
    ['bw_time']='ability_bw_point',
    ['channel_time']='ability_channel_time',
    ['prepare_time']='ability_prepare_time',
    ['area']='ability_damage_range',
    ['stack_cd']='ability_stack_cd',
}

ABILITY_INT_ATTRS = {
    ['ability_max_stack_count']='ability_max_stack_count',
    ['max_level']='ability_max_level',
    ['required_level']='required_level',
    ['cast_type']='ability_cost_type',
}

ABILITY_BOOL_ATTRS = {
    ['is_passive']='is_passive',
    ['is_attack']='is_attack',
    ['is_meele']='is_meele',
    ['show_channel_bar']='show_channel_bar',
    ['is_toggle']='is_toggle',
}

SlotType = {
    ['Groud'] = -1,
    ['Bag'] = 0,
    ['Inventory'] = 1,
}

AbilityType = {
    ['Hide'] = 0,
    ['Normal'] = 1,
    ['Common'] = 2,
    ['Hero'] = 3,
}

AbilityTypeId = {
    'Hide','Normal','Common','Hero'
}

AbilityCastType = {
    ['Normal'] = 1,
    ['Active'] = 2,
    ['Passive'] = 3,
    ['Build'] = 4,
    ['MagicBook'] = 5,
}

AbilityCastTypeId = {
    'Normal','Active','Passive','Build','MagicBook'
}

KvType = {
    ['real'] = 'float',
    ['str'] = 'string',
    ['int'] = 'integer',
    ['string'] = 'string',
    ['integer'] = 'integer',
    ['bool'] = 'boolean',
    ['boolean'] = 'boolean',
    ['ui'] = 'ui_comp',
    ['unit'] = 'unit_entity',
    ['unitName'] = 'unit_name',
    ['unitType'] = 'unit_name',
    ['unitGroup'] = 'unit_group',
    ['item'] = 'item_entity',
    ['itemName'] = 'item_name',
    ['itemType'] = 'item_name',
    ['abilityType'] = 'ability_type',
    ['abilityCast'] = 'ability_cast_type',
    ['abilityName'] = 'ability_name',
    ['model'] = 'model',
    ['tech'] = 'tech_key',
    ['buff'] = 'modifier',
}

HarmTextType = {
    ['Phy'] = 1,
    ['PhyCrit'] = 2,

    ['Recover'] = 3,
    ['Mag'] = 4,
    ['MagCrit'] = 5,
    ['True'] = 6,
    ['Miss'] = 8,
}

RestrictionId = {
    ['ForbidNormalAttacks'] = 2^1,
    ['ForbidAbilities'] = 2^2,
    ['ForbidMovement'] = 2^3,
    ['ForbidTurning'] = 2^4,
    ['MotionFraming'] = 2^5,
    ['CannotBeStopped'] = 2^6,
    ['CannotBeLockedByAbility'] = 2^7,
    ['CannotBeSelected'] = 2^8,
    ['Invisible'] = 2^9,
    ['IgnoreStationaryObstacles'] = 2^10,
    ['IgnoreDynamicObstacles'] = 2^11,
    ['Imperishable'] = 2^12,
    ['Invulnerable'] = 2^13,
    ['CannotBeControlled'] = 2^14,
    ['CannotBeAttacked'] = 2^15,
    ['AIIgnore'] = 2^16,
    ['ImmuneToPhysicalDamage'] = 2^17,
    ['ImmuneToMagicDamage'] = 2^18,
    ['ImmuneToDebuffs'] = 2^19,
    ['Hide'] = 2^20,
}

DamageAttackType = {
    [1] = 'phy',
    [2] = 'mag',
}

DamageArmorType = {
    [1] = 'phy',
    [2] = 'mag',
}

DamageArmorType = {
    [1] = 'phy',
    [2] = 'mag',
}

SignalVisibleType = {
    [1] = 'all',
    [2] = 'self',
    [3] = 'ally',
    [4] = 'enemy',
}

--UNIT_COMMAND = {
--    [1] = 'Move',
--    [2] = 'Attack Move',
--    [3] = 'Attack Target',
--    [4] = 'Patrol',
--    [5] = 'Stop',
--    [6] = 'Garrison',
--    [7] = 'CastAbility',
--    [8] = 'PickUpItem',
--    [9] = 'DiscardItem',
--    [10] = 'GiveItem',
--    [11] = 'Follow',
--    [12] = 'MoveAlongPath',
--}
