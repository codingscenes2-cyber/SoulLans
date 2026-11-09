# Combat and enemy AI specification

## Design goals
Combat must be deliberate, readable, responsive and consistent. Difficulty comes from enemy movesets, positioning, timing and resource management—not hidden stat changes or unavoidable damage.

## Player combat states
Locomotion, sprint, dodge, attack startup, attack active, attack recovery, block, parry, riposte, stagger, item use, casting and dead.

Each attack defines startup duration, active hitbox window, recovery duration, stamina cost, poise damage, damage type and scaling, allowed cancels/combo links, animation and VFX/SFX references.

## Defensive mechanics
- Dodge: explicit invulnerability interval, travel direction, stamina cost and recovery.
- Block: shield/weapon stability, stamina damage and chip damage rules.
- Parry: narrow timing window, attacker vulnerability and failure recovery.
- Guard counter: valid only after a blocked attack and with sufficient stamina.
- Backstab/riposte: positional and state requirements; never trigger solely from distance.

## Damage model
Separate base damage, attribute scaling, armour mitigation, elemental resistance, buffs, status buildup and poise damage. Keep formulas centralized and covered by tests. Communicate meaningful damage feedback without obscuring the encounter.

## Enemy AI states
Target architecture: idle, patrol, detect, investigate, chase, combat, attack, defend, dodge, stagger, retreat and death. The current Ashen Hollow prototype implements idle, patrol, investigate, chase, windup, recovery, stagger and death. It uses NavigationAgent3D path queries with direct steering as a fallback; a baked NavigationRegion3D is still required for reliable obstacle-aware navigation. The current enemy uses one telegraphed melee attack, not a production attack-selection system.

Enemy poise is separate from health. Player weapon resources supply poise damage; poise depletion interrupts the enemy into a short stagger, then poise resets. The current player attack still uses a physics overlap query rather than animation-authored weapon hitboxes.

## Boss framework
Boss data should define phases, health thresholds, arena bounds, attack sets, transition rules, rewards and persistent defeated flag. Bosses need distinct mechanics rather than only inflated health and damage.

## Required tests
- Dodge spends stamina once and cannot be spammed during recovery.
- Damage is applied only during active attack windows.
- A single swing cannot damage the same target repeatedly unless explicitly multi-hit.
- Parry success and failure have distinct results.
- Enemy telegraphs precede hit frames.\n- NavigationAgent3D pathing is tested inside a baked NavigationRegion3D; direct-steering fallback works in the graybox.
- Death, respawn and boss persistence are deterministic.
