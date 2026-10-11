# Correção da importação do atlas

## Causa

Captura do usuário mostrou jogador invisível. Log existente godot.log: No loader found para res://assets/player/player-animations.png, seguido de falha em player_sprite_frames.tres e animações idle/walk inexistentes. PNG960x64 válido estava presente, mas sem .png.import e sem .ctex. Faltou importar o asset na integração anterior.

## Correção

Subagente GPT-6 Luna xhigh executou importação do editor instalado Godot4.7.2 via --headless --editor --path projeto --import, exit0 em15s. Não executou gameplay/testes. Gerou assets/player/player-animations.png.import com importertexture, CompressedTexture2D, UIDdudwa4p506lly, .ctex referenciado existente e filesystemcache atualizado. PNG permaneceu idêntico pelo SHA256 antes/depois; arte/scripts/scenes/resources não alterados. Editor existente preservado. Fast não confirmávelinterface.

Varredura também gerou sidecars históricos em docs/specs/2026-10-11-protagonista-dash/historico/pre-dash/player-animations.png.import e docs/specs/2026-10-11-protagonista-idle-walk/historico/correcao-pernas-v2/protagonista-walk-contact.png.import; arquivos originais preservados. Cache .godot/ é local ignorado por Git.

## Revisões

Preflight uma vez: Gemini3.8 Flash High viaAGY, Museopencode-go/muse-spark-1.3-contributor xhigh e Grokgrok-4.7-xhigh-fast viaCursor disponíveis. Todos revisaram somenteleitura metadados inline congelados e diagnóstico, sem ferramentas/testes/visualização; concluíram sem bugconcreto. Timeout ajustado a2min pelo escopo curto. Opusclaude-opus-5-5-high autenticado/listado, mas quota bloqueada no preflight; sem parecer ou substituição. Stdout fiel e hashes nesta pasta.

## Limites

Importação gerou erros de acesso a diretórios globais user:// e ./Godot/feature_profiles; import do projeto concluiu e ctexexiste. Não há validação gameplay. Parar a execução atual e iniciar novamente permite carregar a textura recém-importada; se editor ainda estiver com fallback em memória, reabrir projeto. Nenhum commit/push.
