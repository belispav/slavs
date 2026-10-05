> **Pozor (2026-10-05):** starý 3D reťazec (Blender sprajty, `*_px` priečinky) je v `_archiv/3d_stary/` mimo gitu. Aktuálna grafika je PixelLab (`*_pl_*`). Text nižšie je história, nebrať do úvahy.

# art/

Sem patria PNG sekvencie vyrenderované z Blenderu, každá animácia vo vlastnom
podpriečinku:

```
art/
  hero_run/     run_a00_0001.png, run_a00_0002.png, ...
  hero_idle/
  slaver_walk/
```

Scéna `scenes/art_test.tscn` (F6) automaticky nájde prvý podpriečinok s PNG
súbormi a prehrá ho.

Renderuje sa skriptom `tools/blender_render_sprites.py` v koreňovom priečinku
projektu. Postup je v `_archiv/GRAFIKA_test_pipeline.md`.
