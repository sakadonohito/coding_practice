(ns warehouse-shipping.core
  (:require [clojure.string :as str]))

(def valid-customer-types
  #{:regular :priority})

(defn validate-order
  [{:keys
    [product-code
     quantity
     available-stock
     reserved-stock
     customer-type]}]
  (when (str/blank? product-code)
    (throw
     (ex-info
      "product-code must not be blank"
      {:field :product-code
       :value product-code})))
  (when (< quantity 1)
    (throw
     (ex-info
      (str "quantity must be at least 1: " quantity)
      {:field :quantity
       :value quantity})))
  (when (neg? available-stock)
    (throw
     (ex-info
      (str "available-stock must not be negative: "
           available-stock)
      {:field :available-stock
       :value available-stock})))
  (when (neg? reserved-stock)
    (throw
     (ex-info
      (str
       "reserved-stock must not be negative: "
       reserved-stock)
      {:field :reserved-stock
       :value reserved-stock})))
  (when-not (contains?
             valid-customer-types
             customer-type)
    (throw
     (ex-info
      (str
       "unsupported customer-type: "
       customer-type)
      {:field :customer-type
       :value customer-type})))
  nil)

(defn calculate-priority-allocation
  [{:keys
    [quantity
     available-stock
     reserved-stock]}]
  (let [remaining-quantity
        (- quantity available-stock)
        used-reserved-stock
        (min remaining-quantity reserved-stock)]
    {:status :priority-reservation
     :allocated-quantity quantity
     :used-reserved-stock used-reserved-stock}))

(defn evaluate-order
  [{:keys [quantity
           available-stock
           reserved-stock
           customer-type]
    :as order}]
  (validate-order order)

  (let [total-stock
        (+ available-stock reserved-stock)]
    (cond
      (>= available-stock quantity)
      {:status :accepted
       :allocated-quantity quantity}

      (and
       (= customer-type :priority)
       (>= total-stock quantity))
      (calculate-priority-allocation order)

      :else
      {:status :rejected
       :shortage-quantity
       (if (= customer-type :priority)
        (- quantity total-stock)
        (- quantity available-stock))})))
