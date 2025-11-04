defmodule VeiculeStorage.Infra.Web.SwaggerUI do
  @moduledoc """
  Módulo para servir a interface Swagger UI diretamente.

  Este módulo gera uma página HTML que incorpora o Swagger UI (via CDN),
  permitindo visualizar e testar a API de forma interativa sem precisar
  de ferramentas externas.

  Em Elixir, usar heredocs (""") para templates HTML é uma prática comum
  e funcional, evitando a necessidade de templates engines complexos para
  casos simples.
  """

  @doc """
  Retorna o HTML completo da página Swagger UI.

  Esta é uma função pura que sempre retorna o mesmo HTML.
  O Swagger UI carregará a especificação do endpoint /api/swagger.json.
  """
  def html do
    """
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Veicule Storage API - Documentation</title>
      <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.10.3/swagger-ui.css" />
      <style>
        body {
          margin: 0;
          padding: 0;
        }
        .topbar {
          display: none;
        }
      </style>
    </head>
    <body>
      <div id="swagger-ui"></div>
      <script src="https://unpkg.com/swagger-ui-dist@5.10.3/swagger-ui-bundle.js"></script>
      <script src="https://unpkg.com/swagger-ui-dist@5.10.3/swagger-ui-standalone-preset.js"></script>
      <script>
        window.onload = function() {
          window.ui = SwaggerUIBundle({
            url: "/api/swagger.json",
            dom_id: '#swagger-ui',
            deepLinking: true,
            presets: [
              SwaggerUIBundle.presets.apis,
              SwaggerUIStandalonePreset
            ],
            plugins: [
              SwaggerUIBundle.plugins.DownloadUrl
            ],
            layout: "StandaloneLayout"
          });
        };
      </script>
    </body>
    </html>
    """
  end
end
