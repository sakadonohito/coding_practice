(ns inventory-service.application.item-service
  (:require
   [inventory-service.domain.item :as item]))

(defn item-summary
  "商品データから表示用文字列を作る。"
  [{:keys [id name quantity] :as item-data}]
  (if (item/valid-item? item-data)
    (format "ID=%d, name=%s, quantity=%d"
            id
            name
            quantity)
    "Invalid item"))
