# Plano prospectivo — contador de nível das cartas

## Objetivo
Adicionar ao rodapé existente de cada carta um status de aquisição e um contador explícito de nível atual, próximo nível e teto aplicável. O rodapé ocupa a mesma área; não aumenta cartão, fonte ou ícones.

## Decisões aprovadas para esta frente
- Manter o box atual e a moldura de 160×240.
- Linha 1: status centralizado em x=12..148, y=205..216: `NOVO` ou `EVOLUIR`; ao chegar ao teto, `NOVO - MÁXIMO` ou `EVOLUIR - MÁXIMO`.
- Linha 2: contador centralizado em x=12..148, y=217..228, no formato `NÍVEL ATUAL > PRÓXIMO / MÁXIMO`. Mostrar sempre o rank possuído antes da escolha, inclusive 0 para uma carta nova.
- Fonte bitmap atual, 5×11 glifos com avanço 6 e altura de linha 12. Para `NÍVEL 219 > 220 / 220`, 21 glifos (126 px) cabem na largura de 136 px.
- Texto de status ciano `#52BAC7`; status que chega ao teto amarelo `#D2A75C`. Prefixo, nível atual, seta e teto cinza `#B6BEC3`; somente o nível alvo fica amarelo.
- Derivar o máximo por `UpgradeCatalog.max_rank_for(upgrade_id, base_maximum_health)`. Exibir fielmente os tetos existentes: 3 para Motor/Pressão/Mola/Dínamo, teto de Chassi derivado do HP base e teto provisório 220 para Impacto/Carga.
- Prévia Aseprite: Carga 0→1/220, Mola 1→2/3 e Dínamo 2→3/3. Texto de Dínamo acompanha a comparação atual 0,3s→0,45s.

## Escopo autorizado
- `scripts/progression/upgrade_catalog.gd`: `card_preview` e dados de apresentação; preservar efeitos, caps, `can_acquire` e seleção de oferta.
- `scripts/ui/upgrade_card.gd`: referências tipadas do rodapé, configuração e helper de cores do contador; deixar tópicos/descrições intactos.
- `scenes/ui/upgrade_card.tscn`: trocar somente o Badge por controles tipados de status/contador e ajustar geometria/cor do rodapé existente.
- `assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua`: somente o desenho do rodapé no estudo.
- `assets/ui/upgrade_cards_v1/README.md` e `export/manifest.json`: contrato de apresentação/metadados, se necessário.
- `assets/ui/upgrade_cards_v1/preview/upgrade-cards-study-576x324.png` e `upgrade-cards-study-1728x972.png`: regeneradas pelo Lua em modo `preview_only=true`.

## Restrições
Não alterar mecânicas, IDs, caps, ofertas, aquisição, efeitos, tópicos, descrições, ícones, fonte/atlas, molduras, dimensões, HUD base ou `UpgradeStatText`. Não criar barras, marcas, tooltips ou novas caixas. Não executar Godot, imports, testes, parser, linter, detector, auditorias ou simulação. Aseprite real permitido para as duas prévias. Sem commit, push, branch, limpeza ou operações fora do escopo.

## Estado
Plano prospectivo; baseline dos alvos será arquivada antes da implementação. Após a renderização visual, o estado será congelado para revisão somente leitura pelo agente principal.
