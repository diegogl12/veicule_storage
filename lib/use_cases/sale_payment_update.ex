defmodule VeiculeStorage.UseCases.SalePaymentUpdate do
  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.Domain.Entities.Payment

  def execute(%Sale{} = sale, sale_repo, payment_repo) do

    with {:ok, current_sale} <- sale_repo.get(sale.id),
        {:ok, current_payment} <- payment_repo.get(current_sale.payment_id),
         {:ok, new_sale} <- new_sale_status(current_sale, sale.status),
         {:ok, new_payment} <- new_payment_status(current_payment, sale.status),
         {:ok, new_sale} <- sale_repo.update(new_sale),
         {:ok, _payment} <- payment_repo.update(new_payment) do
      {:ok, new_sale}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp new_sale_status(current_sale, sale_status) do
    result = case sale_status do
      "PAYMENT_VALIDATED" -> %Sale{current_sale | status: "PAYMENT_COMPLETED"}
      "PAYMENT_CANCELLED" -> %Sale{current_sale | status: "PAYMENT_CANCELLED"}
      _ -> %Sale{current_sale | status: "ERROR"}
    end

    {:ok, result}
  end

  defp new_payment_status(current_payment, sale_status) do
    result = case sale_status do
      "PAYMENT_VALIDATED" -> %Payment{current_payment | status: "COMPLETED"}
      "PAYMENT_CANCELLED" -> %Payment{current_payment | status: "CANCELLED"}
      _ -> %Payment{current_payment | status: "ERROR"}
    end

    {:ok, result}
  end
end
