namespace ProductApp

type Product =
    {
        Name: string
        Price: int
        Stock: int
    }

module ProductService =

    let outOfStockProductNames products =
        products
        |> List.filter (fun product -> product.Stock = 0)
        |> List.map (fun product -> product.Name)

module Program =

    [<EntryPoint>]
    let main argv =
        let products =
            [
                { Name = "Keyboard"; Price = 8000; Stock = 3 }
                { Name = "Mouse"; Price = 3000; Stock = 0 }
                { Name = "Monitor"; Price = 25000; Stock = 2 }
                { Name = "USB Cable"; Price = 1200; Stock = 0 }
            ]

        let result = ProductService.outOfStockProductNames products

        printfn "%A" result

        0
