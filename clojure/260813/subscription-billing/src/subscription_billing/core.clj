(ns subscription-billing.core
  (:require [clojure.string :as str]))

(def plan-prices
  {:basic 1000
   :standard 1800
   :premium 3000})

(def valid-discount-codes
  #{nil "WELCOME10"})

(defn validation-error
  "入力値が不正なことを表すExceptionInfoを作る。"
  [field value subscription-id]
  (ex-info (str "invalid subscription field: " (name field))
           {:field field
            :value value
            :subscription-id subscription-id}))

(defn validate-subscription
  "契約を検証し、正常なら受け取った契約をそのまま返す。"
  [{:keys [id plan seats months discount-code] :as subscription}]
  (cond
    (or (not (string? id)) (str/blank? id))
      (throw (validation-error :id id id))
    (not (contains? plan-prices plan))
      (throw (validation-error :plan plan id))
    (not (and (integer? seats) (pos? seats)))
      (throw (validation-error :seats seats id))
    (not (and (integer? months) (<= 1 months 12)))
      (throw (validation-error :months months id))
    (not (contains? valid-discount-codes discount-code))
      (throw (validation-error :discount-code discount-code id))
    :else subscription))

(defn calculate-subscription
  "契約1件を検証し、請求計算の項目を追加して返す。"
  [subscription]
  (validate-subscription subscription)
  (let [{:keys [plan seats months discount-code]} subscription
        unit-price (plan-prices plan)
        subtotal (* unit-price seats months)
        discount-amount (if (= discount-code "WELCOME10")
                          (quot subtotal 10)
                          0)
        total-amount (- subtotal discount-amount)]

    (assoc subscription
           :unit-price unit-price
           :subtotal subtotal
           :discount-amount discount-amount
           :total-amount total-amount)))

(defn validate-unique-ids
  "一覧内のID重複を検証し、正常なら入力をそのまま返す。"
  [subscriptions]
  (reduce
   (fn [seen-ids {:keys [id]}]
     (if (contains? seen-ids id)
       (throw (ex-info (str "duplicate subscription id: " id)
                       {:field :id :value id}))
       (conj seen-ids id)))
   #{}
   subscriptions)
  subscriptions)

(def empty-summary
  {:subscriptions []
   :subscription-count 0
   :total-seats 0
   :total-before-discount 0
   :total-discount 0
   :total-billed 0
   :counts-by-plan {:basic 0
                    :standard 0
                    :premium 0}})

(defn summarize-subscriptions
  "契約一覧を検証・計算し、全体の請求サマリーを返す。"
  [subscriptions]
  (validate-unique-ids subscriptions)
  (let [calculated-subs (mapv calculate-subscription subscriptions)]
    (reduce
     (fn [summary sub]
       (-> summary
           (update :subscriptions conj sub)
           (update :subscription-count inc)
           (update :total-seats + (:seats sub))
           (update :total-before-discount + (:subtotal sub))
           (update :total-discount + (:discount-amount sub))
           (update :total-billed + (:total-amount sub))
           (update-in [:counts-by-plan (:plan sub)] inc)))
       empty-summary
       calculated-subs)))
