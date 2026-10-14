# Especificação — inimigos cartoon V2

**Estado:** arte concluída; contato final aprovado pelo agente principal em 14/10/2026. A etapa atual encerra sem integração de runtime.
**Data:** 14/10/2026.
**Referência:** `../../../../GDD_Dieselpunk_Noir/pitch-assets/inimigos-cartoon-v2/referencia-inimigos-cartoon-v2.png` (1983×793; manter inalterada).

## Direção visual

A nova prancha, gerada por ImageGen e aprovada pelo principal como direção, substitui a estética realista da V1 para esta reprodução. TrainingTarget é um alvo robusto com cabeça marfim maior que o tronco, olhos/visor laranja angulares e um único tubo espesso ancorado na base. RivetWorker tem capacete vermelho com aba larga, face marfim visível, luvas e botas grandes e uma pistola de rebites curta, sempre conectada à mão. Usar três tons organizados por material e clusters claros; evitar ferrugem salpicada, noise e textura excessiva. A silhueta deve ler como cartoon no tamanho 64×64 e em comparação 4× com o frame 0 atual do protagonista.

O agente principal inspecionou e aprovou o contato final. A integração é uma etapa subsequente e deve manter o runtime inalterado além da substituição dos quatro arquivos PNG/ASE correspondentes.

## Formato e registro

- Oito cels de 64×64 com alpha binário, Aseprite fonte e nearest uniforme: três quadros do alvo e cinco do trabalhador.
- TrainingTarget: ordem idle/impacto/desativado; aproximadamente 8 px de origem por pixel nativo; centro x=32 e edge-baseline y=56 em todos os quadros. Corpo nominal 35–36×44–45 nativo. Collider runtime 72×96 permanece apenas como referência e não é alterado.
- RivetWorker: ordem idle/andando/mirando/disparo/recuperação; aproximadamente 8 px de origem por pixel nativo; body nominal 23×32, pés com edge-baseline y=56 e facing nativo para a direita. Mirando/disparo devem manter a boca em (43,38)±2 px nativos e ferramenta conectada à mão. Collider runtime 46×64 permanece apenas como referência.
- Um nearest por personagem, sem bilinear/dither; 14 cores-base existentes mais o swatch `#FE5B01` amostrado e restrito aos visores laranja, máximo observado de 15 cores opacas por frame. O flood-fill remove somente fundo neutro conectado às bordas; preservar o contorno azul-preto (#00000D) e não deixar placas de fundo retangulares.
- Timings exportados são metadados visuais, não regras. Os nomes/ordem seguem os recursos V1; nenhum recurso runtime é editado agora.

## Entregáveis e escopo

Diretório novo `GDD_Dieselpunk_Noir/pitch-assets/inimigos-cartoon-v2/`: `README.md`, `reproduzir-inimigos-cartoon-v2.lua`, `training_target-cartoon-v2.aseprite`, `training_target-cartoon-v2-atlas.png`, `rivet_worker-cartoon-v2.aseprite`, `rivet_worker-cartoon-v2-atlas.png`, `metadata-inimigos-cartoon-v2.json`, `protagonista-idle-comparacao.png` e `contact-inimigos-cartoon-v2-4x.png`. A metadata registra crops, bounds, timings, muzzle, paleta, dimensões e hashes.

Não alterar referência, V1, scripts/cenas/recursos/runtime, paletas/fontes de jogo, colisores, IA, temporizadores, HP, projétil, entrada, salas ou `project.godot`. Não importar nem executar Godot, gameplay, testes, QA ou auditoria. Sem Git/commit/push/branch/publicação. O agente principal aprovou visualmente `contact-inimigos-cartoon-v2-4x.png`; nenhuma alteração runtime foi feita.

## Baseline

Snapshots e hashes anteriores à reprodução V2 ficam em `historico/base/`. Eles registram o runtime atual sem modificá-lo; cópias V1 devem permanecer byte-idênticas.
