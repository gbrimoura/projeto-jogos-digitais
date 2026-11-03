# Pareceres

Refinamento delimitado de layout e escala. Préflight único e revisão de implementação congelada serão registrados aqui. Não executar engine/testes nem alterar arquivos por revisores.

## Avaliação dos achados Muse R2 pelo principal

Muse confirmou fórmulas, anchors e configuração padrão sem P1. Seus seis P2 foram avaliados individualmente, sem convertê-los em bloqueios genéricos:

1. show_ball_gauge sem setter é comportamento anterior, conceito opcional oculto; esta tarefa não acrescenta controle dinâmico desse módulo.
2. enabled_changed é consumido pela bridge existente (_ready conecta _on_hud_enabled_changed), portanto não é contrato morto. O trecho completo de lifecycle não entrou no pacote por não ter sido alterado; root conferiu a fonte.
3. Chamadas .call entre módulos são a API existente, sem rename; as assinaturas já existem nas cenas preservadas. Guardas genéricas não são necessárias para uma alteração escopada de tamanho.
4. A proteção automática cobre colunas e pilha padrão, não posições arbitrárias do usuário. Na menoraltura324, módulo2 resulta em dash terminando172 e gauge238; rodapé debug começa266, sem sobreposição padrão. Em largurapequena o módulo2 cai a1. Valores calculados por leitura, não testes.
5. Rodapé é governado por _apply_layout antes do primeiro desenho (_ready e set_available_stage_size chamado pela bridge após ready). Fonte/scene completas têm todos os nós; guard-null é fail-safe para composição inválida, não um modo suportado de remover nós essenciais. Os offsets de cena coincidem com o estudo960×540.
6. Root.size é propriedade dirigida por set_available_stage_size; não há outro owner alterando-a na execução normal. Margens/posições e module_pixel_scale têm setters, referência tem invalidação e viewport size/stretch continuam monitorados. Edição arbitrária de Root.size no RemoteInspector não é API de redimensionamento desta HUD.

Nenhum desses pontos exige ampliar o sistema para esta solicitação; os limites estão documentados. Gemini R2 não apontou achados. Pareceres originais preservados, sem apresentar as restrições da revisão como testes realizados.

## Fechamento R2

Gemini3.8High/AGY: exit0, FINDINGSnone. Grok cursor-grok-4.6-xhigh-fast/Cursor: exit0, FINDINGSnone, parecer útil confirmando escala/anchors/ciclo de ready da apresentação. Muse1.3Contributor/OpenCode xhigh: exit0, semP1, seis observaçõesP2 avaliadas acima pelo principal; não exigem expansão ou alteração do layout padrão. Nenhuma correção adicional foi aplicada depois da revisão.

Opus Cursor claude-opus-5-5-high: exit1, ActionRequiredError por limite de uso, reset informado03/11/2026. Nenhum parecer de implementação, não substituído nem contado como aprovação. Préflight feito uma vez; disponibilidade em catálogo não equivale a quota de inferência.

Código permaneceu congelado emR2; hashes comprovam três fontes iguais ao snapshot e seis arquivos protegidos iguais à base. Validação foi leitura estática, sem executar engine/testes/parser/audit. Legibilidade/conforto visual em gameplay continuam sem conferência. Sem commit/push/troca de branch.
