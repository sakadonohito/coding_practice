namespace OrderApp.Tests

open Xunit
open OrderApp
open OrderApp.OrderService

module OrderServiceTests =


    [<Fact>]
    let ``未発送注文の顧客名だけを合計金額順に返す`` () =
        // 1. 発送済み注文と未発送注文が混ざった Order list を用意してください。
        // 2. 未発送注文には TotalAmount: 5000, 9000, 18000 が混ざるようにしてください。
        let orders = [
            { Id = 1; CustomerName = "佐藤"; TotalAmount = 12000; Shipped = true }
            { Id = 2; CustomerName = "鈴木"; TotalAmount = 5000; Shipped = false }
            { Id = 3; CustomerName = "田中"; TotalAmount = 18000; Shipped = false }
            { Id = 4; CustomerName = "高橋"; TotalAmount = 9000; Shipped = false }
        ]
        // 3. unshippedOrderNamesByAmount を呼び出してください。
        let actual = unshippedOrderNamesByAmount orders
        // 4. 未発送注文の CustomerName だけが TotalAmount の小さい順で返ることを検証してください。
        let expected: string list = ["鈴木"; "高橋"; "田中"]
        Assert.Equal<string list>(expected, actual)

    [<Fact>]
    let ``すべて発送済みの場合は空リストを返す`` () =
        // 1. すべて Shipped = true の Order list を用意してください。
        let orders = [
            { Id = 1; CustomerName = "佐藤"; TotalAmount = 12000; Shipped = true }
            { Id = 2; CustomerName = "鈴木"; TotalAmount = 5000; Shipped = true }
            { Id = 3; CustomerName = "田中"; TotalAmount = 18000; Shipped = true }
            { Id = 4; CustomerName = "高橋"; TotalAmount = 9000; Shipped = true }
        ]
        // 2. unshippedOrderNamesByAmount を呼び出してください。
        let actual = unshippedOrderNamesByAmount orders
        // 3. 結果が空リストになることを検証してください。
        let expected: string list = []
        Assert.Equal<string list>(expected, actual)

    [<Fact>]
    let ``注文が空の場合は空リストを返す`` () =
        // 1. 空の Order list を用意してください。
        let orders: Order list = []
        // 2. unshippedOrderNamesByAmount を呼び出してください。
        let actual = unshippedOrderNamesByAmount orders
        // 3. 結果が空リストになることを検証してください。
        //let expected: string list = []
        //Assert.Equal<string list>(expected, actual)
        // 空リストであることを確認する場合はAssert.Emptyでよい。2番目のテストもこの方法にしてもよい
        Assert.Empty actual
