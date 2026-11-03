# Especificação v2 — prismas de rank e tópicos sem marcadores

## Rank visual
- Receber `rank_before`, `rank_after`, `rank_max` e `reward_kind` da linha da oferta, sem consultar nem duplicar caps locais.
- Renderizar prismas apenas quando `rank_max` é exatamente 3, 5 ou 10; a quantidade de prismas é exatamente `rank_max`. Ciano representa níveis adquiridos, amarelo apenas o próximo nível ofertado, e os demais têm contorno metálico.
- Não mapear caps arbitrários por porcentagem. Para outros tetos finitos, ocultar a fileira e preservar o contador numérico.
- `reward_kind == recovery` sempre oculta a fileira; não representar seu teto contábil 220 como prismas. Manter `CURA ATÉ 1 VIDA` e status atuais.
- Desenhar na faixa local x=12..148, y=190..202 com retângulos de coordenadas inteiras e sem antialias.
- Preservar status NOVO/EVOLUIR/AJUSTE/MANUTENÇÃO e contador `NÍVEL atual > ofertado / máximo`, com cores e posição atuais.

## Dados atuais da prévia
- Cartas principais: Carga 0→1/3, Mola 1→2/3, Dínamo 2→3/3.
- Pós-build: velocidade da bola 0→1/10; ajuste do dash 0→1/5; recuperação sem prismas e sem contador de rank.
- Resumo e tópicos existentes são fonte de texto; não alterar recursos ou catálogo.

## Tópicos e fundo
- Fundo navy local x=8..152, y=143..187, inserido após a moldura e antes dos tópicos; deixar y=188 livre para a divisória. O backdrop existente do resumo em y=118..142 permanece.
- Inicializar `Array[Color]` vazio e adicionar prefixo cyan/cinza com `append`; manter spans de cor, texto, wrapping e máximo de três linhas.
- Nenhum texto, tópico, ícone, efeito, recurso ou regra do catálogo deve mudar.

## Prévia e validação
- Desenhar os mesmos prismas pixelados no Lua e gerar os quatro PNGs de estudo por Aseprite com `preview_only=true`, sem `clean_frames`.
- Manter os avisos de estudo visual; não afirmar que a imagem representa screenshot Godot.
- Validação: inspeção manual dos PNGs e leitura estática. Nenhum Godot, import, teste, parser, linter, auditoria automática, render audit ou simulação.