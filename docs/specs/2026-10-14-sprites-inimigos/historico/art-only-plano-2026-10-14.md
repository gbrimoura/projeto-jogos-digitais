# Plano — sprites dos inimigos

**Estado:** reprodução de arte em andamento; ainda não integrada ao Godot.  
**Data:** 14/10/2026.

## Objetivo

Reproduzir no Aseprite a prancha de referência confirmada pelo usuário para esta reprodução inimigos-referencia-v1/referencia-alvo-rebiteiro-v1.png para os placeholders TrainingTarget e RivetWorker. Esta frente termina com fontes, PNGs, metadata e comparações exportadas. Não houve aprovação estética explícita da prancha; o agente principal inspecionará a arte congelada antes de decidir qualquer integração.

## Método

- Usar Aseprite 1.3.18.6 e Lua reproduzível para abrir a prancha, isolar cada personagem, remover fundo conectado e texto, reduzir por nearest com um único fator por inimigo e quantizar à paleta industrial existente.
- Preservar os desenhos e sua identidade. Não desenhar uma alternativa procedural nem usar a imagem grande como textura runtime.
- Exportar cels 64×64, atlas, arquivo editável Aseprite, metadata com bounds/tempos e contact sheets ampliados por nearest. Comparar o TrainingTarget idle com a cópia do idle do protagonista em escala correspondente.
- Não alterar scripts, cenas, recursos, fontes ou imports do jogo. Não importar no Godot, rodar gameplay, QA, testes ou auditorias.

## Alvos de arte

TrainingTarget: 3 quadros (idle, impacto, desativado), sprite nativo 64×64, corpo nominal 36×48, collider atual 72×96, base fixa em y=56. Transformação de referência e baseline constantes entre quadros. O estado desativado é somente arte; a lógica atual continua removendo inimigo letal imediatamente.

RivetWorker: 5 quadros (idle, andando, mirando, disparo, recuperação), sprite nativo 64×64, pivô de base (32,56), corpo nominal 23×32 e collider atual 46×64. A arte olha para a direita. A ferramenta permanece conectada à mão; sua boca nominal é (43,38) no frame em 64×64, tolerância estética de 4 px. O rig pode articular o braço sem redesenhar a identidade. Poses idle e recuperação mantêm a mesma pegada; intermediárias de caminhada são derivadas da referência.

## Limites desta frente

Nenhum runtime ou regra de gameplay. Manter geometria e tempos existentes. Disparo visual só depois de aceitação do projétil; flash letal atual permanece imediato. O timing de IA permanece windup 650 ms e recovery 800 ms. Nenhum ajuste de colisão, alcance, spawn ou boca física.

## Estado-base

Snapshots dos dois scripts e duas cenas estão em historico/base/; hashes SHA-256 dos arquivos protegidos de protagonista, piso, sala principal e sala secundária estão no mesmo diretório. O workspace tinha alterações anteriores do usuário; elas foram preservadas.

