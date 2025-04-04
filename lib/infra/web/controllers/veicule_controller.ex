defmodule VeiculeStorage.Infra.Web.Controllers.VeiculeController do
  require Logger

  alias VeiculeStorage.InterfaceAdapters.Controllers.VeiculeInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO

  @doc """
  Creates a new veicule.

  params:
   - brand: string
   - model: string
   - year: integer
   - color: string
  """
  def create_veicule(params) do
    Logger.info("Creating veicule: #{inspect(params)}")

    with {:ok, dto} <- VeiculeDTO.from_map(params),
         {:ok, veicule} <- VeiculeInternalController.create(dto) do
      {:ok, veicule}
    else
      {:error, error} ->
        {:error, error}
    end
  end
end
