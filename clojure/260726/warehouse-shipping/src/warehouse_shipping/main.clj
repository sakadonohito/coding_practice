(ns warehouse-shipping.main
  (:require
   [warehouse-shipping.core :as shipping]))

(defn -main
  [& _args]
  (let [order
        {:product-code "ITEM-001"
         :quantity 8
         :available-stock 3
         :reserved-stock 2
         :customer-type :regular}

        decision
        (shipping/evaluate-order order)]
    (println "注文：" order)
    (println "判定：" decision)))
