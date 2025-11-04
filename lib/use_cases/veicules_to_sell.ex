defmodule VeiculeStorage.UseCases.VeiculesToSell do
  def execute(veicule_repo, inventory_repo, sale_repo) do
    with {:ok, inventories} <- inventory_repo.get_all(),
         {:ok, sales} <- sale_repo.get_all(),
         {:ok, inventories_to_sell} <- remove_sold_veicules(inventories, sales),
         {:ok, veicules} <- veicule_repo.find_by_ids(Enum.map(inventories_to_sell, & &1.veicule_id)),
         {:ok, inventories_with_veicules} <- order_and_merge_inventories_and_veicules(inventories_to_sell, veicules) do
      {:ok, inventories_with_veicules}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp remove_sold_veicules(inventories, sales) do
    result = inventories
    |> Enum.filter(fn inventory ->
      not Enum.any?(sales, fn sale -> sale.inventory_id == inventory.id end)
    end)

    {:ok, result}
  end

  defp order_and_merge_inventories_and_veicules(inventories, veicules) do
    result = Enum.map(inventories, fn inventory ->
      veicule = Enum.find(veicules, fn veicule -> veicule.id == inventory.veicule_id end)
      %{inventory | veicule: veicule}
    end) |> Enum.sort_by(& &1.price, :asc)

    {:ok, result}
  end
end
