# Movimento e leitura dos ataques

- Referência local de arte: protagonista, Tranca-Lata e Cospe-Rebite. A versão usa o contorno escuro, a máscara clara, o visor de alto contraste e o vermelho de segurança. O manômetro, o núcleo de pressão e os pistões preservam a identidade do Supervisor.
- Atlas de 16 poses em células de 96×96, duas linhas de oito. A segunda linha conserva as marcas de dano em cada ação, inclusive com o núcleo exposto. Fonte editável em Aseprite e Lua de geração junto ao atlas.
- A animação é sincronizada com os estados de combate: preparação de mira, recuo em cada rebite, elevação dos pistões durante a carga de purga, descarga, exposição do núcleo e transição entre fases.
- O corpo se desloca no gantry entre os ataques. A posição fica fixa da mira até o fim da rajada. A região das purgas continua definida pela arena. O piso, as plataformas, a porta e os eventos da luta continuam determinísticos.

## Verificação

Godot 4.7.2 executado na cópia isolada. A movimentação e as poses de aviso, tiro, purga e recuperação passaram nas seeds 42 e 4162699858. A seed 20261124 confirmou a purga baixa no chão e a segurança do chão na purga alta. Na seed 42, a run assistida chegou à 13ª etapa, derrotou o chefe e voltou ao lobby. A importação manteve o aviso preexistente de UID duplicado na cena de referência.

O atlas e o retrato passaram pela auditoria de pixel art. A arte, o deslocamento e os avisos foram conferidos com a viewport do jogo.

## Revisões

Snapshot F761A7D07167935C17E5A3D3470704EAE176BC8F2E08F6D3D8BE257A3AA08BDC. Muse Spark 1.3 Contributor xhigh retornou sem defeitos sustentados no diff fornecido. O OpenCode confirmou as ferramentas desabilitadas. O modelo e o esforço foram selecionados por CLI. O JSON não registra metadados independentes desse par. Pareceres Gemini pendentes por falta de isolamento confirmado. Pareceres Grok e Opus via Cursor pendentes por falha na autenticação da listagem de modelos. O modo Fast/priority do subagente não pôde ser confirmado.
