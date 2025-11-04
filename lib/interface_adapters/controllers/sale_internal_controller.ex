defmodule VeiculeStorage.InterfaceAdapters.Controllers.SaleInternalController do
  alias VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO
  alias VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO
  alias VeiculeStorage.InterfaceAdapters.Gateways.Clients.Mercadopago
  alias VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository
  alias VeiculeStorage.UseCases.SalePaymentUpdate
  alias VeiculeStorage.UseCases.Sell

  def sell(%SellInputDTO{} = dto) do
    with {:ok, sale} <- SellInputDTO.to_sale(dto),
         {:ok, payment} <- SellInputDTO.to_payment(dto),
         {:ok, sale} <- Sell.run(sale, payment, SaleRepository, InventoryRepository, PaymentRepository, Mercadopago) do
      {:ok, sale}
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_sales() do
    with {:ok, sales} <- SaleRepository.get_all() do
      {:ok, sales}
    else
      {:error, error} -> {:error, error}
    end
  end

  def sale_status_update(%SaleDTO{} = dto) do
    with {:ok, sale} <- SaleDTO.to_domain(dto),
         {:ok, sale} <- SalePaymentUpdate.execute(sale, SaleRepository, PaymentRepository) do
      {:ok, sale}
    else
        {:error, error} -> {:error, error}
      end
    end
end
