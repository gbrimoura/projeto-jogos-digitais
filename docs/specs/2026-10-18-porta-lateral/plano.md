# Plano — Porta lateral recortada na parede

**Data:** 18/10/2026  
**Estado:** implementação visual congelada; runtime sem verificação de engine, conforme última direção do usuário.  
**Branch/base:** `corrigir-sprites-salas-plataformas`, HEAD local `90b2e592bd70e1b2ff3e5828af8a9029031e1c66`, com alterações locais preservadas.

## Objetivo

Representar a saída/entrada como uma abertura horizontal recortada na parede lateral da sala, visualmente atravessando a faixa de 64 px em x=0..64 e x=1088..1152. A abertura vai de y=432 a y=560, termina no piso e alcança a borda externa do cenário. O painel landscape na parede de fundo da proposta anterior fica preservado como estudo descartado, sem uso em runtime.

## Estratégia visual

O helper existente `factory_wall_visual.gd` recebe exports `opening_top` e `opening_height`, com defaults que não cortam a parede. Nas instâncias de `Main` e `SecondRoom`, as duas paredes visuais omitem exatamente os pixels entre y=432 e y=560, recortando tiles em escala nearest; as paredes físicas não mudam. `SideDoorVisual` (`@tool`, somente desenho e exports) desenha no recorte um túnel escuro, ombreira/lintel discretos com cores já pertencentes à paleta de fábrica e um estado fechado no interior do túnel. O recorte exportado nas paredes tem default sem abertura; apenas as duas instâncias de sala habilitam o corte. Aberto revela o vazio; fechado mostra uma grade/folha atravessando a passagem. Nenhum painel frontal largo encobre a parede de fundo.

A raiz da saída permanece `(1040,522)` e o sensor continua 96×108. A saída visual fica no centro global `(1120,496)`; entrada `(112,522)` tem visual em `(32,496)`. Cada abertura lateral mede 64×128 e termina em y=560. A entrada fica fechada; a saída mantém sua apresentação Closed/Open e label existente. Física, área de alcance, E, sinais, transições e câmera ficam intactos: a leitura visual do buraco não promete uma travessia física nova.

## Etapas e validação permitida

1. Preservar cópias e SHA-256 do estado local dos helpers, cenas e script de porta em `historico/baseline-local/`.
2. Reproduzir somente a geometria visual no helper de parede e na porta; remover o sprite frontal 160×80 em uso.
3. Criar uma montagem estática curta baseada no atlas/paleta atual para inspecionar buraco lateral aberto/fechado antes de congelar.
4. Registrar os arquivos finais, hashes e limites; deixar revisão final para o principal.

Sem Godot, importação, testes, quality_audit, QA automatizado, edição de arte antiga, collider ou regra de gameplay, commit/push, alteração de branch ou mudanças externas. O principal cuida do índice e dos pareceres.