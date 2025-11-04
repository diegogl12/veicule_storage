defmodule VeiculeStorage.UseCases.Sell do
  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Domain.Entities.Sale

  def run(%Sale{} = sale, %Payment{} = payment, sale_repo, inventory_repo, payment_repo, payment_gateway) do
    with {:ok, _inventory} <- inventory_repo.get(sale.inventory_id),
         {:ok, payment} <- set_first_payment_status(payment),
         {:ok, payment} <- payment_repo.create(payment),
         {:ok, payment} <- payment_gateway.perform_payment(payment),
         {:ok, payment} <- set_pending_payment_status(payment),
         {:ok, payment} <- payment_repo.update(payment),
         {:ok, sale} <- build_valid_sale(sale, payment),
         {:ok, sale} <- sale_repo.create(sale) do
      {:ok, sale}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp build_valid_sale(%Sale{} = sale, %Payment{} = payment) do
    if sale.inventory_id == nil do
      {:error, "Inventory ID is required"}
    else
      {:ok, %{sale | payment_id: payment.id, status: "IN_PROGRESS"}}
    end
  end

  defp set_first_payment_status(%Payment{} = payment), do: {:ok, %{payment | status: "INITIAL"}}
  defp set_pending_payment_status(%Payment{} = payment), do: {:ok, %{payment | status: "PENDING"}}
end
