# Estudos de HUD —31/10/2026

Três imagens de referência feitas com ImageGen a partir do fundo e protagonista reais:01 Painel deCaldeira;02 Placas deManutenção;03 Módulos deOficina. Usuário escolheu01, depois pediu revisar os elementos.

## Direção escolhida, revisão02

- Vida do personagem em painel mecânico, com retrato e leitura segmentada.
- Dash com ícone e contador de recarga; confirmar dados reais na futura implementação, sem inventar novas cargas ou outro recurso.
- Retirar os botões/indicadores de bola e raquete que não foram compreendidos.
- Contador de salas/andar.
- HP inimigo fixo na HUD, com nome/retrato. Usuário escolheu explicitamente o **inimigo próximo da mira**, não último atingido. Critério de desempate/estabilidade entre alvos será definido na implementação.
- Acelerômetro: usuário anunciou que adicionaremos aceleração à bola. O instrumento nesta imagem é conceito para essa mecânica futura. Unidade/escala, curva de aceleração, limite, reset e relação velocidade/aceleração ainda não foram definidos nem implementados.

01-painel-caldeira-revisao-04.png é a referência mais recente; as revisões02 e03 permanecem preservadas. Os três estudos iniciais permanecem preservados. Números/estados são ilustrativos; imagem não comprova regra final ou runtime. Não há modificações de HUD, HP inimigo acima de sprites, dash ou física da bola nesta correção de transição.

## Procedimento para próxima implementação

Continuar metodologia persistente: referência ImageGen alinhada aos assets atuais → reprodução/exportação Aseprite adequada à grade/paleta → integração Godot após confirmar visual e vínculo com estados reais. Imagens aqui são estudos conceituais, não spritesheets/pixelart auditada pronta para importar. Não houve QA/audit/Godot/testes (AGENTS). Referências vieram de assets reais; nenhuma imagem de referência substituiu diretamente sprites/cenas.

## Revisão03 — recargas como relógio cinza

Pedido de31/10: cooldown das ações em formato de relógio e cor cinza, mantendo também a frase. Prévia revisada com relógio circular e setor de progresso cinza, ícone do dash dessaturado durante a recarga, texto RECARREGANDO e tempo restante ao lado. A HUD de referência tem apenas o dash como ação com cooldown; o padrão vale para futuras ações autorizadas. Vida, HP inimigo e acelerômetro mantêm suas cores e funções. Apenas imagem conceitual e documentação foram atualizadas, sem alterações no runtime.

## Revisão04 — barras de HP e linguagem pixel art

O usuário aprovou barras de vida com valores atual/máximo para acomodar futuros upgrades e pediu manter tudo pixelado. A revisão04 troca as unidades isoladas por preenchimento contínuo em passos de pixel, tanto no HP do personagem quanto no painel fixo do inimigo. Valores da imagem são exemplos visuais, sem alteração da vida ou das regras atuais do jogo.

Direção visual: grade de pixels coerente, contornos em degraus, sombras em poucas cores e texto bitmap. Na futura reprodução Aseprite e integração, preservar pixels nítidos e revisar a filtragem/escala da HUD. Não usar fontes suaves, blur ou efeitos vetoriais para substituir essa linguagem. A prévia ImageGen não equivale a assets de produção auditados.

Preservados: cooldown do dash em relógio cinza com frase RECARREGANDO e tempo, HP inimigo mais próximo da mira identificado por nome/retrato, contador de salas e acelerômetro conceitual. Mudança somente de referência visual e documentação; HUD e aceleração ainda não integradas ao Godot.
