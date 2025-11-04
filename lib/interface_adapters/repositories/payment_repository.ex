defmodule VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository do
  @behaviour VeiculeStorage.Domain.Repositories.PaymentRepositoryBehaviour

  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.PaymentSchema

  require Ecto.Query
  require Logger

  @impl true
  def create(%Payment{} = payment) do
    attrs = %{
      payment_method: payment.payment_method,
      payment_value: payment.payment_value,
      status: payment.status,
      payment_date: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    %PaymentSchema{}
    |> PaymentSchema.changeset(attrs)
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
    with {:ok, current_payment_schema} <- get_schema(payment.id),
         changeset <- build_update_changeset(payment, current_payment_schema),
         {:ok, payment_updated} <- Repo.update(changeset) do
      {:ok, to_payment(payment_updated)}
    else
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

  defp get_schema(id) do
    case Repo.get(PaymentSchema, id) do
      nil -> {:error, :not_found}
      payment_schema -> {:ok, payment_schema}
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

  defp build_update_changeset(%Payment{} = new_payment, %PaymentSchema{} = current_schema) do
    attrs = %{
      payment_method: new_payment.payment_method,
      payment_value: new_payment.payment_value,
      status: new_payment.status
    }

    PaymentSchema.changeset(current_schema, attrs)
  end
end
