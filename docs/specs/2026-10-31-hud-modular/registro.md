# Registro — integração modular da HUD

Pedido autorizado: aplicar no Godot, de maneira modular, os elementos do kit Aseprite recém-gerado. Implementação concentrada em novas cenas/scripts e dois pontos existentes mínimos; dados reais substituem exemplos da prancha.

Produção delegada a GPT-6 Luna xhigh, sem confirmação de Fast/priority na interface. A primeira tentativa foi interrompida por quota antes de gravar; retomada após a janela informada com o mesmo modelo. O lote entregue foi congelado e revisado estaticamente. O principal coordenou contratos e correções de autoria por leitura, sem escrever código de implementação.

Arquivos adicionados: dez scripts e oito cenas em scripts/ui/hud e scenes/ui/hud. run_root.tscn ganha a instância persistente; MovementController ganha somente o getter puro da duração efetiva do cooldown. Main, RunController, cenas de sala, projeto e sprites anteriores mantêm seus hashes. Não houve commit, push ou mudança de branch.

Os ajustes ficam em scenes/ui/hud/hud_root.tscn. BallGauge é opcional e oculto, sem nova física. As salas standalone conservam a HUD antiga. Mensagens de erro, derrota, recompensa e transição continuam nos overlays existentes. A ligação nova oculta apenas os indicadores substituídos e restaura sua visibilidade ao ser desativada.

Não houve Godot/importação, testes, parser, linter ou audit. A verificação foi leitura estática de fontes e contratos, com comparação de integridade dos arquivos preservados. A aparência e o fluxo em runtime ainda não foram verificados. Pacotes, snapshots, hashes e pareceres originais estão nesta pasta; limitações de cada revisor em pareceres/README.md.

Fechamento: Gemini e Muse R1 sem achados concretos; Grok timeout10min sem parecer; Opus Cursor indisponível por quota. Código permaneceu R1. Limites e saídas originais no consolidado de pareceres. A implementação está aplicada aos arquivos da run, com runtime não executado.
