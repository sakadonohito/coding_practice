(ns inventory-service.domain.item
  (:require
   [clojure.string :as str]))

(defn valid-name?
  "商品名として有効ならtrueを返す。"
  [name]
  (and (string? name)
       (not (str/blank? name))))

(defn valid-quantity?
  "在庫数量として有効ならtrueを返す。"
  [quantity]
  (and (integer? quantity)
       (not (neg? quantity))))

(defn valid-item?
  "商品データ全体が有効ならtrueを返す。"
  [{:keys [id name quantity]}]
  (and (pos-int? id)
       (valid-name? name)
       (valid-quantity? quantity)))
