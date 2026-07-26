namespace OrderApp

type Order = {
    Id: int
    CustomerName: string
    TotalAmount: int
    Shipped: bool
}

module OrderService =
    let unshippedOrderNamesByAmount orders =
        orders
        |> List.filter (fun order -> not order.Shipped)
        |> List.sortBy (fun order -> order.TotalAmount)
        |> List.map (fun order -> order.CustomerName)

    let orders = [
        { Id = 1; CustomerName = "佐藤"; TotalAmount = 12000; Shipped = true }
        { Id = 2; CustomerName = "鈴木"; TotalAmount = 5000; Shipped = false }
        { Id = 3; CustomerName = "田中"; TotalAmount = 18000; Shipped = false }
        { Id = 4; CustomerName = "高橋"; TotalAmount = 9000; Shipped = false }
    ]

    let result = unshippedOrderNamesByAmount orders

    printfn "%A" result
