# Implementação — encaixe do painel de alvo

Mantido o painel nativo144×40. `NameText` recebe somente o nome e ocupa x42–138/y6–18; `LevelText` mostra `NV{level}` em x42–72/y18–30; `ValueText` mostra HP real alinhado à direita em x78–138/y18–30. A raiz e a cena de painel mantêm parâmetros opcionais de nível com default1, e a bridge envia `display_name` sem prefixo mais o nível separado.

O retrato usa o tamanho natural se couber na região32×28; retratos maiores são contidos em dimensões inteiras e centralizados sob nearest. Os arquivos atuais (Tranca-Lata32×28 e Rivet Worker24×24) permanecem no tamanho original.

A antiga instância de `HudHealthBar` foi removida somente do painel de alvo. O `_draw()` de `HudTargetPanel` desenha uma moldura de6px com as cores já presentes na paleta do kit e preenche até90px usando a textura alvo existente. O fundo `Frame` usa `show_behind_parent=true` para ficar atrás da barra desenhada pela raiz; os controles irmãos de retrato e texto continuam sobre o fundo. A barra global/player `HudHealthBar` não mudou.

## Limites da verificação

A avaliação foi estática: dimensões, posição dos controles, métricas da fonte, cor/textura, chamadas da bridge e preservação por hashes. Não foi executado Godot/importação, teste, parser ou lint. A ordem visual é inferida da configuração `show_behind_parent` e da árvore de cena, sem captura de runtime.