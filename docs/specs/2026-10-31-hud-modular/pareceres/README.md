# Pareceres — integração HUD

Préflight salvo uma vez por ferramenta. Roteiro prospectivo aguardando descoberta read-only e confirmação do escopo antes de implementar. Cada rodada terá entrada imutável, hash, stdout/stderr e exit. Revisão não executa engine ou testes e não modifica arquivos.

## Rodadas de plano

R1: Muse, Grok e Opus AGY devolveram achados úteis, avaliados pelo principal. Gemini encerrou com stdout vazio, sem parecer. R2: Muse sem achados, Opus AGY com problema concreto de escala e notas de contrato; Grok encerrou com stdout vazio. R3: Gemini sem achados; Opus AGY sem P1 e com três notas P2 de implementação (CanvasLayer transform, monitoramento de stretch e guarda síncrona de pausa), encaminhadas ao Luna e incorporadas antes de congelar código.

As decisões R3 foram transmitidas prospectivamente pelo chat e registradas em decisoes-r3.md depois que o escritor congelou o lote. Não se atribui ao arquivo posterior o papel de plano anterior. Préflight único: IDs exatos e autenticação disponíveis; não garante quota de inferência. Para implementação, Opus Cursor claude-opus-5-5-high retornou ActionRequiredError por quota, reset indicado em03/11/2026, exit1 e nenhum parecer. Não foi substituído por Opus AGY: o parecer de plano não conta como revisão de implementação.

R1 de implementação permanece congelado para três revisores disponíveis; nenhum deles está autorizado a executar testes ou modificar arquivos. O principal conferiu preservação por hashes e avaliou código/nós por leitura, sem executar engine. A ausência de runtime deve constar na entrega.

## Fechamento da implementação R1

| Revisor | Escopo | Resultado |
|---|---|---|
| Gemini 3.8 Flash (High), Antigravity plan | Pacote completo congelado R1 | Exit0, STATUS done, FINDINGS none. Leitura estática, sem execução. |
| Muse Spark 1.3 Contributor, OpenCode xhigh plan | Pacote completo congelado R1 | Exit0, STATUS done, nenhum P1/P2 concreto. Leitura estática, sem execução. |
| cursor-grok-4.6-xhigh-fast, Cursor plan | Pacote completo congelado R1 | Timeout10min, stdout sem parecer útil. Wrapper PID40120 e descendentes verificados foram encerrados; sessão nativa encerrou -1. Saídas preservadas e timeout registrado separadamente. Não é aprovação. |
| claude-opus-5-5-high, Cursor plan | Pacote completo congelado R1 | Exit1, ActionRequiredError por quota; reset informado03/11/2026. Sem parecer, não substituído. |

Principal avaliou os retornos e manteve o código R1 congelado sem incremento adicional. Os dois pareceres úteis não apontaram correções obrigatórias. Muse relatou que o leitor limitou a linha longa de font.json a2000caracteres, portanto sua visão do JSON completo é limitada; o principal já havia lido o metadata completo do kit e não atribui ao revisor uma confirmação que ele não realizou.

Ressalva do principal à descrição de fallback em Gemini: o fallback legado implementado cobre metadata/atlas de fonte via carregamento seguro. Os demais PNGs são recursos obrigatórios das cenas e existem no kit; sua remoção poderia impedir o carregamento da cena, não se promete fallback genérico para qualquer arquivo ausente. Essa observação delimita o parecer e não exige alterar o kit congelado.

Os oito arquivos protegidos verificados mantêm hashes anteriores. run_root e MovementController têm somente as alterações autorizadas; novos scripts/cenas constam no snapshot e manifesto SHA-256. Nenhum Godot, importação, teste, parser, linter, detector ou audit executado. Runtime ainda não foi verificado. Sem commit/push/alteração de branch.

Estado: integração modular escrita e revisada estaticamente por Gemini/Muse; revisão obrigatória Opus pendente por indisponibilidade e Grok sem parecer por timeout. Não declarar aprovação unânime nem validação de execução.
