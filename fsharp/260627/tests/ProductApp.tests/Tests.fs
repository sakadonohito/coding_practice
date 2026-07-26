namespace ProductApp.Tests

open System
open Xunit
open ProductApp
open ProductApp.ProductService

module ProductServiceTests =

    [<Fact>]
    let ``outOfStockProductNames returns only product names whose stock is zero`` () =
        // 次の商品リストを用意してください。
        // Keyboard: Price 8000, Stock 3
        // Mouse: Price 3000, Stock 0
        // Monitor: Price 25000, Stock 2
        // USB Cable: Price 1200, Stock 0
        let products =
            [
                { Name = "Keyboard"; Price = 8000; Stock = 3 }
                { Name = "Mouse"; Price = 3000; Stock = 0 }
                { Name = "Monitor"; Price = 25000; Stock = 2 }
                { Name = "USB Cable"; Price = 1200; Stock = 0 }
            ]

        // outOfStockProductNames を呼び出してください。
        let actual = ProductApp.ProductService.outOfStockProductNames products
        //printfn "%A" actual
        // 結果が ["Mouse"; "USB Cable"] と一致することを検証してください。
        let expected = ["Mouse"; "USB Cable"]
        Assert.Equal<string list>(expected, actual)

    [<Fact>]
    let ``outOfStockProductNames returns empty list when all products are in stock`` () =
        // 次の商品リストを用意してください。
        // Keyboard: Price 8000, Stock 3
        // Monitor: Price 25000, Stock 2
        let products =
            [
                { Name = "Keyboard"; Price = 8000; Stock = 3 }
                { Name = "Monitor"; Price = 25000; Stock = 2 }
            ]

        // outOfStockProductNames を呼び出してください。
        let actual = ProductApp.ProductService.outOfStockProductNames products
        //printfn "%A" actual
        // 在庫切れの商品がないため、結果が空リストになることを検証してください。
        let expected = []
        Assert.Equal<string list>(expected, actual)

    [<Fact>]
    let ``outOfStockProductNames returns empty list when product list is empty`` () =
        // 空リストを用意
        let products: Product list = []

        let actual = ProductApp.ProductService.outOfStockProductNames products
        let expected: string list = []
        Assert.Equal<string list>(expected, actual)
