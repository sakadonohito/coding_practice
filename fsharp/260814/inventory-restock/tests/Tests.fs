module InventoryRestockTests

open Expecto
open InventoryRestock

let private item
    sku
    category
    onHand
    reserved
    reorderPoint
    targetStock
    =
    { Sku = sku
      Name = $"商品-{sku}"
      Category = category
      OnHand = onHand
      Reserved = reserved
      ReorderPoint = reorderPoint
      TargetStock = targetStock }

[<Tests>]
let tests =
    testList
        "inventory restock"
        [
          testCase "倉庫在庫から予約済み在庫を引いて利用可能数を返す"
          <| fun _ ->
              let sampleItem = item "FOOD-001" Food 10 4 5 20
              let actual = availableStock sampleItem
              Expect.equal actual 6 "利用可能在庫は6になる"

          testCase "補充基準より在庫が多ければ提案しない"
          <| fun _ ->
               let targetItem = item "FOOD-001" Food 10 2 7 20
               let actual = createRestockProposal targetItem
               Expect.equal actual None "在庫補充判断 -> None"

          testCase "在庫ゼロならCriticalの補充提案を作る"
          <| fun _ ->
               let targetItem = item "ELEC-001" Electronics 5 5 3 12
               let actual = createRestockProposal targetItem
               match actual with
               | Some proposal ->
                   Expect.equal proposal.Sku "ELEC-001" "SKUが一致する"
                   Expect.equal proposal.AvailableStock 0 "AvailableStockは0"
                   Expect.equal proposal.OrderQuantity 12 "OrderQuantityは12"
                   Expect.equal proposal.Priority Critical "PriorityはCritical"
               | None ->
                   failtest "proposalが作られずNoneが返された"

          testCase "必要な商品だけを入力順で集計する"
          <| fun _ ->
               let itemList = [
                   item "FOOD-001" Food 10 4 6 20;
                   item "HOME-001" Household 10 1 5 15;
                   item "ELEC-001" Electronics 5 5 3 12;
                   item "FOOD-002" Food 4 1 3 10]
               let actual = summarizeInventory itemList
               match actual with
               | Ok report ->
                   let skuList = report.Proposals |> List.map (fun p -> p.Sku)
                   Expect.equal skuList  ["FOOD-001"; "ELEC-001"; "FOOD-002"] "ProposalsのSKU順はFOOD-001、ELEC-001、FOOD-002"
                   Expect.equal report.InspectedItemCount 4 "InspectedItemCountは4"
                   Expect.equal report.ProposalCount 3 "ProposalCountは3"
                   Expect.equal report.TotalOrderQuantity 33 "TotalOrderQuantityは33"
                   Expect.equal report.CriticalCount 1 "CriticalCountは1"

                   let expectedMap = Map.ofList [Food, 2; Household, 0; Electronics, 1]
                   Expect.equal report.ProposalCountsByCategory expectedMap "Foodは2、Householdは0、Electronicsは1"

                   Expect.equal report.ProposalCountsByCategory.[Food] 2 "Foodは2"
                   Expect.equal report.ProposalCountsByCategory.[Household] 0 "Householdは0"
                   Expect.equal report.ProposalCountsByCategory.[Electronics] 1 "Electronicsは1"
               | Error error ->
                   failtest "Okが返されるはずですが、Errorが返されました: %A" error

          testCase "空一覧ではすべてゼロのレポートを返す"
          <| fun _ ->
              let actual = summarizeInventory []
              match actual with
              | Ok report ->
                  Expect.equal report.Proposals [] "Proposalsは空"
                  Expect.equal report.InspectedItemCount 0 "InspectedItemCountは0"
                  Expect.equal report.ProposalCount 0 "ProposalCountは0"
                  Expect.equal report.TotalOrderQuantity 0 "TotalOrderQuantityは0"
                  Expect.equal report.CriticalCount 0 "CriticalCountは0"

                  let expectedMap = Map.ofList [Food, 0; Household, 0; Electronics, 0]
                  Expect.equal report.ProposalCountsByCategory expectedMap "Foodは0、Householdは0、Electronicsは0"

              | Error error ->
                  failtest "Okが返されるはずですが、Errorが返されました: %A" error

          testCase "不正な商品一覧では最初の入力エラーを返す"
          <| fun _ ->
               let baseItem = item "FOOD-001" Food 10 4 6 20
               let testCases =
                   [ [ item "   " Food 10 4 6 20 ], BlankSku 0
                     [ { baseItem with Name = "   " } ], BlankName "FOOD-001"
                     [ { baseItem with OnHand = -1 } ], NegativeOnHand("FOOD-001", -1)
                     [ { baseItem with OnHand = 3; Reserved = 4 } ], InvalidReserved("FOOD-001", 4, 3)
                     [ { baseItem with ReorderPoint = -1 } ], NegativeReorderPoint("FOOD-001", -1)
                     [ { baseItem with ReorderPoint = 5; TargetStock = 5 } ], InvalidTargetStock("FOOD-001", 5, 5)
                     [ baseItem; baseItem ], DuplicateSku "FOOD-001" ]
               testCases
               |> List.iter (fun (inputItems, expectedError) ->
                   let actual = summarizeInventory inputItems
                   Expect.equal actual (Error expectedError) "正しい入力エラーがスローされること")
        ]

[<EntryPoint>]
let main argv =
    runTestsWithCLIArgs [] argv tests
