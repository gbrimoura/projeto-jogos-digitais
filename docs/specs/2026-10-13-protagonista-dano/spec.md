# Especificação prospectiva — dano v1

## Referência e direção

Referência gerada pelo método integrado de ImageGen (não Nano Banana), aprovada pelo principal, recebida em 13/10/2026 e preservada em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-hurt-v1/referencia-hurt-v1.png`. SHA-256 e extração final estão na metadata de arte. A imagem é RGBA 1983×793, com áreas transparentes e alpha parcial/halo na borda; a reprodução usa limiar de alpha e quantização sem dithering.

A prancha tem três poses na ordem: impacto, contração e recuperação. O protagonista está em leitura frontal/lateral voltada à esquerda. Os dois primeiros quadros mostram olhos ciano apertados em `><`; no terceiro os olhos voltam a retângulos verticais. Cabeça e ombros permanecem conectados. A referência original é guia de postura e expressão; o idle V2 aprovado orienta identidade e paleta.

Resumo detalhado do prompt de referência: personagem protagonista original do projeto Dieselpunk Noir; reação de dano expressiva em três poses lado a lado, near-front voltado à esquerda; capacete marfim, visor marinho, olhos ciano, corpo mecânico azul/amarelo, anatomia compacta; primeiro quadro recebe impacto com leve recoil da cabeça e olhos `><`; segundo comprime o torso/ombros sem separar membros; terceiro recupera cabeça/postura e reabre os olhos como dois retângulos ciano; manter leitura de pixel art, contornos nítidos, proporções/head size do idle e pernas apoiadas. Evitar deslocamento do root, pose de morte, sangue, blur, motion trails, pixels semi-transparentes na reprodução final e alteração do design. A origem da imagem aprovada e o prompt reproduzível/resumo estão documentados junto aos artefatos em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-hurt-v1/README.md`.

## Arte

- Cada frame runtime: 64×64 px; três cels em sequência editável Aseprite.
- Cadência: impacto 80 ms, contração 80 ms, recuperação 100 ms; total real do clip: 260 ms; `hurt` não faz loop.
- Direção nativa à esquerda, igual ao idle; flip atual do personagem continua aplicado.
- Sola de apoio alinhada a y=56. Usar escala nearest única e registro compartilhado; não auto-fit independente por pose.
- Quantizar à paleta do idle de 27 cores; pixels opacos alpha 255 ou transparentes alpha 0; sem anti-aliasing/dithering.
- Prévia GIF 4×: idle em pausa, três frames de hurt nos timings de runtime e idle novamente; holds de idle são demonstrativos e não parte do clip runtime.

O principal aprovou o contact comparativo `protagonista-hurt-v1-contact-idle-hurt-4x.png` antes da integração: a expressão `><`, escala/alinhamento com idle, compressão e recuperação foram consideradas legíveis, sem clipping visível.

## Atlas e SpriteFrames

Base congelada: 25 frames (atlas PNG 1600×64; fonte Aseprite 64×64 com 25 frames). Animações e cadências existentes estão registradas em `historico/baseline/runtime/resources/player_sprite_frames.tres`; baseline integra o Dash V4 local ainda não commitado.

Após aprovação do contact, foram anexados frames 25–27, mantendo frames 0–24, seus tempos e tags sem mudança. Atlas PNG final: 1792×64. O recurso SpriteFrames recebeu um animation `hurt`, loop `false`, speed 1, com frames 25/26/27 e 0,080/0,080/0,100 s. O integrador verificou os pixels e as durações dos 25 frames baseline e faixa/direção/repetição de cada tag antes de salvar.

## Lógica

`PlayerHealth` deve marcar o timer de 0,5 s antes de sinais de estado, recusar amount ≤ 0, HP já zerado e dano com timer ativo, e emitir um sinal de dano aceito depois da mutação do HP. `Player` conecta a esse sinal e pede reação somente quando `current_health > 0`; dano letal continua pelo caminho existente de `died`.

`PlayerVisual` guarda estado hurt e permite que o clip natural conclua pelo `animation_finished`. O clip não é reiniciado por mudanças de input/facing/andar/ar. Prioridade: morte > hurt > dash > ar > land > walk/idle. A seleção de pouso e a reinicialização do dash devem respeitar hurt. Se o jogador pousar durante hurt, não deixar um land antigo enfileirado. Ao finalizar, limpar hurt e aplicar estado visual atual. Reset e morte limpam o estado; morte permanece cinza e parada conforme comportamento vigente.

A invulnerabilidade padrão e override no `scenes/player.tscn` ficam em 0,5 s. O flash mantém alpha 1.0 enquanto a expressão hurt está visível, com pulso leve; no restante da janela, preserva-se o flash atual por até 0,5 s. A lógica não bloqueia input nem altera movimento, dano letal, física, colisão ou timers de combate.

## Evidência e limites

A revisão de arte pelo principal ocorreu antes da integração. A importação do editor Godot 4.7.2 terminou com exit 0 em recovery mode, confirmando carregamento de classes/scripts e reimportação do atlas. No modo normal, o editor falhou ao carregar a GDExtension preexistente `git_plugin.gdextension` devido à DLL nativa e encerrou com signal 11 durante o scan inicial; o recovery mode ignorou essa extensão, sem alteração nos addons/TMPs. A importação confirma somente carregamento de recursos, não a sensação em jogo. Não executar gameplay, testes ou quality audit. Avaliação visual final do usuário no runtime continua fora desta entrega.

## Pareceres finais — 13/10/2026

Gemini 3.8 Flash High (AGY), Muse Spark 1.3 Contributor xhigh (OpenCode) e Grok 4.7 XHigh Fast (Cursor) concluíram a revisão estática sem correções obrigatórias. Opus 5.5 High via Cursor bloqueado por quota, sem parecer. Fonte congelada, relatórios originais e hashes em [pareceres](pareceres/README.md). Importação Godot em recovery mode concluída; nenhum gameplay/teste executado.
