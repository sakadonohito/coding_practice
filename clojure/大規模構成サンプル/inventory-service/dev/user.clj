(ns user
  (:require
   [clojure.test :as test]
   [inventory-service.application.item-service :as item-service]
   [inventory-service.domain.item :as item]))

(def sample-item
  {:id 1
   :name "Apple"
   :quantity 10})

(defn check-item []
  (item/valid-item? sample-item))

(defn show-item []
  (item-service/item-summary sample-item))

(defn run-tests []
  (test/run-all-tests #"inventory-service\..*-test"))
