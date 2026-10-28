# Geração de salas com variedade e conexões verticais

Início: 27/10/2026. Integração: 28/10/2026. Estado: runtime R4 integrado; Gemini/Muse/Grok finais sem P1/P2. Opus indisponível por quota.

O usuário confirmou uma sequência linear de encontros que pode subir ou descer. A mudança mantém a quantidade atual de salas e a ordem de encontros comuns/chefe. Não introduz ramificações ou revisitas.

## O que mudou

- `room_run_layout.gd` prepara o percurso completo por andar antes de instanciar salas. Usa uma direção horizontal por andar e movimentos verticais limitados por coluna, impedindo reocupação de coordenadas por construção. Com pelo menos duas conexões, reserva uma vertical. As direções UP e DOWN são possíveis, sem obrigar toda run curta a ter ambas.
- Cada descritor contém seed de sala, família, coordenada, entrada, saída e posições das passagens. A entrada seguinte é oposta à saída anterior e compartilha sua posição transversal. A saída inferior fica do lado oposto ao spawn lateral, evitando queda automática ao liberar o combate.
- `RunController` resolve a seed da run uma vez e a mostra no HUD. `randomize_run_seed = false` permite reproduzir uma seed, inclusive zero. Seeds de salas e famílias são derivadas separadamente do sorteio da topologia.
- `room_layout_generator.gd` oferece cinco famílias: passarelas com três apoios, crista e vale com quatro, e escadas até o teto com quatro ou cinco. Varia larguras, vãos, alturas e posições com RNG local; a seleção evita repetir imediatamente uma família compatível.
- A geometria gerenciada usa plataformas de 16 px de espessura e preserva pelo menos 96 px livres sob os apoios mais baixos. As escadas terminam em y=160, alinhadas a uma abertura de 256 px centrada em x=248 ou x=904. Esses valores são parâmetros técnicos do protótipo, não decisões finais do GDD.
- `managed_room_topology.gd` prepara colisões, gates, contenções e recortes visuais correspondentes. Mantém o Floor original com um único collider durante o combate; somente depois da liberação substitui a faixa inferior por segmentos laterais quando a saída é DOWN.
- `ExitDoor` detecta o cruzamento orientado do centro da cápsula em X ou Y, sem E. `Main` mantém a revalidação deferred, lock, fade, regras de combate/recompensa e transferência de HP/build. Falhas recuperáveis de travessia vertical reposicionam o jogador dentro da sala.

## Validação de layout escrita no runtime

O preparo valida descritor, formas físicas, recortes, guardas, spawns, patrulha e suporte do Tranca-Lata antes de ativar a sala. A busca de alcance examina no máximo 12 pontos de decolagem por aresta e utiliza o MovementConfig do jogador, incluindo aceleração, gravidade e limite de queda. Testa obstáculos e teto, permite procurar outra trajetória após um bloqueio e considera os dois lados de descida de um apoio.

Os saltos e quedas exigem que o centro interpolado no cruzamento do topo esteja ao menos 22 px dentro das bordas. Uma variação cuja rota seja recusada usa o layout canônico da mesma família, que passa pelos mesmos validadores geométrico e físico. Se ele também falhar, a sala é recusada com diagnóstico; não há aceite silencioso de uma geometria inválida.

Essa lógica foi escrita e revisada estaticamente. Não foi executada no motor nesta tarefa.

## Escopo preservado

Foram alterados dez scripts de mundo, incluindo dois helpers novos. Nenhuma cena, sprite, textura, script do jogador, IA de inimigo, configuração de movimento, recompensa ou RunBuild foi alterada. O caminho standalone continua horizontal e mantém seu gerador legado; as novas conexões são usadas pela run gerenciada.

Snapshots locais foram feitos antes da escrita e após cada rodada. O trabalho preexistente sem commit foi preservado. Não houve stage, commit, push ou troca de branch.

## Delegação e revisões

GPT-6 Luna xhigh implementou e corrigiu, como único escritor de runtime. A interface não permite confirmar Fast/priority. O principal definiu contratos, avaliou pareceres e leu as fontes/diffs. Revisores trabalharam apenas sobre pacotes imutáveis e retornaram pelo stdout.

Gemini 3.8 Flash High e Muse Spark 1.3 xhigh produziram pareceres úteis. As rodadas corrigiram rejeição indevida de centros, offset da porta standalone, busca de salto interrompida cedo, seed estática, falta de variação interna, nomes indefinidos, guarda do fallback, margem de pouso e conflitos de locais aninhados.

Grok 4.6 retornou alguns pareceres de plano, mas não produziu texto útil nas revisões de runtime encerradas até R3. Não foi considerado aprovação. Opus 5.5 High via Cursor foi solicitado e bloqueado por quota; a tentativa complementar via Antigravity também atingiu quota. Seus pareceres de plano não substituem a revisão obrigatória de implementação via Cursor.

Estado final da revisão R4: Gemini, Muse e Grok sem P1/P2; 10/10 fontes revisadas estáveis e 31/31 arquivos protegidos intactos. Consulte `pareceres/README.md` e `registro.md` para o resultado consolidado, entradas, hashes e saídas originais.

## Limites de confirmação

Não foram executados Godot, importação, parser, linter, testes, QA, simulações externas ou benchmarks, conforme AGENTS.md. A revisão estática não confirma a sensação dos saltos, a apresentação em jogo ou o desempenho real do gerador.
