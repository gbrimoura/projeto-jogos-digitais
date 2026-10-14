# Especificação — dash do protagonista

## Estado atual — escala v5 (13/10/2026)

A escala V5 aplica fator uniforme 0,85, nearest-neighbor, somente aos quadros
14–16 da animação lateral +X. O atlas atual tem 28 quadros (1792×64) e já
contém o pulo V4 corrigido em 17–24 e hurt V1 em 25–27. Os 25 quadros não-dash
permanecem pixel-exatos, assim como 28/28 durações e 8/8 tags; `.tres`, `.import`,
scripts, cenas, física e controles não foram alterados. O pivô comum é X=32,
Y=56; os tempos dash continuam 40/40/60 ms, total 140 ms, não cíclico. A
importação de recursos do editor Godot 4.7.2 em recovery mode terminou com
exit 0. Não houve gameplay, testes ou quality audit. Gemini/Muse/Grok revisam os
arquivos congelados; Opus está bloqueado por quota.

Veja [diagnóstico, transformação, hashes e resultado V5](spec-escala-v5.md),
[implementação](implementacao.md#dash-escala-v5--13-10-2026) e as fontes e
previews em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-escala-v5/`.

## V4 — histórico

A V4 introduziu a referência lateral +X nos quadros 14–16 do atlas então
composto por 25 quadros. A decisão de escala foi sucedida pela V5. Veja
[referência, métricas e parâmetros v4](spec-v4-referencia.md),
[resultado da integração V4](implementacao.md#dash-v4--13-10-2026) e os
arquivos congelados em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash-v4/`.
O histórico de pareceres V4 está em [referência V4](pareceres/referencia-v4/README.md).

## Histórico de especificações — v1 a v3

## Fonte e atlas

- Fonte de entrada: `GDD_Dieselpunk_Noir/pitch-assets/protagonista-walk/protagonista-walk-v3.aseprite`, com os doze frames aprovados de idle e caminhada.
- A fonte Lua acrescenta três frames novos ao mesmo sprite, sem alterar a fonte
  v3 no disco. O clone da composição da pose base pode ser usado para construir
  os novos desenhos.
- Cada quadro mede 64×64 px. O atlas final é horizontal, de 960×64 px: idle nos
  índices 0–5, walk nos índices 6–11 e dash nos índices 12–14.
- A arte dash mantém a paleta amostrada de 27 cores, pixels opacos ou
  transparentes e a identidade visual da cabeça e do traje. Não usa
  anti-aliasing, rotação interpolada, blur ou pixels fora do canvas.
- As três poses são desenhos originais em perfil +X, com um visor lateral preto e uma lente ciano, peito creme/amarelo e pernas escuras com placas azuis. Representam impulso, avanço e sustentação. O tronco/cabeça se
  inclinam para +X; os braços ficam recolhidos para trás; as pernas flexionam e
  permanecem ligadas aos quadris, com ao menos um pé perto do chão. A direção
  oposta continua usando o `flip_h` da imagem.
- O script aceita `out`, `source_aseprite` e `base`. O nome padrão é
  `protagonista-dash-v3`; `source_aseprite` aponta para o arquivo v3 na pasta
  `protagonista-walk`.

## Temporização

| Animação | Índices | Duração por quadro | Ciclo |
|---|---:|---:|---:|
| idle | 0–5 | 420, 140, 180, 140, 540, 80 ms | 1.500 ms, cíclico |
| walk | 6–11 | 100 ms cada | 600 ms, cíclico |
| dash | 12–14 | 40, 40, 60 ms | 140 ms, não cíclico |

O recurso `SpriteFrames` mantém velocidade base de 1 fps; `duration` permanece
como multiplicador de segundos. A última pose de dash continua visível enquanto
`_is_dashing` permanecer ativo após os 140 ms. O controlador de dash já limita a
duração em 0,14 s; esta alteração não ajusta esse valor.

## Estado visual e integração

Prioridade: morte (animação parada), dash, pose estática no ar (primeiro quadro
do idle), e, no chão, caminhada ou idle conforme o estado atual.

A transição de `set_dashing(false)` para `set_dashing(true)` reinicia o frame 0
do dash uma única vez. Mudanças de estado de chão ou caminhada enquanto o dash
está ativo não chamam `play()` novamente. Se o dash terminar antes ou depois dos
140 ms, a apresentação volta imediatamente à animação adequada para o estado
atual. Morte interrompe a animação e o reset mantém o comportamento de idle já
existente. O espelhamento continua limitado ao `AnimatedSprite2D`; a trilha
`DashTrail` conserva seu comportamento.

Não há mudança de velocidade, duração, colisão, entrada, controle, raquete,
combate ou cenas.

## Estado histórico e pendências anteriores à v4

Implementado e exportado; PNG runtime e fonte Aseprite combinada atualizados. As tags originais são restauradas após acrescentar quadros para impedir autoexpansão da tag walk. R2 Gemini/Muse/Grok concluídas; Opus bloqueado por quota. Conferência manual no Godot pendente. Nenhum teste, execução do Godot ou quality_audit realizado.

## Prévia horizontal demonstrativa

O GIF protagonista-dash-horizontal-v3.gif usa canvas de 136×64 e 16 quadros, exportado em escala 6×. Mostra deslocamento de 50 px nativos em 140 ms para cada direção, intercalado com idle de 300 ms nos extremos; ciclo total de 880 ms. Reutiliza as três poses do atlas, com sete subquadros de 20 ms por direção. O espelhamento e a posição são inteiros. O runtime não foi alterado: a física do Godot já desloca a raiz do jogador. A primeira exportação tinha um quadro vazio inicial; contador próprio passou a reutilizar o frame inicial do Sprite e a fonte agora exige dezesseis quadros.

## Correção da postura — v2

Usuário esclareceu que queria o robô de lado durante o dash. A v1 mantinha pose frontal. Luna xhigh redesenhou os três quadros em perfil; principal exportou e integrou o atlas e a fonte editável. Contato inspecionado visualmente. Pareceres específicos desta v2 em pareceres/pose-lateral-v2; revisões anteriores não aprovam esta versão. Godot não executado.

## Pose compacta v3 — baseada na análise de referências

Usuário autorizou corrigir a silhueta ampla de corrida da v2. Cabeça baixa encostada no ombro, pescoço curto, tórax inclinado e compacto, um braço visível recolhido, perna de apoio sob o quadril e outra estendida para trás com bota elevada. Três quadros mantêm a pose principal com pequenas variações. Paleta/canvas/tags/timings preservados. Referência de postura: Mega Man X; adaptação original do robô, sem copiar sprites externos. Atlas e fonte combinada v3 integrados. Pareceres específicos em pareceres/pose-compacta-v3; revisões v2 não aprovam esta versão. Godot não executado.

## Orientação nativa por animação

Idle e walk têm direção nativa -X; dash tem direção nativa +X. AnimatedSprite2D.flip_h é true quando a direção lógica difere da direção nativa. animation_changed reaplica essa regra nas transições. DashTrail continua usando somente a direção lógica, sem inverter a trilha com base no desenho.

## Encerramento da revisão de escala V5 — 13/10/2026

Gemini, Muse e Grok concluíram a revisão estática; achados avaliados pelo principal sem correção de runtime necessária. Opus bloqueado por quota, sem parecer. [Relatórios originais, decisões e hashes](pareceres/escala-v5/README.md). Integração e importação concluídas; avaliação estética do usuário em jogo pendente.
