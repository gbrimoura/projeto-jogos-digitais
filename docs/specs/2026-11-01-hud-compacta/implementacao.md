# Implementação — HUD compacta

Somente scripts/ui/hud/hud_root.gd, scripts/ui/hud/run_hud_bridge.gd e scenes/ui/hud/hud_root.tscn mudaram. A arte dos painéis e a fonte continuam iguais; escala e distribuição reduzem a ocupação da sala.

A referência física da bridge passou de576×324 para960×540, sem alterar a resolução global. O tamanho lógico da raiz agora acompanha a área real disponível dividida pela escala inteira. A compensação de stretch e a translação visible_origin foram preservadas; a origem final é arredondada. A referência tem mínimo576×324, evitando configurações acidentais que ampliem a HUD excessivamente.

| Tela final | Escala anterior | Escala atual | Área lógica disponível |
|---|---|---|---|
|1920×1080|3|2|960×540|
|1152×648|2|1|1152×648|
|1280×720|2|1|1280×720|
|3840×2160|6|4|960×540|

Valores derivados das fórmulas, não medidos em screenshot ou runtime. Em1080p, um painel144×40 passa de432×120 para288×80: redução de1/3linear e5/9deárea, com pixels inteiros.

## Distribuição e ajustes

Vida/dash ficam na esquerda, alvo no centro superior, salas/instrumento na direita. A raiz usa toda a viewport; não fica num canvas menor centralizado sobre o combate. As posições exportadas mantêm sua referência de576px: offsets esquerdos, delta do centro e margem direita. A escala interna de módulos continua1 por padrão;2 ajusta alturas/pilha e recua a1 quando as colunas não cabem. O layout de estudo no editor é960×540.

show_debug_details=false: status normal exibe só a primeira linha e oculta ENCONTRO ATIVO/PREPARANDO ENCONTRO, mantendo mensagens úteis de sala limpa/saída/falha. Seed, contador textual de inimigos e build ficam disponíveis no modo debug. Isso não altera o contador de salas, vida, dash ou HP do alvo. Status normal ocupa uma linha discreta no rodapé; debug pode usar3linhas e build. Instrumento conceitual continua oculto por padrão.

Ajustar escala por scale_reference_size em ModularHud/bridge e margens/offsets em hud_root.tscn. Reiniciar a execução para carregar a nova composição e as novas propriedades. Nenhuma tela nova de configurações foi criada.

## Limites

Sem execução de Godot/importação, testes, parser, linter ou detector/audit pelo agente nesta tarefa, conforme AGENTS. A leitura e os cálculos de layout não comprovam conforto visual em gameplay. Resoluções menores que576×324 finais podem recortar o limite mínimo, mantendo os pixels em escala1. Mudanças manuais arbitrárias de posição podem causar sobreposição; o ajuste automático cobre a configuração padrão e a pilha/colunas do modo2, não um editor de restrições gerais.

Preservados gameplay, portas, geração, Main, RunController, project.godot, dados/lifecycle da HUD e assets do kit. Sem commit/push ou troca de branch. Implementação por um único GPT-6 Luna xhigh; Fast/priority não confirmável pela interface. Estado R2 congelado e pareceres em pareceres/README.md.
