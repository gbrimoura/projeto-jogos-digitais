# Especificação — cartas mecânicas

## Contrato de arte
- Sete assets transparentes, cada um com grade de origem 64×40 e export PNG 128×80 em escala inteira 2×.
- Manter os caminhos e IDs existentes sob assets/ui/upgrade_cards_v1.
- Usar somente a paleta HUD existente, cuja ordem e 19 hexadecimais são validados pelo gerador; no máximo cerca de 10 cores opacas por ícone e alpha binário.
- Contorno regular de 1 px nativo; volumes cartoon com grandes agrupamentos, sombras e realces de 2–3 tons por material; luz do alto à direita.
- A fonte ASE continua em 128×80 com camadas editáveis escaladas em 2×, conforme contrato do gerador.

## Identidade dos sete objetos
1. impacto_reforcado — bola metálica volumosa com quatro ou mais rebites grandes integrados à superfície; sem raquete ou sinais abstratos.
2. motor_acelerado — propulsor industrial pequeno e reconhecível por corpo, bocal de escape e chama; sem ícone sobreposto.
3. carga_reativa — bobina elétrica de volume industrial com núcleo/enrolamento e uma faísca de escala secundária; não usar bola com raio.
4. ricochete_pressao — válvula/regulador de pressão com manômetro integrado e componentes de tubo/base; não usar bola e parede.
5. mola_retorno — mola helicoidal comprimida formada por voltas de metal arredondadas, apoiada entre duas bases; não representar com ziguezague.
6. dinamo_defesa — gerador compacto reconhecível com carcaça e volante lateral; sem raquete ou mostrador de relógio.
7. chassi_reforcado — placa de blindagem espessa, com borda em relevo e rebites grandes; sem coração.

## Artefatos de saída
- Fonte canônica: source/generate_upgrade_cards.lua.
- Fontes e exportações: sete arquivos .aseprite e sete PNGs 128×80 existentes.
- Prévia de três cartas em 576×324 e 1728×972; contato em 432×352 e 864×704.
- Atualização da descrição de estilo em README.md e export/manifest.json. Sem modificar molduras, fontes, integração geométrica ou .import.

## Preservação de composição
As partes do gerador que leem a paleta, abrem as molduras/fontes, montam as prévias e aplicam suas dimensões permanecem iguais. Textos, posições, títulos, estado das cartas e artefatos de layout não fazem parte desta rodada.

## Verificação
Executar apenas a produção Aseprite autorizada e abrir as imagens para inspeção visual. O principal solicitará revisões estáticas após o congelamento. Sem execução de engine, testes, parser, linter ou auditorias automáticas.