# ONYX Dispatch

Recurso de dispatch para FiveM, instalado como `onyx_dispatch` em `resources/[standalone]`.

## Estrutura

- `client/`: interface de jogo, unidades, alertas e comandos de chamada.
- `server/`: estado partilhado, persistência e encaminhamento de alertas.
- `configs/`: opções, eventos/framework e idiomas.
- `html/`: interface NUI, mapas, ícones, bibliotecas e sons.

## Dependências

- `ox_lib`
- `oxmysql`
- assetpacks do recurso original
- FXServer com build 4960 ou superior

No `server.cfg`, iniciar `ox_lib` e `oxmysql` antes de `onyx_dispatch`.

## Base de dados

`Config.AutoInsertSQL` está ativo por predefinição. O recurso cria a tabela `cd_dispatch` para guardar os callsigns. O nome da tabela foi mantido para preservar compatibilidade com os dados e integrações existentes.

## Compatibilidade

O nome do recurso e os exports próprios são `onyx_dispatch`. Os eventos públicos continuam no namespace `cd_dispatch:` para não partir integrações já existentes.

## Segurança e manutenção

- Não guardar credenciais, ficheiros de configuração do servidor, logs ou cache neste repositório.
- As chamadas entre NUI e Lua usam o nome do recurso fornecido pelo FiveM; não dependem de um URL externo.
- Antes de adicionar integrações externas, validar o destino e os dados no servidor.
- Manter ficheiros de bibliotecas e assets originais enquanto forem referenciados pela interface ou pelo código.
