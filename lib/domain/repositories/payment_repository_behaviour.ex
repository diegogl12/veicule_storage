defmodule VeiculeStorage.Domain.Repositories.PaymentRepositoryBehaviour do
  alias VeiculeStorage.Domain.Entities.Payment

  @callback create(Payment.t()) :: {:ok, Payment.t()} | {:error, any()}
  @callback update(Payment.t()) :: {:ok, Payment.t()} | {:error, any()}
  @callback get(String.t()) :: {:ok, Payment.t()} | {:error, any()}
end
