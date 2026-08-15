module InventoryRestock

open System

type ProductCategory =
    | Food
    | Household
    | Electronics

type InventoryItem =
    { Sku: string
      Name: string
      Category: ProductCategory
      OnHand: int
      Reserved: int
      ReorderPoint: int
      TargetStock: int }

type RestockPriority =
    | Normal
    | Critical

type RestockProposal =
    { Sku: string
      Name: string
      Category: ProductCategory
      AvailableStock: int
      OrderQuantity: int
      Priority: RestockPriority }

type InventoryError =
    | BlankSku of index: int
    | BlankName of sku: string
    | NegativeOnHand of sku: string * value: int
    | InvalidReserved of
        sku: string * reserved: int * onHand: int
    | NegativeReorderPoint of sku: string * value: int
    | InvalidTargetStock of
        sku: string * targetStock: int * reorderPoint: int
    | DuplicateSku of sku: string

type RestockReport =
    { Proposals: RestockProposal list
      InspectedItemCount: int
      ProposalCount: int
      TotalOrderQuantity: int
      CriticalCount: int
      ProposalCountsByCategory: Map<ProductCategory, int> }

let private validateInventory
    (items: InventoryItem list)
    : Result<InventoryItem list, InventoryError> =
     let fieldError =
         items
         |> List.indexed
         |> List.tryPick (fun (index, item) ->
             if String.IsNullOrWhiteSpace item.Sku then
                 Some(BlankSku index)
             elif String.IsNullOrWhiteSpace item.Name then
                 Some(BlankName item.Sku)
             elif item.OnHand < 0 then
                 Some(NegativeOnHand(item.Sku, item.OnHand))
             elif item.Reserved < 0 || item.Reserved > item.OnHand then
                 Some(InvalidReserved(item.Sku, item.Reserved, item.OnHand))
             elif item.ReorderPoint < 0 then
                 Some(NegativeReorderPoint(item.Sku, item.ReorderPoint))
             elif item.TargetStock <= item.ReorderPoint then
                 Some(InvalidTargetStock(item.Sku, item.TargetStock, item.ReorderPoint))
             else
                 None)

     match fieldError with
     | Some error -> Error error
     | None ->
         let duplicateSku =
             items
             |> List.countBy(fun item -> item.Sku)
             |> List.tryFind(fun (_, count) -> count > 1)

         match duplicateSku with
         | Some(sku, _) -> Error(DuplicateSku sku)
         | None -> Ok items

let availableStock
    (item: InventoryItem)
    : int =
    item.OnHand - item.Reserved

let createRestockProposal
    (item: InventoryItem)
    : RestockProposal option =
    let available = availableStock item
    if available > item.ReorderPoint then
        None
    else
        let orderQuantity = item.TargetStock - available
        let priority =
            if available = 0 then
                Critical
            else
                Normal
        Some {
            Sku = item.Sku
            Name = item.Name
            Category = item.Category
            AvailableStock = available
            OrderQuantity = orderQuantity
            Priority = priority}

let private countProposalsByCategory
    (proposals: RestockProposal list)
    : Map<ProductCategory, int> =
    [ Food; Household; Electronics ]
    |> List.map (fun category ->
        let count =
            proposals
            |> List.filter (fun p -> p.Category = category)
            |> List.length
        category, count)
    |> Map.ofList

let summarizeInventory
    (items: InventoryItem list)
    : Result<RestockReport, InventoryError> =
    match validateInventory items with
    | Error error -> Error error
    | Ok validItems ->
        let proposals =
            validItems
            |> List.choose createRestockProposal

        let report =
            { Proposals = proposals
              InspectedItemCount = List.length validItems
              ProposalCount = List.length proposals
              TotalOrderQuantity = proposals |> List.sumBy (fun p -> p.OrderQuantity)
              CriticalCount =
                  proposals
                  |> List.filter (fun p -> p.Priority = Critical)
                  |> List.length
              ProposalCountsByCategory = countProposalsByCategory proposals }

        Ok report
