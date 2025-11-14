defmodule VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepositoryTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.PaymentSchema

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "get/1" do
    test "successfully gets a payment by id" do
      # Arrange
      payment_id = "payment-uuid-123"

      payment_schema = %PaymentSchema{
        id: payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING",
        payment_date: ~N[2025-11-14 10:00:00]
      }

      stub(Repo, :get, fn PaymentSchema, ^payment_id -> payment_schema end)

      # Act
      result = PaymentRepository.get(payment_id)

      # Assert
      assert {:ok, %Payment{
        id: ^payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING",
        payment_date: ~N[2025-11-14 10:00:00]
      }} = result
    end

    test "returns error when payment is not found" do
      # Arrange
      payment_id = "non-existent-id"
      stub(Repo, :get, fn PaymentSchema, ^payment_id -> nil end)

      # Act
      result = PaymentRepository.get(payment_id)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "create/1" do
    test "successfully creates a payment" do
      # Arrange
      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "INITIAL"
      }

      payment_schema = %PaymentSchema{
        id: "new-payment-uuid",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "INITIAL",
        payment_date: ~N[2025-11-14 10:00:00]
      }

      stub(NaiveDateTime, :utc_now, fn -> ~N[2025-11-14 10:00:00] end)
      stub(NaiveDateTime, :truncate, fn date, :second -> date end)
      stub(PaymentSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:ok, payment_schema} end)

      # Act
      result = PaymentRepository.create(payment)

      # Assert
      assert {:ok, %Payment{
        id: "new-payment-uuid",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "INITIAL"
      }} = result
    end

    test "returns error when repository fails" do
      # Arrange
      payment = %Payment{
        payment_method: "CREDIT_CARD",
        payment_value: 95000.00,
        status: "INITIAL"
      }

      stub(NaiveDateTime, :utc_now, fn -> ~N[2025-11-14 10:00:00] end)
      stub(NaiveDateTime, :truncate, fn date, :second -> date end)
      stub(PaymentSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:error, :database_error} end)

      # Act
      result = PaymentRepository.create(payment)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "update/1" do
    test "successfully updates a payment" do
      # Arrange
      payment_id = "payment-uuid-123"

      payment = %Payment{
        id: payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "COMPLETED"
      }

      existing_schema = %PaymentSchema{
        id: payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING",
        payment_date: ~N[2025-11-14 10:00:00]
      }

      updated_schema = %PaymentSchema{
        id: payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "COMPLETED",
        payment_date: ~N[2025-11-14 10:00:00]
      }

      stub(Repo, :get, fn PaymentSchema, ^payment_id -> existing_schema end)
      stub(PaymentSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :update, fn :changeset -> {:ok, updated_schema} end)

      # Act
      result = PaymentRepository.update(payment)

      # Assert
      assert {:ok, %Payment{
        id: ^payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "COMPLETED"
      }} = result
    end

    test "returns error when payment is not found" do
      # Arrange
      payment = %Payment{
        id: "non-existent-id",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "COMPLETED"
      }

      stub(Repo, :get, fn PaymentSchema, "non-existent-id" -> nil end)

      # Act
      result = PaymentRepository.update(payment)

      # Assert
      assert {:error, :not_found} = result
    end

    test "returns error when repository update fails" do
      # Arrange
      payment_id = "payment-uuid-123"

      payment = %Payment{
        id: payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "COMPLETED"
      }

      existing_schema = %PaymentSchema{
        id: payment_id,
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING",
        payment_date: ~N[2025-11-14 10:00:00]
      }

      stub(Repo, :get, fn PaymentSchema, ^payment_id -> existing_schema end)
      stub(PaymentSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :update, fn :changeset -> {:error, :database_error} end)

      # Act
      result = PaymentRepository.update(payment)

      # Assert
      assert {:error, :database_error} = result
    end
  end
end
