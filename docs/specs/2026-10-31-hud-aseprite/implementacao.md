# Implementação — HUD Caldeira v1

## Entrega de arte

Kit nativo em `assets/ui/hud_caldeira_v1/`, produzido por GPT-6 Luna xhigh no Aseprite 1.3.18.6. A interface de delegação não permite confirmar Fast/priority; essa limitação foi informada. O principal coordenou pesquisa, contratos, inspeção visual e integração dos arquivos novos. Não há integração com o Godot nesta etapa.

A composição de autoria mede 576×324. Há prévias em escala inteira 2× e 3×, módulos separados e alternativa com instrumento no canto inferior direito. A aplicação final à tela 1920×1080 ainda precisa ser definida na integração; a prévia não comprova pixel perfect nessa resolução.

- Vida contínua com preenchimento independente e exemplo de valor atual/máximo.
- Dash com ícone, relógio cinza de 17 estados, frase e contador separado. A amostra pronta não mostra tempo restante.
- Painel fixo do inimigo com retrato original, nome e barra. A seleção do inimigo próximo da mira pertence à futura integração.
- Contador de andar/sala e instrumento da bola com nove posições de agulha. Aceleração permanece conceito sem unidade, fórmula ou regras físicas.
- Molduras 9-slice, fonte bitmap PT-BR, PNGs avulsos, atlas e metadados.

## Edição

`source/hud-composition.aseprite` contém a composição em camadas. Relógio e agulha têm fontes próprias com 17 e nove frames e tags normalizadas. O tempo de reprodução dessas fontes serve ao estudo, não à duração de uma ação. Componentes e retratos têm fontes separadas.

O gerador Lua redesenha e sobrescreve os arquivos gerados. Depois de editar manualmente uma fonte, salvar uma cópia e exportar com outro nome; não executar o gerador esperando preservar essas alterações. O README do kit explica esse fluxo.

## Correções de autoria

R2 retirou o tempo da amostra PRONTO, corrigiu a contagem de glifos de RECARREGANDO e esclareceu o risco de sobrescrita. R3 aplicou o setter oficial de paleta do Aseprite. R4 alinhou o retrato 32×28 do Tranca-Lata e a barra aos metadados, uniformizou padding de atlas, gerou o rótulo CONCEITO realmente em 74×15 e criou timelines e pivô inteiros consistentes.

Snapshots R1–R4, pacote de revisão e saídas originais permanecem nesta pasta. Quatro arquivos exploratórios foram mantidos após bloqueio automático da tentativa de remoção. Estão explicitamente fora da entrega curada em `export/manifest.json`; não houve nova tentativa de remover ou mover.

## Produção e preservação

A geração produtiva retornou exit 0 e HUD_GENERATION_OK; stderr e log de erro Lua estavam vazios. O principal inspecionou visualmente composição contextual, módulos e estado PRONTO. Não foram executados testes, Godot, importação, parser, linter ou auditoria automática.

Os hashes finais dos nove arquivos protegidos coincidem com a base anterior: Main, RunController, projeto, cenas, sprites e fundo original. As alterações locais anteriores ficaram preservadas. Não houve commit, push ou mudança de branch. Resultados dos revisores estão em `pareceres/README.md`.
