(ns warehouse-shipping.core-test
  (:require
   [clojure.test
    :refer
    [deftest
     is
     testing]]
   [warehouse-shipping.core
    :as shipping]))

(deftest accepts-order-when-available-stock-is-enough
  (testing
   "利用可能在庫だけで注文数量を満たせる"
    ;; 要件:
    ;; 商品コード:
    ;; "ITEM-001"
    ;; 注文数量:
    ;; 5
    ;; 利用可能在庫:
    ;; 8
    ;; 予約在庫:
    ;; 0
    ;; 顧客区分:
    ;; :regular
    ;; shipping/evaluate-orderの結果が
    ;; 次と等しいことを確認する。
    ;; {:status :accepted
    ;;  :allocated-quantity 5}
    (let [order
          {:product-code "ITEM-001"
           :quantity 5
           :available-stock 8
           :reserved-stock 0
           :customer-type :regular}

          actual
          (shipping/evaluate-order order)

          expected
          {:status :accepted
           :allocated-quantity 5}]
      (is (= expected actual)))
))

(deftest accepts-priority-order-using-reserved-stock
  (testing
   "優先顧客は予約在庫を使って出荷できる"
    ;; 要件:
    ;; 商品コード:
    ;; "ITEM-002"
    ;; 注文数量:
    ;; 7
    ;; 利用可能在庫:
    ;; 4
    ;; 予約在庫:
    ;; 5
    ;; 顧客区分:
    ;; :priority
    ;; 通常在庫だけでは3個不足する。
    ;; 結果が次と等しいことを確認する。
    ;; {:status :priority-reservation
    ;;  :allocated-quantity 7
    ;;  :used-reserved-stock 3}
    (let [order
          {:product-code "ITEM-002"
           :quantity 7
           :available-stock 4
           :reserved-stock 5
           :customer-type :priority}

          actual
          (shipping/evaluate-order order)

          expected
          {:status :priority-reservation
           :allocated-quantity 7
           :used-reserved-stock 3}]
      (is (= expected actual)))
))

(deftest rejects-regular-order-when-stock-is-not-enough
  (testing
   "一般顧客は予約在庫を出荷に利用できない"
    ;; 要件:
    ;; 商品コード:
    ;; "ITEM-003"
    ;; 注文数量:
    ;; 8
    ;; 利用可能在庫:
    ;; 3
    ;; 予約在庫:
    ;; 2
    ;; 顧客区分:
    ;; :regular
    ;; 合計在庫は5なので、不足数量は3。
    ;; 結果が次と等しいことを確認する。
    ;; {:status :rejected
    ;;  :shortage-quantity 5}
    (let [order
          {:product-code "ITEM-003"
           :quantity 8
           :available-stock 3
           :reserved-stock 2
           :customer-type :regular}

          actual
          (shipping/evaluate-order order)

          expected
          {:status :rejected
           :shortage-quantity 5}]

      (is (= expected actual)))
))

(deftest rejects-priority-order-when-stock-is-not-enough
  (testing
   "優先顧客が在庫不足の場合"
    ;; 要件:
    ;; 商品コード:
    ;; "ITEM-003"
    ;; 注文数量:
    ;; 8
    ;; 利用可能在庫:
    ;; 3
    ;; 予約在庫:
    ;; 2
    ;; 顧客区分:
    ;; :priority
    ;; 合計在庫は5なので、不足数量は3。
    ;; 結果が次と等しいことを確認する。
    ;; {:status :rejected
    ;;  :shortage-quantity 3}
    (let [order
          {:product-code "ITEM-003"
           :quantity 8
           :available-stock 3
           :reserved-stock 2
           :customer-type :priority}

          actual
          (shipping/evaluate-order order)

          expected
          {:status :rejected
           :shortage-quantity 3}]

      (is (= expected actual)))
))

(deftest rejects-order-with-zero-quantity
  (testing
   "注文数量が0なら例外を投げる"
    ;; 要件:
    ;; 注文数量に0を指定する。
    ;; clojure.lang.ExceptionInfoが
    ;; 発生することを確認する。
    ;; 例外メッセージが次と等しいことを確認する。
    ;; "quantity must be at least 1: 0"
    ;; さらにex-dataが次と等しいことを確認する。
    ;; {:field :quantity
    ;;  :value 0}
    (let [order
          {:product-code "ITEM-001"
           :quantity 0
           :available-stock 8
           :reserved-stock 0
           :customer-type :regular}

          exception
          (try
            (shipping/evaluate-order order)
            nil
            (catch clojure.lang.ExceptionInfo error
              error))
          expected
          (ex-info
           "quantity must be at least 1: 0"
           {:field :quantity
            :value 0})]
      (is (some? exception))
      (is (= (ex-message expected)
             (ex-message exception)))
      (is (= (ex-data expected)
             (ex-data exception))))
))

(deftest rejects-unsupported-customer-type
  (testing
   "未定義の顧客区分なら例外を投げる"
    ;; 要件:
    ;; 顧客区分に:vipを指定する。
    ;; clojure.lang.ExceptionInfoが
    ;; 発生することを確認する。
    ;; 例外メッセージが次と等しいことを確認する。
    ;; "unsupported customer-type: :vip"
    (let [order
          {:product-code "ITEM-001"
           :quantity 1
           :available-stock 8
           :reserved-stock 1
           :customer-type :vip}

          exception
          (try
            (shipping/evaluate-order order)
            nil
            (catch clojure.lang.ExceptionInfo error
              error))
          expected
          (ex-info
           "unsupported customer-type: :vip"
           {:field :customer-type
            :value :vip})]
      (is (some? exception))
      (is (= (ex-message expected)
             (ex-message exception)))
      (is (= (ex-data expected)
             (ex-data exception))))
))

(deftest evaluates-multiple-shipping-cases
  (testing
   "複数の正常系をまとめて検証する"
    ;; 要件:
    ;; testsというベクタを作る。
    ;; 各要素は次のキーを持つマップにする。
    ;; :name
    ;; :order
    ;; :expected
    ;;
    ;; ケース1:
    ;; 名前: "利用可能在庫で足りる"
    ;; quantity: 3
    ;; available-stock: 5
    ;; reserved-stock: 0
    ;; customer-type: :regular
    ;; expected:
    ;; {:status :accepted
    ;;  :allocated-quantity 3}
    ;;
    ;; ケース2:
    ;; 名前: "優先顧客が予約在庫を使う"
    ;; quantity: 10
    ;; available-stock: 6
    ;; reserved-stock: 5
    ;; customer-type: :priority
    ;; expected:
    ;; {:status :priority-reservation
    ;;  :allocated-quantity 10
    ;;  :used-reserved-stock 4}
    ;;
    ;; ケース3:
    ;; 名前: "合計在庫でも不足する"
    ;; quantity: 10
    ;; available-stock: 2
    ;; reserved-stock: 3
    ;; customer-type: :priority
    ;; expected:
    ;; {:status :rejected
    ;;  :shortage-quantity 5}
    ;;
    ;; doseqを使って各ケースを実行する。
    ;; testingにケース名を渡し、
    ;; どのケースが失敗したか分かるようにする。
    (let [tests
          [{:name "利用可能在庫で足りる"
            :order {:product-code "ITEM-001"
                    :quantity 3
                    :available-stock 5
                    :reserved-stock 0
                    :customer-type :regular}
            :expected {:status :accepted
                       :allocated-quantity 3}}
           {:name "優先顧客が予約在庫を使う"
            :order {:product-code "ITEM-001"
                    :quantity 10
                    :available-stock 6
                    :reserved-stock 5
                    :customer-type :priority}
            :expected {:status :priority-reservation
                       :allocated-quantity 10
                       :used-reserved-stock 4}}
           {:name "合計在庫でも不足する"
            :order {:product-code "ITEM-001"
                    :quantity 10
                    :available-stock 2
                    :reserved-stock 3
                    :customer-type :priority}
            :expected {:status :rejected
                       :shortage-quantity 5}}]]
      (doseq [{:keys [name order expected]} tests]
        (testing name
          (is (= expected
                 (shipping/evaluate-order order))) )))
))
