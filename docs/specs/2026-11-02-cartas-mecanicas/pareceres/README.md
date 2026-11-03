# Revisões estáticas — cartas mecânicas

Préflight único autenticado, modelos exatos disponíveis: Gemini 3.8 Flash (High), Cursor cursor-grok-4.6-xhigh-fast (preferência global), Muse opencode-go/muse-spark-1.3-contributor xhigh e Cursor claude-opus-5-5-high. Saídas de preflight preservadas em preflight-0/1/2.json (incluindo truncamento original do catálogo Cursor). R2 congelado em review-input.txt; R3 em review-delta.txt, fontes e hashes preservados no histórico.

## R2
- Gemini: exit 0, encontrou largura negativa na metade esquerda de oval_band, oclusão de contornos/reflexos entre camadas, 12 cores no ícone pressão contra limite de 10 e omissão do contato nativo no manifesto. Root confirmou no fonte e encaminhou correções a Luna.
- Muse xhigh: exit 0, encontrou orçamento de cores e manifesto; observações sobre luz, volante e chama avaliadas pelo root. Corrigida luz do motor; carga tem tampas de materiais distintos, volante tem aro estrutural e chama é efeito intencional. As classificações de gravidade dos revisores são opiniões, não instruções.
- Grok: exit 0 com stdout e stderr vazios. Não é parecer nem aprovação.
- Opus exato: exit 1, ActionRequiredError por limite de uso, renovação indicada em 03/11/2026. Não substituído; revisão obrigatória continua pendente.

## R3
Gemini e Muse receberam o delta inline imutável, sem ferramentas, comandos ou alterações, timeout de 5 minutos. Ambos exit 0 e confirmaram correções sem bloqueios remanescentes. Saídas originais em r3-gemini.* e r3-muse.*. Gemini escreveu equivocadamente que PNGs foram aprovados pelo usuário: a inspeção visual foi do agente principal; o usuário ainda não avaliou esta versão. Nenhum parecer constitui avaliação estética do usuário.

Root inspecionou diretamente contato e prévia das cartas e confirmou preservação por SHA-256 de 9 arquivos protegidos (código de apresentação, cenas, molduras e fontes), em protected-preservation.json. Aseprite foi usado para produção, exit 0. Não houve Godot, imports, testes, auditorias, parsers, linters ou simulações. Alterações locais e branch preservadas; sem commit/push. O produto está atualizado nos caminhos já referenciados; a revisão Opus permanece pendente por indisponibilidade.