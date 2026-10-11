# Grok — números dos upgrades

Cursor Agent; grok-4.7-xhigh-fast; plan/read-only. Fontes: fontes.json.

STATUS: done
SUMMARY: A hierarquia do card fecha no recorte pedido. Em cada um dos três botões, a Description curta fica acima de um Label nativo EffectSummary, com fonte 30 contra 16 na descrição. O texto numérico vem só de `effect_summary` (export de apresentação, atribuído ao label) e o preview da cena repete o mesmo texto. Valores mantidos: Impacto `projectile_damage_override = 2` e "1 → 2 de dano"; Motor `dash_cooldown_override = 0.4` e "0,55 s → 0,40 s"; Carga `charged_damage_bonus = 2` e "+2 de dano". NodePaths e casts `as Label`/`Button`/`TextureRect` batem com a árvore. Subárvore do card está com `mouse_filter = 2` (IGNORE), então o clique continua no Button; os labels novos não entram em foco. Painel mínimo 1060×438 cabe em 1152×648; os três cards são 310×278, mesma ordem e alinhamento; ícone nulo fica `visible = false` em `present_options`. Nenhum cálculo de gameplay nesses arquivos lê `effect_summary`.
CHANGED_FILES: none
TESTS: static only — leitura dos seis arquivos congelados; sem Godot, sem testes, sem git
RISKS: low | scenes/upgrade_offer.tscn Description de ImpactCard e ChargeCard versus resources/upgrades/impacto_reforcado.tres e resources/upgrades/carga_reativa.tres | o preview da descrição na cena ("Aumenta o dano-base da bola." / "Energiza a própria bola após um parry.") difere da descrição do resource ("Aumenta o dano da bola." / "O parry energiza sua bola para o próximo acerto."); `present_options` sobrescreve antes do `show()`, e os três `effect_summary` da cena coincidem com os resources
NEXT_STEP: aceitar o incremento; sincronizar essas duas Descriptions da cena com os resources só se o preview do editor precisar ser fiel

