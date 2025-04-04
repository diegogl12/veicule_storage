defmodule VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository do
  @behaviour VeiculeStorage.Domain.Repositories.PaymentRepositoryBehaviour
  require Ecto.Query
  require Logger

  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.PaymentSchema

  @impl true
  def create(%Payment{} = payment) do
    %PaymentSchema{
      payment_method: payment.payment_method,
      payment_value: payment.payment_value,
      status: payment.status,
      payment_date: NaiveDateTime.truncate(payment.payment_date, :second)
    }
    |> Repo.insert()
    |> case do
      {:ok, payment_inserted} ->
        {:ok, to_payment(payment_inserted)}

      {:error, error} ->
        Logger.error("Error on PaymentRepository.create: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl true
  def update(%Payment{} = payment) do
    %PaymentSchema{
      id: payment.id,
      payment_method: payment.payment_method,
      payment_value: payment.payment_value,
      status: payment.status,
      payment_date: NaiveDateTime.truncate(payment.payment_date, :second)
    }
    |> Repo.update()
    |> case do
      {:ok, payment_updated} ->
        {:ok, to_payment(payment_updated)}

      {:error, error} ->
        Logger.error("Error on PaymentRepository.update: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl true
  def get(id) do
    case Repo.get(PaymentSchema, id) do
      nil -> {:error, :not_found}
      payment_schema -> {:ok, to_payment(payment_schema)}
    end
  end

  defp to_payment(schema) do
    %Payment{
      id: schema.id,
      payment_value: schema.payment_value,
      status: schema.status,
      payment_date: schema.payment_date
    }
  end
end
