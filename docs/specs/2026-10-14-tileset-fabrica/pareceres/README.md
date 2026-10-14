# Pareceres — primeiro tileset da fábrica

Estado: arte V3 reproduzida no Aseprite e TileSet visual preparado no projeto. Gemini R1 sem bug funcional; Muse R2 aceitou a descrição corrigida sem bloqueios remanescentes. Opus bloqueado por quota; Grok expirou sem parecer. Godot, importação, gameplay, testes e quality audit não foram executados. Colisões e uso na sala não fazem parte deste kit visual.

## Método e autoria

O principal consultou o GDD real no Notion antes da geração: Arquivo Central, Direção Visual e Protótipo do Primeiro Andar. A referência ImageGen foi preservada; GPT-6 Luna xhigh reproduziu as peças em Aseprite, ajustou os conectores e as plataformas, exportou o atlas128×128 e preparou16 regiões32×32 no TileSet. Os recortes32px/16peças/20cores são desta tarefa, pois GDD mantém paleta e resolução finais pendentes.

A fonte, os contatos e as demos foram inspecionados pelo principal antes das cópias do projeto. Três cópias binárias (atlas, fonte Aseprite, demo) são idênticas às versões aprovadas. PNG final SHA256: `1ECBCD964639CEE5B8502076952B9AA12909E30B146EF62B6330CC36258CA7D5`.

Luna no Codex atingiu quota ao iniciar a última correção documental, após concluir os assets. O mesmo modelo foi usado por OpenCode Go (`opencode-go/gpt-6-luna`, variante `xhigh`, plan somente leitura), retornando textos pelo stdout para integração controlada pelo principal. Não houve troca de modelo/esforço. Fast/priority não selecionável nem confirmável em ambas as interfaces. Handoff e erro preservados.

## Rodadas e limites

Preflight de autenticação/modelos uma vez nesta tarefa: Cursor, AGY e OpenCode Go disponíveis; identificadores exatos confirmados. R1 com fontes completas inline (Lua, TileSet, preview, paleta, manifest); limite3min pela frente estreita de assets/recurso novo, sem gameplay. R2 restrita a descrições documentais, também3min. Revisores somente leitura, sem ferramentas de workspace ou execução de engine.

| Revisor | Modelo/ferramenta | Resultado |
|---|---|---|
| Gemini R1 | Gemini 3.8 Flash (High), AGY plan | Exit0; sem bug funcional; observações avaliadas abaixo. |
| Muse R1/R2 | opencode-go/muse-spark-1.3-contributor, xhigh, OpenCode plan | Exit0; R2 aceita descrições e encerra suspeitas por intenção/fix aplicada. |
| Grok R1 | grok-4.7-xhigh-fast, Cursor plan | Timeout3min; interrompido por Ctrl-C; stdout vazio, nenhum parecer. |
| Opus R1 | claude-opus-5-5-high, Cursor plan | Exit1; ActionRequiredError por quota, nenhum parecer. |

## Avaliação do principal

- As pontas da plataforma possuem suportes inferiores triangulares/rebitados maiores (16/17px), enquanto o corpo reto tem10px. É a forma da referência, com topo contínuo e largura32px. O principal aceitou a imagem; nenhum alongamento do meio foi feito para satisfazer uma hipótese de retângulo uniforme. Luna descreveu o papel das pontas e do meio no Lua, manifest e README; Muse R2 aceitou essa decisão.
- Corrigida a mensagem do README gerado que dizia aguardar aprovação, em contraste com o manifest aprovado. A nova redação distingue aprovação visual/cópias prontas de carregamento e gameplay não verificados.
- `output_bounds` é a região alocada de amostragem/registro; `opaque_bounds` mede pixels alpha efetivos. O cotovelo aloca32px de altura, mas ocupa21px após translação. As descrições esclarecem as medidas, sem mudar coordenadas ou pixels.
- O assert de apoio é somente uma relação aritmética de registro. Não foi tratado como comprovação independente de colisão ou contato físico. A inspeção visual da demo é evidência separada; engine não executado.
- O preview usa Sprite2D com PNG2×/nearest, não um TileMapLayer em gameplay. Ele serve para inspecionar arte/escala; não comprova carregamento do `.tres` ou físicas. O recurso contém16 regiões manuais, sem terrenos automáticos nem colisões.
- As emendas de cano foram corrigidas com registro local, cópia do flange da própria referência e extrusão de borda. Os segmentos de plataforma passaram a ocupar32px de largura exata. Tudo está reproduzível na Lua; não houve redesenho do personagem.
- Sintaxe de comentários `.tres` corrigida para `;`, conforme [formato oficial Godot4.7](https://docs.godotengine.org/en/4.7/engine_details/file_formats/tscn.html).

## Evidência e preservação

Stdout/stderr originais `gemini-r1.txt`, `muse-r1.txt`, `muse-r2.txt`, `grok-r1.txt`, `opus-r1.txt`; entradas `review-input-r1.txt` e `review-input-r2.txt`. Estado congelado e revisão documental em `estado-r1-sha256.json`/`estado-r2-sha256.json`. Somente Lua/manifest/README receberam descrições apósR1; PNGs, Aseprite, TileSet, preview e paleta ficaram iguais.

`personagem-preservado.json` compara8 arquivos do personagem, rebatida e launcher/controller com o fechamento anterior: todos permanecem idênticos. Nenhum commit, push, branch ou mudança de cena preexistente nesta tarefa. Revisões Opus/Grok permanecem ausentes; não atribuir aprovação a esses modelos.

Importação posterior autorizada pelo usuário: [Godot4.7.2 — importação/carregamento exit0](importacao-2026-10-14/README.md). As restrições de não execução descritas acima correspondem à etapa de criação anterior.

