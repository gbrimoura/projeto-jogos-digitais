# Avaliação do agente principal — números dos upgrades

STATUS: done
SUMMARY: Labels EffectSummary abaixo de Description, tamanho 30 contra corpo 16, contraste ciano sobre fundo escuro e alinhamento central; descrições e valores separados nos recursos. Não identifiquei P1/P2 na leitura estática.
CHANGED_FILES: none nesta avaliação.
TESTS: leitura de seis fontes e comparação dos valores; nenhum teste/Godot/render executado.
RISKS: render no Godot pendente; textos de apresentação precisam acompanhar ajustes futuros de balanceamento.
NEXT_STEP: registrar os pareceres externos e validar visualmente quando solicitado.

Os três paths novos existem na cena; script usa arrays tipados e lê effect_summary antes de exibir. Labels usam mouse_filter IGNORE, mantendo cliques no Button; conexão de seleção/pausa/input permanece igual. Description reserva 58px, EffectSummary 40px e separação12px. Estimativa estática com ícone: 217px de conteúdo em254px úteis por cartão; painel438px contempla altura dos cartões278px, heading/dica e padding. Fonte30 dá prioridade aos valores sem substituir títulos22/corpo16. Valores de dano2, dash0.4 e bonus2 intactos. Inspeção visual não foi executada, conforme instrução do repositório.

