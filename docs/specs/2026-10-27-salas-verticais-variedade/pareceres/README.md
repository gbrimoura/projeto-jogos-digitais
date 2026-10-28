# Pareceres e evidências

## Estado

Runtime R4 integrado e congelado. Gemini e Muse encerraram R4 sem P1/P2 e confirmaram as correções e os contextos canônicos. Grok R4 também encerrou com parecer útil e sem P1/P2. Nenhuma execução de Godot, parser, testes, importação, linter, QA ou benchmark.

Os pareceres são evidência de revisão estática, não validação de compilação ou jogabilidade. O principal avaliou os achados e preservou discordâncias, falhas e saídas vazias; não há aprovação atribuída a modelo que não entregou parecer.

## Modelos e preflight

O preflight foi feito uma vez: Cursor autenticado e modelos `cursor-grok-4.6-xhigh-fast` / `claude-opus-5-5-high` presentes; Antigravity com Gemini 3.8 Flash High e Opus 5.5 High; OpenCode Go credenciado e `opencode-go/muse-spark-1.3-contributor` presente. Muse foi chamado com variante `xhigh` e agente `plan`.

Grok 4.6 segue a instrução explícita global fornecida pelo usuário, que prevalece sobre o 4.7 do AGENTS.md local. Não houve troca silenciosa. A implementação foi delegada a GPT-6 Luna xhigh; a interface não confirma Fast/priority.

## Plano

- R1: Muse, Gemini e Opus AGY identificaram contratos incompletos e conflitos físicos. O primeiro zigue-zague foi descartado e substituído por escadas progressivas.
- R2: Gemini e Muse permitiram avançar ao código; Opus AGY pediu corrigir a coincidência de entrada/saída inicial e a validação da rota de saída com gate aberto após clear.
- R3: Opus AGY confirmou o fechamento dessas duas pendências. O principal manteve sensor no centro real da cápsula e a ordem de integração do controlador existente.
- Grok: R1 vazio; R2 trouxe objeções à decolagem em corrida na borda. O principal demonstrou por leitura e contas que existem decolagens internas e velocidades permitidas; o contrato exige uma rota possível, não segurança para todo input. Delta R3 solicitado, mas retornou sem texto útil. A discordância original e sua avaliação foram preservadas.

Nas primeiras chamadas AGY houve bloqueio da permissão de comando em modo não interativo. Conteúdo inline e proibição de ferramentas resolveram a leitura do plano, sem alterar permissões. Os arquivos iniciais com stderr e sem parecer permanecem guardados.

## Implementação

| Rodada | Gemini | Muse | Grok | Opus |
|---|---|---|---|---|
| R1 | Leitura integral; early return, direção pelo centro do piso e seed estática | Achados correspondentes e observações de validação | Exit 0, sem texto útil | Cursor: quota; suplemento AGY: quota 429 |
| R2 | Confirmou correções R1; identificou nomes indefinidos no helper | Mesmo P1 e paridade dos centros | Exit 0, sem texto útil | Indisponibilidade já demonstrada; não repetido |
| R3 | Quatro correções confirmadas, sem P1/P2 | Concordou com o delta, pediu contexto canônico/chamador | Exit 0, sem texto útil | Indisponível |
| R4 | Sem P1/P2; corrigidos conflitos de locais, contexto fecha pendências | Sem P1/P2; contexto fecha as duas pendências R3 | Parecer útil, sem P1/P2; contexto e delta confirmados | Indisponível |

### Avaliação dos achados

R1 corrigiu rejeição indevida dos centros de plataformas com largura104, offset da porta standalone, interrupção da busca no primeiro bloqueio, seed global, falta de variação interna e validação de obstáculos. R2 refez a busca com até12 pontos e dados de movimento, retorno seguro e fallback físico.

R3 corrigiu nomes indevidos em `managed_room_topology.configure`, guarda geométrica no caminho canônico, snap dos centros e pouso interpolado com inset22. R4 corrigiu duas redeclarações em bloco filho de Main; a regra foi conferida na fonte oficial do Godot, sem executar o parser. A documentação e os pareceres distinguem os limites reais do retângulo e a faixa que já recebeu o inset.

A alegação Muse R1 de ciclo RIGHT/DOWN/LEFT/UP foi rejeitada: o construtor escolhe um único sentido horizontal por andar e limita o movimento vertical por coluna. A declaração de ausência de ciclos decorre dessa construção, não de um teste executado.

### Indisponibilidades

Cursor Opus `claude-opus-5-5-high` retornou ActionRequiredError por limite de uso, com reset informado em03/11/2026. O suplemento com o mesmo modelo no Antigravity retornou `RESOURCE_EXHAUSTED`/429. Não houve substituição, alteração de plano pago ou aprovação fictícia. Os pareceres de plano via AGY não cumprem a exigência de revisão de implementação via Cursor.

Grok retornou saídas vazias nas rodadas de runtime encerradas atéR3. Algumas tentativas Cursor registraram erro do auto-updater em `.promote-lock`; esses erros foram preservados, sem modificar locks, versões ou autenticação.

Para Gemini R1 foram preservadas duas tentativas de transporte sem parecer (flag `--print` e esquema de stdin). A leitura integral por `view_file`, sem executar comandos, produziu o parecer útil. Rodadas finais usaram texto inline menor e imutável.

## Artefatos

- `runtime-r1/` a `runtime-r4/` em `../historico/`: fontes congeladas e manifestos SHA256.
- `runtime-rN-input.txt`: entrada exata de cada revisão. `input-sha256.json` registra seus hashes.
- `*.stdout.txt`, `*.stderr.txt`, `*.exit.txt`: saídas originais, sem reescrita.
- `../historico/runtime-rN-diff.txt`: mudanças entre rodadas; nenhuma comparação usa HEAD como baseline do trabalho local.
- `../historico/base/`: fontes locais antes desta tarefa; `protected-*.json`: preservação das áreas fora de escopo.

O resultado final e a integridade estão em `../registro.md` e nos manifestos finais.

## Encerramento

R4 aceito pelo principal após Gemini/Muse/Grok sem pendências. Integridade final10/10 fontes e31/31 protegidos, entrada R4 SHA5D5EDF5A186C4A7E24A7169862FF31B4E5456B77AFD6B12C6A104BF8E4A7C9CC inalterada. Opus sem parecer por quota; sem Godot/testes. Detalhes no registro.
