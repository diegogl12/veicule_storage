defmodule VeiculeStorage.Infra.Web.Controllers.SaleController do
  alias VeiculeStorage.InterfaceAdapters.Controllers.SaleInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO
  alias VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO

  def sell(params) do
    with {:ok, dto} <- SellInputDTO.from_map(params),
         {:ok, sale} <- SaleInternalController.sell(dto) do
      {:ok, sale}
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_sales() do
    with {:ok, sales} <- SaleInternalController.get_sales() do
      {:ok, sales}
    else
      {:error, error} -> {:error, error}
    end
  end

  def sale_status_update(params) do
    with {:ok, dto} <- SaleDTO.from_map(params),
         {:ok, sale} <- SaleInternalController.sale_status_update(dto) do
      {:ok, sale}
    else
      {:error, error} -> {:error, error}
    end
  end
end
