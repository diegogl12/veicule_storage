defmodule VeiculeStorage.InterfaceAdapters.Gateways.Clients.Mercadopago do
  @behaviour VeiculeStorage.Domain.Gateways.PaymentGatewayBehaviour

  alias VeiculeStorage.Domain.Entities.Payment

  @impl true
  def perform_payment(%Payment{} = payment) do
    {:ok, payment}
  end
end
