(ns inventory-service.domain.item-test
  (:require
   [clojure.test :refer [deftest is testing]]
   [inventory-service.domain.item :as item]))

(deftest valid-name-test
  (testing "空でない文字列は有効"
    (is (true? (item/valid-name? "Apple"))))

  (testing "空文字列は無効"
    (is (false? (item/valid-name? ""))))

  (testing "空白だけの文字列は無効"
    (is (false? (item/valid-name? "   "))))

  (testing "文字列以外は無効"
    (is (false? (item/valid-name? nil)))))

(deftest valid-quantity-test
  (testing "0以上の整数は有効"
    (is (true? (item/valid-quantity? 0)))
    (is (true? (item/valid-quantity? 10))))

  (testing "負数は無効"
    (is (false? (item/valid-quantity? -1))))

  (testing "整数以外は無効"
    (is (false? (item/valid-quantity? 1.5)))))

(deftest valid-item-test
  (testing "必要な値が揃った商品は有効"
    (is (true?
         (item/valid-item?
          {:id 1
           :name "Apple"
           :quantity 10}))))

  (testing "商品名が空なら無効"
    (is (false?
         (item/valid-item?
          {:id 1
           :name ""
           :quantity 10}))))

  (testing "在庫数が負数なら無効"
    (is (false?
         (item/valid-item?
          {:id 1
           :name "Apple"
           :quantity -1})))))
