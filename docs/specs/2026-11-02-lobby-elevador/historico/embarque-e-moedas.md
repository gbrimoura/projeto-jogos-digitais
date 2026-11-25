# Embarque e moedas de sucata

- O embarque exige o personagem vivo, no chão e perto da cabine. Depois do E, os controles são suspensos durante as seis poses de 80 ms e a sequência de portas, luzes e troca de cena. Uma falha na troca restaura o personagem e exige que ele se afaste para tentar de novo.
- A moeda usa a textura existente em escala 2× com filtro nearest. Objetos preservam a quantidade configurada. A moeda de inimigo vale uma sucata, preservando o valor anterior por derrota, e é creditada quando recolhida. O bônus da Bolsa Magnética continua restrito aos pickups que já o recebiam.
- O drop do inimigo usa a posição capturada no sinal de derrota e procura uma superfície abaixo, considerando também colunas ao lado de um alçapão. A coleta fica restrita ao Player vivo da sala ativa.

## Registro de integração

ImageGen integrado ao Codex gerou o estudo de pose com o prompt abaixo. A produção montou as duas primeiras poses a partir da caminhada existente e desenhou a virada e a vista traseira no Aseprite. O atlas de embarque é separado do atlas de combate.

> Create a clean 4-frame animation reference strip for the exact small Selenite Tower pixel-art character in the attached reference, viewed at the same camera height in a 2D side-scrolling game. Four equal spaced cells across one row, consistent baseline, exact proportions, no text, no backdrop or elevator. Left to right: protagonist finishes a walk step, turns shoulders toward an elevator receding into the screen, neatly takes one short step in a three-quarter back view, settles facing away. Exact dark navy athletic/mechanical body, yellow accents, ivory helmet shell, single yellow-tipped antenna, short buggy cyan visor only on first two frames and no face on the final rear pose. Hard square edges, crisp low-resolution original sprite design. Use this as a posing reference, visual clarity over extra detail.

Aseprite exportou PNG de 384 × 64, fonte editável e GIF de prévia. A inspeção confirmou seis quadros distintos, 80 ms por quadro e transparência binária. `git diff --check` passou. A execução do Godot segue pendente.


O pescoço foi redesenhado nas três poses de costas com uma junta clara e contornada entre o capacete e os ombros. O PNG do jogo, a fonte Aseprite e o GIF foram atualizados. A comparação da exportação confirmou as três primeiras poses idênticas e as seis durações de 80 ms.
