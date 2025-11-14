ExUnit.start()
Application.ensure_all_started(:mimic)

# Mocks para os Behaviours
Mox.defmock(PaymentGatewayMock, for: VeiculeStorage.Domain.Gateways.PaymentGatewayBehaviour)
Mox.defmock(PaymentRepositoryMock, for: VeiculeStorage.Domain.Repositories.PaymentRepositoryBehaviour)
Mox.defmock(VeiculeRepositoryMock, for: VeiculeStorage.Domain.Repositories.VeiculeRepositoryBehaviour)
Mox.defmock(InventoryRepositoryMock, for: VeiculeStorage.Domain.Repositories.InventoryRepositoryBehaviour)
Mox.defmock(SaleRepositoryMock, for: VeiculeStorage.Domain.Repositories.SaleRepositoryBehaviour)

# Módulos para copiar com Mimic (permite stub de funções)
[
  VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository,
  VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository,
  VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository,
  VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository,
  VeiculeStorage.InterfaceAdapters.Controllers.VeiculeInternalController,
  VeiculeStorage.InterfaceAdapters.Controllers.InventoryInternalController,
  VeiculeStorage.InterfaceAdapters.Controllers.SaleInternalController,
  VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO,
  VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO,
  VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO,
  VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO,
  VeiculeStorage.InterfaceAdapters.Gateways.Clients.Mercadopago,
  VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema,
  VeiculeStorage.InterfaceAdapters.Repositories.Schemas.InventorySchema,
  VeiculeStorage.InterfaceAdapters.Repositories.Schemas.SaleSchema,
  VeiculeStorage.InterfaceAdapters.Repositories.Schemas.PaymentSchema,
  VeiculeStorage.UseCases.Sell,
  VeiculeStorage.UseCases.SalePaymentUpdate,
  VeiculeStorage.UseCases.VeiculesToSell,
  VeiculeStorage.UseCases.VeiculesSold,
  VeiculeStorage.Infra.Web.Controllers.VeiculeController,
  VeiculeStorage.Infra.Web.Controllers.InventoryController,
  VeiculeStorage.Infra.Web.Controllers.SaleController,
  VeiculeStorage.Infra.Repo.VeiculeStorageRepo,
  Jason,
  UUID,
  NaiveDateTime,
  Application,
  Ecto.Changeset,
  Plug.Conn
]
|> Enum.each(&Mimic.copy/1)
