extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var enemy := CharacterBody3D.new()
    enemy.name = "HitFlashTestEnemy"
    enemy.set_script(load("res://scripts/training_enemy.gd"))
    root.add_child(enemy)
    await process_frame

    var original: Color = enemy.enemy_material.albedo_color
    enemy._flash_hit()
    if enemy.hit_flash_timer <= 0.0 or enemy.enemy_material.albedo_color == original:
        push_error("A hit must visibly flash the enemy material.")
        quit(1)
        return

    enemy._update_hit_flash(0.2)
    if enemy.hit_flash_timer != 0.0 or enemy.enemy_material.albedo_color != original:
        push_error("Hit flash must expire and restore the original material colour.")
        quit(1)
        return

    enemy.queue_free()
    await process_frame
    print("PASS: enemy hit flash expires and restores its material")
    quit(0)
