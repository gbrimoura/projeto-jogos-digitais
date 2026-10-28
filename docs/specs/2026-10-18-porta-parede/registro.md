# Registro — Porta horizontal embutida na parede

O usuário esclareceu “Desenho deitado, mais largo que alto” e “tem que ser na parede”. A orientação do desenho é landscape, com asset embutido num painel de parede ao fundo junto à lateral. A proposta retrato 32×64 foi descartada como arte final e preservada em `historico/proposta-orientacao-anterior/`.

Geometria final autorizada: painel 160×80 por estado; porta embutida 128×64 em `(16,8)`; sheet horizontal 320×80, HFrames 2; escala 2×; sprite em z=-2 atrás de floor, parede visual e atores. Saída visual centro `(960,496)` com raiz de interação `(1040,522)`; entrada visual centro `(192,496)` com raiz `(112,522)`. A porta não corta a parede física.

Referência horizontal V2 foi recebida e copiada para `assets/environment/factory_v1/door/referencia-porta-horizontal-v2.png`; o prompt exato está em `imagegen-prompt-horizontal-v2.txt`. O prompt vertical `imagegen-prompt.txt` permanece imutável como histórico e não é arte final. A arte final usa Lua editável/Aseprite, PNG runtime, preview 4× e montagem estática de parede+piso+player.

Decisões incorporadas após leitura dos pareceres de plano: preservar sensor E em 96×108 no x=992..1088, com prompt/indicador localizados junto a ele; não ampliar sensor nem alterar física. A porta aberta deixa vão de 48 px nativos livre e recolhe lâminas telescópicas em bolso dentro do batente, sem folha estacionada na margem externa de 16 px. O painel opaco usa emendas do atlas e fica atrás da faixa visual da parede e do piso (painel z=-2, parede z=-1, piso z=0, protagonista z=1). Entrada usa espelhamento horizontal para orientar o bolso à parede lateral; continua sempre fechada em runtime.

Snapshots/hash do estado local anterior em `historico/baseline-local/`; decisão horizontal em `historico/steering-horizontal-v2.txt`. Nenhum teste, QA, Godot, import, commit ou push.

## Implementação congelada

A folha final `assets/environment/factory_v1/door/porta-fabrica-horizontal-v2.png` tem 320×80 px, dois frames de painel opaco 160×80, porta integrada 128×64 e abertura livre 80×48 nativos. Fonte Aseprite/Lua, preview 4×, composição estática e hashes estão documentados em `assets/environment/factory_v1/door/README.md` e `manifest.json`. Inspeção visual estática confirmou os dois estados nas duas extremidades, integração com parede/piso e protagonista em primeiro plano; não é captura de engine.

A cena reutilizável troca os stand-ins vetoriais por `DoorArt` e atualiza somente o frame/label conforme os estados já existentes. O sensor, lógica E, sinais, guards, terminais, parede física e colisões foram mantidos; `Main`/`SecondRoom` recebem apenas overrides visuais. O principal observou metadados `.import` na pasta; não foram criados, editados nem importados pelo implementador. Nenhuma engine, import, teste ou QA automatizado foi executado. Hashes do baseline local anterior seguem em `historico/baseline-local/`.
Correção R2: o Lua agora resolve o prefixo de saída padrão a partir de `p.root` (`p.out` continua sendo override), em vez de depender do diretório de trabalho atual. O hash atualizado do script está em `assets/environment/factory_v1/door/manifest.json`; nenhuma arte exportada foi regenerada.
Consolidação do principal: Gemini/Grok R1 revisados; correção pontual do caminho Lua aplicada e R2 sem defeito concreto remanescente no delta. Opus Cursor quota, Muse API expirada, Opus AGY bloqueio de ferramenta: sem parecer desses revisores. Fontes/hashes e decisões em pareceres/README.md. Sem Godot/importação/testes/QA/commit/push. Alterações locais anteriores preservadas.
