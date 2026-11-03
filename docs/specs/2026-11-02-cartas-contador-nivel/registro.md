# Registro — contador de nível das cartas

Estado inicial da frente. O plano e a especificação foram criados antes das edições. A baseline dos oito alvos autorizados está em `historico/baseline/`; `historico/baseline-sha256.csv` registra seus hashes SHA-256. A implementação deve limitar-se ao escopo descrito em `plano.md` e `spec.md`.

A prévia inicial foi inspecionada manualmente para orientar a preservação da arte e do rodapé existente. A produção deverá usar Aseprite real somente com `preview_only=true`, sem limpar nem regenerar molduras. Revisão obrigatória final e integração do registro pelo agente principal, após congelamento.

## Resultado integrado
O rodapé agora mostra status NOVO/EVOLUIR, adicionando - MÁXIMO quando a escolha completa o upgrade. A segunda linha mostra NÍVEL atual > ofertado / máximo, com apenas o nível ofertado em amarelo. Status normal ciano e máximo amarelo; níveis atual/máximo e separadores cinza. A moldura e tamanho da carta permanecem iguais. O máximo vem de max_rank_for(id, baseHP), respeitando limites atuais, inclusive Chassi dinâmico e tetos técnicos provisórios 220 sem rebalanceamento.

Prévia Aseprite: Carga 0>1/220, Mola 1>2/3, Dínamo 2>3/3. Tópicos do Dínamo atualizados no estudo para redução 0,3s>0,45s coerente com o rank oferecido. Root inspecionou PNG. Saída do processo Aseprite não capturada, sem alegação exit0. Três revisores concluíram sem bloqueios; Opus pendente por cota. Sem Godot/testes/commit/push. Veja pareceres/README.md.

## Referências de apresentação consultadas pelo principal
Pesquisa solicitada pelo usuário: níveis máximos de Vampire Survivors (https://vampire-survivors.fandom.com/wiki/Weapons) e tiers de armas de Brotato (https://brotato.wiki.spellsandguns.com/Weapons). A hierarquia compacta orientou a decisão de design, não a cópia de assets, regras ou limites. O formato atual > próximo / máximo é uma adaptação para as cartas deste projeto.
