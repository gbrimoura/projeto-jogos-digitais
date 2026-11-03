# Especificação — contador de nível e teto

## Dados
- `card_preview` continua rejeitando upgrades inválidos ou indisponíveis usando a lógica existente.
- Apresentar `rank_before`, `rank_after` e `rank_max`, sendo `rank_max` derivado de `max_rank_for(upgrade_id, base_maximum_health)`.
- Status base `NOVO` quando rank atual é 0; caso contrário `EVOLUIR`. Se o rank ofertado atingir `rank_max`, acrescentar ` - MÁXIMO`.
- O contador é sempre `NÍVEL {rank_before} > {rank_after} / {rank_max}`. É informação de apresentação; não modifica oferta nem aquisição.

## Geometria e cor
- Mantém cartão e moldura 160×240 e os controles do rodapé dentro da caixa existente.
- Status: x=12..148, y=205..216, altura 12 px, centralizado. Ciano para status normal, amarelo para status que atinge o máximo.
- Contador: x=12..148, y=217..228, altura 12 px, centralizado. Prefixo `NÍVEL `, nível atual, espaços, seta e ` / MÁXIMO` em `#B6BEC3`; apenas o rank alvo em `#D2A75C`.
- Fonte bitmap atual: glifos 5×11, avanço 6 px, line-height 12 px; sem antialias.
- Comprimento máximo relevante: `NÍVEL 219 > 220 / 220` = 21 glifos = 126 px dentro de 136 px.
- Não cobrir ou reposicionar ícones, título, resumo, tópicos ou divisórias existentes.

## Estudos Aseprite
Três cartões no preview: Carga Reativa rank 0→1 de 220; Mola de Retorno rank 1→2 de 3; Dínamo de Defesa rank 2→3 de 3. O Dínamo usa a comparação atual `REDUÇÃO: 0,3S > 0,45S`. Mostrar status e contador em duas linhas do rodapé, com o mesmo alinhamento e hierarquia da integração. Gerar apenas os dois PNGs de estudo com `preview_only=true`; não ativar `clean_frames`, não regenerar molduras, fontes, ícones ou contato.

## Validação permitida
Inspeção visual manual dos dois PNGs em escala nativa/ampliada e revisão estática de preservação do escopo. Nenhum comando de engine, testes, parser, linter, auditor, detector ou simulação.
