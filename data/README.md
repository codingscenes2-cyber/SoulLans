# Gameplay data

This directory will contain Godot Resources for weapons, armour, items, enemies, spells, classes, attacks, bosses and progression tables.

Design rules:
- Keep balance values out of hard-coded controller logic.
- Use typed Resources with explicit exported fields.
- Give each asset a stable identifier.
- Validate references and defaults before shipping.
- Version save data independently from resource definitions.


## Weapon resources

Weapon definitions use the `WeaponData` Resource script in `scripts/weapon_data.gd`. The starter Ashen Iron Sword lives at `resources/weapons/ashen_iron_sword.tres`. Weapon data currently drives the prototype light attack's base damage, stamina cost, range and startup/active/recovery timing. Scaling values and poise damage are authored data but are not yet applied by the player combat calculation.
