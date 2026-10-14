# Plano — sprites dos inimigos

**Estado:** integração visual congelada para revisão estática; Godot/import/runtime/testes não executados.  
**Data:** 14/10/2026.

## Objetivo

Reproduzir a prancha confirmada como referência para TrainingTarget e RivetWorker, congelar fontes/atlases/metadata aprovados internamente e conectar a arte ao runtime visual dos placeholders, sem alterar regras de gameplay, física ou temporizadores.

## Método

- Usar Aseprite 1.3.18.6 e Lua reproduzível para abrir a prancha, isolar cada personagem, remover fundo conectado e texto, reduzir por nearest com um único fator por inimigo e quantizar à paleta industrial existente.
- Preservar os desenhos e sua identidade. Não desenhar uma alternativa procedural nem usar a imagem grande como textura runtime.
- Exportar cels 64×64, atlas, arquivo editável Aseprite, metadata com bounds/tempos e contact sheets ampliados por nearest. Comparar o TrainingTarget idle com a cópia do idle do protagonista em escala correspondente.
- Copiar PNGs/ASE aprovados para assets/enemy/{training_target,rivet_worker}, criar SpriteFrames em resources/enemy e conectar AnimatedSprite2D/shader de flash somente nos dois scripts/cenas autorizados. Preservar os nós legados escondidos, healthbars, WarningMark/Sound, geometrias, UIDs e transformações físicas.
- Não alterar AI, colisores, física, tempos, projétil, spawns, salas, protagonista, project.godot ou imports. Não executar Godot, import, gameplay, QA, testes ou auditorias.

## Alvos de arte

TrainingTarget: 3 quadros (idle, impacto, desativado), sprite nativo 64×64, corpo nominal 36×48, collider atual 72×96, base fixa em y=56. Transformação de referência e baseline constantes entre quadros. O estado desativado é somente arte; a lógica atual continua removendo inimigo letal imediatamente.

RivetWorker: 5 quadros (idle, andando, mirando, disparo, recuperação), sprite nativo 64×64, pivô de base (32,56), corpo nominal 23×32 e collider atual 46×64. A arte olha para a direita. A ferramenta permanece conectada à mão; sua boca nominal é (43,38) no frame em 64×64, tolerância estética de 4 px. O rig pode articular o braço sem redesenhar a identidade. Poses idle e recuperação mantêm a mesma pegada; intermediárias de caminhada são derivadas da referência.

## Limites desta frente

Nenhum runtime ou regra de gameplay. Manter geometria e tempos existentes. Disparo visual só depois de aceitação do projétil; flash letal atual permanece imediato. O timing de IA permanece windup 650 ms e recovery 800 ms. Nenhum ajuste de colisão, alcance, spawn ou boca física.

## Estado-base

Snapshots dos dois scripts e duas cenas estão em historico/base/; hashes SHA-256 dos arquivos protegidos de protagonista, piso, sala principal e sala secundária estão no mesmo diretório. O workspace tinha alterações anteriores do usuário; elas foram preservadas.


## Integração visual autorizada

TrainingTarget usa atlas 64×64 centrado em `(0,0)`, com base nativa y=56 alinhada ao topo inferior do collider existente (`+48` mundo). Idle é o quadro-base; dano não letal mostra impacto enquanto o flash original de 120 ms estiver ativo. O quadro desativado fica apenas em arte/metadata; dano letal continua emitindo `defeated` e `queue_free()` imediatamente.

RivetWorker usa atlas 64×64 com pivô `(32,56)`, AnimatedSprite2D em `(0,-48)` e escala 2, mirando nativamente para a direita sob o espelhamento existente de `Visuals`. Estados visuais: idle, walk (idle+walk), aim durante WINDUP, fire por até 120 ms somente depois de o projétil ser aceito e recovery durante RECOVERY. O controller continua autoritativo para estados/tempos (windup 650 ms, recovery 800 ms). Flash mistura pixels do BodySprite com `#FFF1C7`, alpha preservado; não afeta barras/alertas.

A integração estática será revisada pelo agente principal. Este estágio não executa testes nem abre/importa o Godot.

## Resultado da integração e revisão estática
Arte reproduzida e inspecionada no Aseprite; os dois sprites integrados às cenas com materiais de flash e poses ligadas aos estados existentes. Gemini/Muse concluídos sem bloqueios; Grok retornou exit0 sem parecer em duas tentativas do mesmo modelo e Opus indisponível por quota. [Saídas fiéis, decisões, hashes e limites](pareceres/README.md). Fontes/PNG/ASE preservados e cópias runtime idênticas. Sem Godot/import/testes/gameplay. Aparência em jogo ainda não verificada.

