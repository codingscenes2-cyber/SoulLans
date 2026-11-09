#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p assets/materials assets/animations

echo "[1/4] Downloading the six environment texture maps from Poly Haven..."
python3 - <<'PY'
import json
import pathlib
import urllib.request

out = pathlib.Path("assets/materials")
assets = [
    ("concrete_floor_01", "concrete_floor_01"),
    ("rock_wall_17", "rock_wall_17"),
]
maps = [
    ("diff", "diff"),
    ("nor_gl", "nor_gl"),
    ("rough", "rough"),
]

def walk(value):
    if isinstance(value, dict):
        url = value.get("url")
        if isinstance(url, str):
            yield url
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)

for asset, prefix in assets:
    request = urllib.request.Request(
        f"https://api.polyhaven.com/files/{asset}",
        headers={"User-Agent": "SoulLand-Android-Prototype/1.0"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        data = json.load(response)
    urls = list(walk(data))
    for map_name, suffix in maps:
        candidates = [u for u in urls if u.endswith(f"_{suffix}_1k.jpg")]
        if not candidates:
            raise SystemExit(f"Missing Poly Haven map: {asset} {map_name}")
        target = out / f"{prefix}_{map_name}_1k.jpg"
        print(f"Downloading {target}")
        urllib.request.urlretrieve(candidates[0], target)
        if not target.exists() or target.stat().st_size < 1024:
            raise SystemExit(f"Texture download is missing or too small: {target}")
PY

echo "[2/4] Downloading the two Quaternius CC0 animation libraries..."
BASE="https://raw.githubusercontent.com/Barbatos6669/elderforge/bb2ce469f0ab2ccfc487faef55550ba07fae2483/assets/animations"
curl -fL --retry 3 "$BASE/universal_animation_library_1/UAL1_Standard.glb" -o assets/animations/UAL1_Standard.glb
curl -fL --retry 3 "$BASE/universal_animation_library_1/LICENSE_Quaternius_CC0.txt" -o assets/animations/LICENSE_Quaternius_CC0.txt
curl -fL --retry 3 "$BASE/universal_animation_library_2/UAL2_Standard.glb" -o assets/animations/UAL2_Standard.glb
curl -fL --retry 3 "$BASE/universal_animation_library_2/LICENSE_Quaternius_CC0.txt" -o assets/animations/LICENSE_Quaternius_CC0_2.txt

echo "[3/4] Installing the GLTF animation merge dependencies..."
npm install --no-save @gltf-transform/core@4.2.1 @gltf-transform/extensions@4.2.1

echo "[4/4] Merging animation clips into the Soul Land hero rig..."
node tools/merge_animations.mjs \
  assets/characters/ashen_hero.glb \
  assets/characters/ashen_hero_animated.glb \
  assets/animations/UAL1_Standard.glb \
  assets/animations/UAL2_Standard.glb

test -s assets/characters/ashen_hero_animated.glb
echo "SUCCESS: Android build assets are prepared."
du -h assets/characters/ashen_hero_animated.glb assets/animations/*.glb assets/materials/*.jpg
