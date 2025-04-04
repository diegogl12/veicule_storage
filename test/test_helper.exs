ExUnit.start()
Application.ensure_all_started(:mimic)

Mox.defmock(PaymentGatewayMock, for: VeiculeStorage.InterfaceAdapters.Gateways.PaymentGatewayBehaviour)
Mox.defmock(PaymentRepositoryMock, for: VeiculeStorage.Domain.Repositories.PaymentRepositoryBehaviour)
Mox.defmock(PaymentStatusRepositoryMock, for: VeiculeStorage.Domain.Repositories.PaymentStatusRepositoryBehaviour)

[
  VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository,
  VeiculeStorage.InterfaceAdapters.Repositories.PaymentStatusRepository,
  VeiculeStorage.InterfaceAdapters.Controllers.PaymentController,
  VeiculeStorage.InterfaceAdapters.DTOs.PaymentDTO,
  VeiculeStorage.InterfaceAdapters.DTOs.PaymentStatusUpdateDTO,
  VeiculeStorage.UseCases.RequestPayment,
  VeiculeStorage.UseCases.UpdatePaymentStatus,
  Jason,
  Tesla,
  UUID,
  NaiveDateTime,
  Application,
  VeiculeStorage.Infra.Repo.VeiculeStorageRepo,
  Ecto.Changeset,
  VeiculeStorage.Infra.Web.Controllers.PaymentController,
  Plug.Conn
]
|> Enum.each(&Mimic.copy/1)
