# Adendo prospectivo — polimento visual v2

**Estado:** prospectivo; escrito antes das alterações autorizadas.
**Pedido:** “deixe um pouco melhor esse sprite”, referindo-se à abertura lateral atual.

O ajuste é modesto e permanece na passagem já existente: reforçar a leitura industrial cartoon com bevels de 2 px, chapa superior mais espessa, rebites 2×2, ferrugem discreta e indicador âmbar pequeno. Fechado terá grade mais robusta e trava mecânica. Aberto preservará o vão escuro amplo, sem grade, com profundidade e reforços somente nas bordas.

Manter a geometria `Rect2(-32,-64,64,128)`, estados, API, `flip_h`, z=-1, encaixe lateral, leitura E e física sem alterações. Usar apenas as cores da paleta de fábrica existente de 20 cores, contornos alinhados à grade e sem antialias. Nada se projeta além do retângulo do vão. A fonte Lua da prévia deve reproduzir os retângulos do runtime com a conversão local `(+32,+64)`, mantendo a faixa 1152×224, clipping e composição que ignora alpha 0.

Escopo de escrita: `scripts/world/side_door_visual.gd`, `assets/environment/factory_v1/door/side-opening/preview-side-opening.lua` e sua PNG de montagem; este adendo, o histórico e o registro. Sem testes, engine, import, quality audit ou QA.
