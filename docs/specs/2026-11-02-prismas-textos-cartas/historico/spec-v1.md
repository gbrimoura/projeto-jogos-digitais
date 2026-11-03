# Especificação — prismas de rank e tópicos sem marcadores

## Rank visual
- Receber `rank_before`, `rank_after`, `rank_max` e `reward_kind` da linha da oferta, sem consultar nem duplicar caps locais.
- Usar 3 espaços quando `rank_max <= 3`, 5 quando `rank_max <= 5` e 10 nos demais casos. Mapear o progresso para caps acima de 10 pela proporção entre rank atual e máximo.
- Desenhar prismas facetados na faixa local x=12..148, y=190..202 com formas retangulares em coordenadas inteiras e sem antialias: adquiridos ciano `#52BAC7`, próximo ofertado amarelo `#D2A75C`, vazios com contorno metálico. A posição do próximo ofertado é o primeiro espaço ainda não adquirido.
- Ocultar a fileira para `reward_kind == recovery`; manter o texto `CURA ATÉ 1 VIDA` e o status existentes.
- Preservar status NOVO/EVOLUIR/AJUSTE/MANUTENÇÃO e contador `NÍVEL atual > ofertado / máximo`, com cores e posição atuais.

## Tópicos e fundo
- Fundo navy local x=8..152, y=143..187, inserido após a moldura e antes dos tópicos; deixar y=188 livre para a divisória. O backdrop existente do resumo em y=118..142 permanece.
- Inicializar `Array[Color]` vazio e adicionar prefixo cyan/cinza com `append`; manter spans de cor, texto, wrapping e máximo de três linhas.
- Nenhum texto, tópico, ícone, efeito, recurso ou regra do catálogo deve mudar.

## Prévia
- Desenhar os mesmos prismas pixelados no Lua de preview e gerar apenas os quatro PNGs de estudo existentes por Aseprite com `preview_only=true`, sem `clean_frames`.
- Casos do estudo principal: Carga 0→1/220, Mola 1→2/3, Dínamo 2→3/3. Pós-build: atributo de cap 10, atributo de cap 5 e recuperação sem prismas.
- Prévia rotulada como estudo visual, sem afirmar que é screenshot Godot.

## Validação permitida
Inspeção manual dos PNGs exportados e leitura estática dos arquivos no escopo. Nenhum Godot, import, teste, parser, linter, auditoria automática, render audit ou simulação.