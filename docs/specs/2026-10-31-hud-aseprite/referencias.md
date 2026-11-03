# Referências visuais de HUD

Consulta31/10/2026. Observações feitas pelo principal em screenshots oficiais de Steam publicadas pelos respectivos desenvolvedores; inferências de composição, não engenharia interna nem regras válidas para toda versão. Dados de origem em pareceres/referencias-steam.json e referencia-rogue-legacy-2.json. Arquivos de estudo estão fora do repositório, em .codex/tmp/hud-referencias-2026-10-31; nenhuma textura estrangeira entra no kit.

| Referência | Observação na captura consultada | Adaptação para nosso jogo |
|---|---|---|
| [Hollow Knight / Team Cherry](https://store.steampowered.com/app/367520/Hollow_Knight/) | Vida, recurso circular e moeda concentrados no alto à esquerda; amplo centro livre. | Agrupar vida e ação do jogador sem espalhar indicadores sobre a arena. Não copiar unidades de vida, recurso ou moeda. |
| [Rogue Legacy2 / Cellar Door Games](https://store.steampowered.com/app/1253920/Rogue_Legacy_2/) | Barras com atual/máximo à esquerda e ações abaixo; orientação/minimapa em canto direito. | Vida numérica capaz de crescer e coluna de dash; salas à direita. Sem inventar mana/minimapa. |
| [Hades / Supergiant](https://store.steampowered.com/app/1145360/Hades/) | Barra de chefe e nome no alto central; vida do jogador no canto inferior esquerdo. | Separar alvo e jogador visualmente; manter topo esquerdo aprovado em vez de copiar toda posição do Hades. |
| [Dead Cells / Motion Twin](https://store.steampowered.com/app/588650/Dead_Cells/) | Screenshots promocionais consultadas omitem HUD global; algumas mostram pequenas barras locais sobre inimigos. | Referência de contraste e densidade da arte pixelada; não inferir posição de HUD ausente. Nosso usuário pediu HP fora dos inimigos, por isso barras locais não são adotadas. |

Conclusão de desenho: margens consistentes, módulos agrupados por função, barra do alvo separada, texto não misturado com ornamento e centro/caminhos do chão livres. São decisões nossas com base visual nas capturas, não recomendações atribuídas aos autores. Instrumento da bola compacto no alto à direita; componentes modulares para ajustar posições após avaliação no jogo. Não há alegação de testes de usabilidade ou acessibilidade realizados.
