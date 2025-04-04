defmodule VeiculeStorage.Domain.Gateways.PaymentGatewayBehaviour do
  alias VeiculeStorage.Domain.Entities.Payment

  @callback perform_payment(Payment.t()) :: {:ok, Payment.t()} | {:error, any()}
end
