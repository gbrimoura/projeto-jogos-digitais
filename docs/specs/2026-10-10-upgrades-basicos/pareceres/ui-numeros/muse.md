# Muse — números dos upgrades

OpenCode; opencode-go/muse-spark-1.3-contributor; xhigh; plan/read-only. Fontes: fontes.json.

STATUS: done
SUMMARY: Text/numeric hierarchy increment verified presentation-only: short Description (16) above separate native EffectSummary Label (30, distinct color) in all 3 cards, driven by resource.effect_summary with matching scene preview values 1→2, 0,55→0,40, +2 unchanged; node paths/types, resource mapping, mouse_filter pass-through to Button, 1060x438 in 1152x648 bounds, 3x310x278 aligned cards with icon hidden-if-null, no gameplay logic change.
CHANGED_FILES: none
TESTS: static only — read scenes/upgrade_offer.tscn, scripts/ui/upgrade_offer.gd, scripts/progression/upgrade_definition_resource.gd, 3x resources/upgrades/*.tres; no execution/Godot/tests per freeze.
RISKS: low / scenes/upgrade_offer.tscn + resources/upgrades/*.tres / preview Description wording drift (Impact/Carga preview vs .tres) — no actual issue, overwritten at runtime by present_options().
NEXT_STEP: Keep frozen; proceed to next authorized front.

