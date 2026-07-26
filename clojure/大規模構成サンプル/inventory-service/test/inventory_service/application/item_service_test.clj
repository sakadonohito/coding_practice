(ns inventory-service.application.item-service-test
  (:require
   [clojure.test :refer [deftest is testing]]
   [inventory-service.application.item-service :as item-service]))

(deftest item-summary-test
  (testing "有効な商品を表示用文字列に変換する"
    (is (= "ID=1, name=Apple, quantity=10"
           (item-service/item-summary
            {:id 1
             :name "Apple"
             :quantity 10}))))

  (testing "無効な商品ではエラー文字列を返す"
    (is (= "Invalid item"
           (item-service/item-summary
            {:id 1
             :name ""
             :quantity 10})))))
