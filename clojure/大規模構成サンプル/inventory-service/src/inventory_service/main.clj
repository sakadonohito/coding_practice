(ns inventory-service.main
  (:require
   [inventory-service.application.item-service :as item-service])
  (:gen-class))

(defn -main
  "アプリケーションのエントリーポイント."
  [& args]
  (println "Inventory Service")
  (println "Arguments:" args)
  (println (item-service/item-summary
            {:id 1
             :name "Apple"
             :quantity 10})))
