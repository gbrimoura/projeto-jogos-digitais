# Registro — portas, 31/10/2026

Pedido: remover labels de entrada/saída, indicar saída liberada com setas pixeladas e melhorar a aparência de entrar pela porta aberta.

Luna fez leitura inicial e confirmou uma causa visual plausível no alçapão: o desenho inteiro ficava acima do personagem, enquanto o cruzamento físico ocorre pelo centro do collider. Root manteve os contratos de colisão e travessia e autorizou apenas apresentação. Gemini/Muse/Grok/Opus AGY revisaram o plano; os achados de camadas, direção, índices e feedback foram encaminhados antes da escrita. Uma reconfirmação de Opus AGY foi bloqueada por quota429, sem parecer.

Luna produziu cinco arquivos existentes e dois helpers novos. Root congelou R1 e pediu R2 restrito à posição das setas verticais, que antes apontavam ao lado do vão. R2 ficou congelado para revisão estática dos quatro modelos exatos, sem execução de engine. A revisão não equivale a confirmação visual em jogo.

Os hashes de Main, RunController, topology, MovementController e run_root coincidem com a base atual preservada. As duas cenas de sala tiveram apenas seus overrides de DoorLabel alterados. Mudanças locais anteriores permanecem. Nenhum commit, push, reset, stage ou troca de branch.

Incidente de autoria: um apply_patch com caminho duplicado criou um arquivo vazio fora do repo. A limpeza foi bloqueada automaticamente antes de executar; o residual segue fora do projeto e sem uso. Não houve repetição, remoção ou movimentação alternativa. Ver plano e consolidação dos pareceres para detalhes.

Fechamento R3: Gemini/Muse confirmaram por leitura o ajuste de espelhamento do fundo, sem achados remanescentes no delta. Grok R2/R3 sem saída útil; Opus Cursor quota, sem parecer. Nenhum teste/Godot executado por solicitação do agente nesta tarefa. O código foi aplicado e o visual em execução permanece sem conferência.
