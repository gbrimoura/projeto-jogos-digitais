# Registro — cartas mecânicas

## Resultado R2
Os sete ícones foram redesenhados no gerador Aseprite canônico, preservando os IDs e caminhos, grade nativa 64×40 e exportação 2× para PNG 128×80. As fontes ASE continuam em 128×80 com camadas ampliadas, como no contrato existente. O resultado usa objetos industriais cartoon com contorno de 1 px nativo, volume por material e realces comuns no alto à direita.

A prancha final tem bola metálica com rebites; propulsor com bocal, fendas de ventilação e chama; bobina com núcleo e faísca; válvula com manômetro; mola comprimida de voltas ovais metálicas entre bases; gerador com volante lateral; e placa de blindagem com rebites e painel central discreto. Não foram usados os motivos bola+raio, raquete+relógio, coração ou relógio sobreposto.

O principal inspecionou o contato R2 e considerou a composição pronta para revisão estática. Isso registra a checagem visual do root, não uma aprovação estética do usuário nem um parecer externo.

## Artefatos alterados
- assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua
- Sete fontes .aseprite e sete PNGs existentes sob assets/ui/upgrade_cards_v1/source/ e assets/ui/upgrade_cards_v1/export/.
- Contato nativo/ampliado e estudos de três cartas nativo/3× sob assets/ui/upgrade_cards_v1/preview/.
- assets/ui/upgrade_cards_v1/README.md
- assets/ui/upgrade_cards_v1/export/manifest.json
- Este diretório de plano, spec, registro, snapshots e pacote de revisão.

Fontes do HUD, acréscimos de fonte, molduras, arquivos .import, integração geométrica, código/cenas e comportamento das cartas não foram editados. As versões substituídas dos 21 arquivos estão copiadas em historico/r0-baseline/; files.json registra tamanho e SHA-256 originais. historico/r2-final-files.json registra tamanho e SHA-256 dos equivalentes finais.

## Produção e validação permitida
Aseprite 1.3.18.6 executou o gerador com saída 0 em R2. Saída está em assets/ui/upgrade_cards_v1/source/mechanical-production-r2.stdout.log; stderr está no arquivo de mesmo prefixo com sufixo .stderr.log. Os PNGs e o contato foram inspecionados diretamente. R1 e os logs vazios da tentativa inicial foram preservados em arquivos separados, sem sobrescrever logs antigos.

Não houve Godot, importação, teste, parser, linter, auditoria, simulação ou alteração de gameplay. Revisões estáticas globais serão executadas pelo agente principal depois de receber este pacote congelado. Nenhum resultado de revisor foi presumido ou incluído.
## Incremento R3 — correção do parecer parcial
Preservado o estado R2 antes de editar em historico/r2-pre-review-fix/ (gerador, sete fontes ASE, sete PNGs, quatro previews e manifest, 20 arquivos com hashes). A correção de paleta reduz pressão de 12 para 10 entradas: substitui o contorno creme do mostrador por marfim e o pixel vermelho-escuro do cubo por vermelho, mantendo a sombra cobre-escuro do corpo e a leitura do manômetro. No motor, as tampas laterais foram trocadas para respeitar a luz: esquerda steelLight, direita silver. A lista de prévias agora inclui o contato nativo 432×352, tanto no template Lua quanto no manifest exportado.

Aseprite 1.3.18.6 regenerou os arquivos com saída 0. Logs R3: mechanical-production-r3.stdout.log e mechanical-production-r3.stderr.log. O contato R3 foi inspecionado. A resposta delimitada, apenas com funções afetadas, manifest e hashes R2/R3, está em pareceres/review-delta.txt; o pacote R2 imutável não foi alterado. Nenhum teste, engine ou auditoria foi executado.
### Correções finais Gemini/Muse antes do freeze R3
O R2 pré-revisão permanece preservado em historico/r2-pre-review-fix/. Antes das correções finais, o candidato R3 também foi preservado em historico/r3-pre-gemini-fix/ com seus 20 artefatos e hashes, além do delta intermediário.

Resolvidos os defeitos estáticos concretos: oval_band calcula a largura esquerda com outer_half - inner_half e mantém o furo; rebites agora desenham contorno, metal e glints na camada superior em ordem; anéis da bobina Carga, painel do chassi, cubo do volante e marcas do manômetro também são desenhados sobre suas bases. As duas correções de paleta e o swap de luz do motor do incremento R3 anterior permanecem.

Aseprite 1.3.18.6 regenerou as fontes, PNGs, contatos e prévias finais com exit 0. Logs: mechanical-production-r3-final.stdout.log e mechanical-production-r3-final.stderr.log. O principal inspecionou o contato final; sem clipping relevante. O pacote R3 para revisão é pareceres/review-delta.txt (14.729 caracteres), com brief/resoluções, somente helpers e funções afetados completos, manifest e hashes R3 intermediário/final. O pacote R2 review-input.txt continua intocado. Nenhum teste, engine ou auditoria foi executado.
## Fechamento da rodada
R3 corrigiu os achados estáticos do gerador: espiras simétricas, detalhes na camada superior, pressão com dez cores e manifesto completo. Gemini/Muse R3 sem bloqueios. Grok R2 sem parecer; Opus pendente por cota até 03/11/2026. Root conferiu contato/cartas e 9 hashes protegidos. Sem execução de jogo/testes, commit ou push. Veja pareceres/README.md para os limites e saídas fiéis.
