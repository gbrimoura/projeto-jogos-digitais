# Revisões — identidade pixelada do lobby

## Coordenação
Escritor único GPT-6 Luna xhigh; Fast/priority não confirmável na interface. Preflight único confirmou autenticação e IDs exatos dos três revisores disponíveis. As skills pixel-art/Aseprite orientaram paleta/grade/fontes; a proibição do usuário a quality_audit/Godot/testes prevaleceu. Produção permitida exclusivamente no Aseprite real, com inspeção manual de PNGs. Baseline binária do visual e da cena anterior em historico/baseline, inclusive placa e letreiro locais anteriores.

## Plano antes da produção
Entrada plan-input.txt e hash preservados. Gemini3.8FlashHigh/AGYplan exit0 favorável com riscos de draw-order/paleta; MuseSpark1.3Contributor/OpenCodeplan xhigh exit0 coerente com normalização dos nomes de exports para resolução nativa; principal normalizou os nomes antes do GO. cursor-grok-4.6-xhigh-fast/Cursorplan exit0 vazio, sem parecer. claude-opus-5-5-high/AGYplan exit3 quota429, sem parecer.

## Produção e revisão visual
Aseprite1.3.18.6 gerou base576x324 e portas32x56, fontes ASE com camadas e estudos com personagem original. Root inspecionou as prévias1152x648, comparando fábrica existente/Player. Solicitou campo noturno opaco em y0..279 para evitar depender do clear-color do jogo; y>=280 permanece transparente. R2 foi aprovada visualmente antes da integração. A placa, texto, lâmpadas, chão e posições de portas foram preservados.

Root identificou integração inicial por Image.load/ImageTexture e coordenou Texture2D preload normal, sem executar import. [Documentação oficial Image.load](https://docs.godotengine.org/en/stable/classes/class_image.html#class-image-method-load) registra a limitação de leitura bruta em projetos exportados. Estado anterior preservado em history/r2-before-preload/.

## Implementação: rodada integral e delta final
Entradas inline imutáveis implementation-input.txt (script completo, Lua completo, núcleo do manifesto) e final-delta-input.txt; hashes preservados. Revisores somente leitura, sem ferramentas ou engine/testes.

- Gemini3.8FlashHigh/AGYplan: impl exit0 com aprovação condicionada à importação normal e notasP2; final exit0 APPROVED. Import é etapa normal futura do editor, não código a contornar com leitura bruta. Sugestão de executar headless/merge não foi seguida: não autorizados nesta tarefa.
- MuseSpark1.3Contributor/OpenCodeplan xhigh: impl exit0 HOLD com apontamentos avaliados abaixo; final exit0 ACCEPT FINAL DELTA, sem defeitos acionáveis após esclarecimentos e correção da API de paleta.
- cursor-grok-4.6-xhigh-fast/Cursorplan: impl e final exit0/stdout vazio; SEM PARECER, não são aprovações.
- claude-opus-5-5-high/Cursorplan: disponibilidade nesta tarefa retornou exit1 ActionRequiredError por quota até03/11/2026. Revisão obrigatória PENDENTE; sem substituição silenciosa e sem inventar parecer.

## Avaliação crítica dos achados
1. Aceito: aplicação de paleta ASE usava atribuição protegida por pcall que podia esconder erro. O implementador mudou para Palette(20), setColor e sprite:setPalette direto, conforme [API oficial Aseprite](https://aseprite.org/api/sprite#spritesetpalette); removeu duas duplicações inócuas e regenerou pelo Aseprite, exit0/stderr vazio. R3 preservado em history/r3-before-setPalette. Os3exports runtime permaneceram byte-idênticos, confirmado pelo root em r3-exports-preservation.json.
2. Rejeitado como defeito: exigência de20cores sobre toda a cena. A trava vale apenas aos novos exports; a placa/luzes/chão e o Player usam cores originais deliberadamente preservadas. Manifesto explicita scope new_runtime_exports_only.
3. Rejeitado como regressão: overdraw do piso até656 e laterais672 já existe na baseline, foi mantido por escopo. Estudo estático recorta1152x648. Não altera colisões nem encaixe do topo560.
4. Rejeitado: interpretação de bounds [21,7,23,50] como extremos. Formato é x,y,width,height; extremos inclusivos43,56, origem calculada88,223, pé223+56+1=280 nativo=560 mundo. Manifesto explicita formato e extremos para remover ambiguidade; não foi movido o personagem.
5. Marcadores de preview têm pequenas diferenças de paleta/decimação na prancha nativa; estudo1152 representa referências sem reamostrar. Não é captura do Godot nem garantia de correspondência de todos os pixels. Placa/lâmpadas continuam sobre o PNG no runtime.
6. Importação normal ao abrir o editor permanece operacionalmente necessária; não houve engine, import, teste de compilação ou export. Não apresentamos aprovação estática como confirmação de funcionamento no binário local.

## Preservação e limites
preservation-17.json confirma17/17fontes críticas intactas, incluindo cena/lógica do lobby, Controller, projeto, jogador, geração e HUD. final-products.sha256.json registra estado dos produtos. Produção final registrada em assets/environment/factory_v1/lobby_v1/source/aseprite-production-r3.*: exit0, stderr vazio. Sem Godot/import/testes/parser/lint/auditoria/simulação, commit, push ou troca de branch. Nenhuma limpeza de alterações locais. Integração limitada a lobby_visual.gd e ao novo kit de arte; runtime/aparência na engine permanecem não confirmados.
