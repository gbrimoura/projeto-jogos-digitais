# Plano prospectivo — traços e destaques nos tópicos das cartas

## Objetivo
Retirar os pequenos quadrados cobre que aparecem atrás dos tópicos, representar cada efeito como um tópico com traço ciano e destacar em amarelo apenas o benefício numérico ou o valor novo de uma comparação. Manter a moldura de 160×240, a fonte bitmap, os ícones e a lógica dos upgrades.

## Escopo autorizado
- `scripts/ui/upgrade_card.gd`: preparar e quebrar os tópicos por conteúdo e repassar as cores dos glifos.
- `scripts/ui/upgrade_stat_text.gd`: novo renderizador local derivado de `HudBitmapText`, sem carregar outra fonte.
- `scenes/ui/upgrade_card.tscn`: atribuir o script aos controles de tópicos existentes e ajustar apenas esses controles/backdrops se necessário.
- `assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua`: modo explícito `preview_only=true` + `clean_frames=true`, limpando só as marcas pequenas na região dos tópicos das três molduras; atualizar o estudo de três cartas.
- `assets/ui/upgrade_cards_v1/source/upgrade-card-frame-states.aseprite` e os três `frame_*_160x240.png`: apenas as marcas isoladas na área y=118..186, nos estados normal/focus/pressed.
- `assets/ui/upgrade_cards_v1/preview/upgrade-cards-study-576x324.png` e `upgrade-cards-study-1728x972.png`: prévias atualizadas pelo Aseprite Lua.
- `assets/ui/upgrade_cards_v1/README.md` e `assets/ui/upgrade_cards_v1/export/manifest.json`: atualizar somente o contrato da apresentação e os arquivos realmente regenerados.

## Restrições
Não alterar gameplay, `UpgradeCatalog`, recursos de upgrades, mecânicas, IDs, caminhos ou arte dos sete ícones, fonte/atlas, tamanho, geometria ou molduras globais. Não tocar no contact sheet. Não executar Godot, imports, testes, parser, linter, auditorias, render audits ou simulações. Produção somente com Aseprite real; sem commit, push, limpeza ou mudanças fora deste escopo.

## Estado
Escopo implementado e congelado para revisão. A baseline foi arquivada antes da edição; revisões externas somente leitura ficam a cargo do agente principal.