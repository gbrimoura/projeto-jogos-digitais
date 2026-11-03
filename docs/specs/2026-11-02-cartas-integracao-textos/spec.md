# Especificação — textos da integração de cartas

## Apresentação
Cada carta mostra título, condição/efeito em até duas linhas de 24 glifos e tópicos com estatísticas nomeadas. Até três linhas são permitidas para os tópicos depois da quebra automática. O badge NOVO ou EVOLUIR: NÍVEL n deve caber em 22 glifos.

## Semântica
- Impacto: aumenta o dano da bola.
- Motor: reduz a recarga do dash, mostrando os segundos derivados do helper real.
- Carga: rebater a própria bola carrega o próximo acerto; exibir o dano adicional e que vale para o próximo acerto.
- Pressão: cada parede aumenta o dano, com limite de paredes por bola mostrado.
- Mola: aumenta rebotes e duração total da bola.
- Dínamo: reduz o tempo restante de recarga do dash uma vez por rebatida; não implica efeito passivo.
- Chassi: aumenta vida máxima e recupera vida somente ao escolher.

Em NOVO, apresentar ganho nominal. Em EVOLUIR, usar valor atual > próximo para o mesmo atributo quando isso couber na área disponível. Todos os números são derivados dos helpers e recursos existentes, sem alteração de mecânica.

## Validação documental
Confirmar estaticamente o fluxo dos sete paths de ícone pelos recursos, UpgradeCatalog, UpgradeOffer e UpgradeCard. Conferir manualmente limites de copy e preservação por hashes. Nenhuma execução de engine, teste, parser, linter, auditoria, benchmark ou simulação.