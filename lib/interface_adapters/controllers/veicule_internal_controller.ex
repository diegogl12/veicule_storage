defmodule VeiculeStorage.InterfaceAdapters.Controllers.VeiculeInternalController do
  alias VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO

  def create(%VeiculeDTO{} = dto) do
    with {:ok, veicule_domain} <- VeiculeDTO.to_domain(dto),
         {:ok, veicule} <- VeiculeRepository.create(veicule_domain) do
      {:ok, veicule}
    else
      {:error, error} ->
        {:error, error}
    end
  end
end
