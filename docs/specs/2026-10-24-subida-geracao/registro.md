# Registro — subida do Tranca-Lata e geração por orçamento

Pedido do usuário: permitir subida de plataformas e otimizar geração procedural de fases. Duas frentes Luna gpt-6-luna xhigh diagnosticaram somente leitura; depois implementaram sequencialmente, um escritor por vez. Fast/priority não confirmável. Root persistiu plano/spec antes de cada escrita, coordenou os contratos e inspecionou diffs. Nenhum teste, simulação, Godot, parser/linter ou QA foi executado por restrição do AGENTS.

## Subida
A física já suportava a primeira subida120 doFloor560→top440: apex=max(72,120+48)=168, dentro do limite192 e rise144. O problema confirmado era seleção de ponto de decolagem/retry: alternativa existia somente para descidas; tentativa de lado inválido em subida era bloqueada sem tentar pontos seguros próximos. Além disso, standoff76 da primeira plataforma208 e boundsFloor52..1100 podem invadir paredes64 para corpo±36.

O retry agora trata subidas e saltos de mesma altura com até7 posições, dentro dos bounds e deduplicadas: posição física atual, offsets±16/±32 e standoffs reais dos dois lados do destino. Todos passam plan_jump_to_from antes de serem armazenados. A lista avança em falhas sem reset por frame; exaure antes de blockededge/replan. Movimento até o ponto continua físico; plano é reconstruído na chegada e no PREPARE. Descidas conservam uma alternativa do lado oposto. Não se aumentou alcance/apex/velocidade/gravity e não se ignorou Player/parede/underside. Objetivo é perseguição em apoios superiores, sem sistema novo de waypoints autônomos. Ocupação física do pouso por um corpo pode corretamente impedir salto.

Alterado somente training_target.gd: estado de retry virou lista/índice e a função de retry foi generalizada. Solver e grafo de perseguição permaneceram byte-exatos. Ataques, dano, tempos, onda, sprites e física ficaram preservados.

## Geração
O gerador anterior escolhia vãos e larguras sem reservar todos os extras e podia rejeitar até32rotas, especialmente em contagens apertadas. A subida por sorteios independentes truncados em376 concentrava alturas no teto da faixa.

A nova versão calcula primeiro o footprint mínimo e o intervalo viável da primeira borda, respeitando spawn+38/grid8. Sorteia orçamento extra até a folga/capacidade e reserva uma unidade8quando disponível; distribui por2N−1slots de largura/vão, com Fisher-Yates usando apenas RNGlocal e reservas de capacidade sufixa. A quantidade extra é aleatória, evitando forçar o fim de toda rota ao limite direito ou saturar larguras/vãos. A subida total0..64 é sorteada em unidades8 e repartida entreN−1etapas, sem clamping no topo.

Uma candidata construída passa por _entries_are_safe; se recusada, mantém o fallback existente validado e erro fechado. API, seed usada, primary_index last/fallback_index first e preparação Main antesde_ready continuam iguais. Seed explícita reproduz a nova versão; não se promete compatibilidade do mesmo número com o mapa do algoritmo antigo. Seed0 continua randomizando apenas RNGlocal uma vez por layout. Não foi alterada seed/run/progressão no RunController.

Preservados: count fornecido pelas fixtures (atualmente3; técnico2..5), widths104..216 com mínimo160nafixture3, espessura24/grid8, gaps56..96, firstLeft208..256/top440, tops376..440monótonos, rise0..64, lastEnd<=980, corredor96, piso/parede/teto/portas/spawns/patrulha/combate/recompensa/HP/build. Para5plataformas o intervalo inicial se reduz por viabilidade208..232; não é nova regra de contagem doGDD. Alterado somente room_layout_generator.gd; Main/cenas continuam com a mesma validação.

## Evidências e limites
Snapshot inicial18arquivos, snapshot NAV intermediário e snapshot integrado R1 preservados;16protegidos idênticos porSHA. Diffs e entrada de revisão em histórico/pareceres. Ganho esperado é reduzir candidatas descartadas e repetição de fallback, não benchmark medido de carregamento/FPS. A busca de decolagem é limitada, mas mantém queries de segurança; não se promete que qualquer plataforma ocupada/bloqueada seja alcançável. Campos/índices/progressão e arte existentes não foram reconfigurados.

Revisões/decisão final em [pareceres](pareceres/README.md). Opus exato tentou a rodada mas está bloqueado porquota, semsubstituição. Sem commit/push/troca de branch, preservando trabalho local. Carregamento, jogabilidade e tempo real de execução continuam sem validação em engine.

## Fechamento R1
Gemini e Muse concluíram revisão estática sem bloqueios concretos. Observações de espera do stucktimeout, revalidação e fallback/margem foram avaliadas; nenhum código adicional foi alterado. Grok terminou exit0 com stdout em branco, semparecer útil; Opus exato bloqueado porquota, semsubstituição. Estado18/18 estável e16/16 protegidos intactos. As duas frentes Luna foram integradas sequencialmente e permanecem limitadas aos dois arquivos descritos. Sem Godot/testes/simulações/benchmark/commit/push.
