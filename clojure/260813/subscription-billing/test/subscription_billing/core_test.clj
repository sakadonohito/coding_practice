(ns subscription-billing.core-test
  (:require [clojure.test :refer [deftest is testing]]
            [subscription-billing.core :as sut]))

(deftest calculate-basic-subscription-test
  (testing "割引なしのbasic契約を計算できる"
    (let [input {:id "SUB-001", :plan :basic, :seats 2, :months 3, :discount-code nil}
          expected {:id "SUB-001", :plan :basic, :seats 2, :months 3, :discount-code nil
                    :unit-price 1000 :subtotal 6000 :discount-amount 0 :total-amount 6000}]
      (is (= expected (sut/calculate-subscription input))))))

(deftest calculate-welcome-discount-test
  (testing "WELCOME10で割引前金額の10%が差し引かれる"
    (let [input {:id "SUB-001", :plan :standard, :seats 3, :months 1, :discount-code "WELCOME10"}
          expected {:id "SUB-001", :plan :standard, :seats 3, :months 1, :discount-code "WELCOME10"
                    :unit-price 1800 :subtotal 5400 :discount-amount 540 :total-amount 4860}]
      (is (= expected (sut/calculate-subscription input))))))

(deftest summarize-multiple-subscriptions-test
  (testing "複数契約の件数・人数・金額・プラン別件数を集計できる"
    (let [input1 {:id "SUB-001", :plan :basic, :seats 2, :months 3, :discount-code nil}
          input2 {:id "SUB-002", :plan :standard, :seats 3, :months 1, :discount-code "WELCOME10"}
          input3 {:id "SUB-003", :plan :premium, :seats 1, :months 2, :discount-code nil}
          summary (sut/summarize-subscriptions [input1 input2 input3])]
      (is (= 3 (:subscription-count summary)))
      (is (= 6 (:total-seats summary)))
      (is (= 17400 (:total-before-discount summary)))
      (is (= 540 (:total-discount summary)))
      (is (= 16860 (:total-billed summary)))
      (is (= {:basic 1 :standard 1 :premium 1}
             (:counts-by-plan summary)))
      (is (= ["SUB-001" "SUB-002" "SUB-003"]
             (mapv :id (:subscriptions summary)))))))

(deftest summarize-empty-subscriptions-test
  (testing "空の契約一覧からゼロ値のサマリーを返す"
    (is (= sut/empty-summary (sut/summarize-subscriptions [])))))

(deftest duplicate-id-test
  (testing "契約IDが重複している場合はExceptionInfoを投げる"
    (let [sub1 {:id "SUB-001" :plan :standard :seats 1 :months 1 :discount-code nil}
          sub2 {:id "SUB-001" :plan :basic :seats 2 :months 2 :discount-code nil}

          error (try
                  (sut/summarize-subscriptions [sub1 sub2])
                  nil
                  (catch clojure.lang.ExceptionInfo e
                    e))]
      (is (some? error))
      (is (= {:field :id :value "SUB-001"}
             (ex-data error))))))

(deftest invalid-subscription-fields-test
  (testing "不正なフィールドごとに対象のfieldとvalueを返す"
    (let [base {:id "SUB-001" :plan :standard :seats 3 :months 6 :discount-code nil}
          test-cases [[:id "   " (assoc base :id "   ")]
                     [:plan :enterprise (assoc base :plan :enterprise)]
                     [:seats 0 (assoc base :seats 0)]
                     [:seats 1.5 (assoc base :seats 1.5)]
                     [:months 13 (assoc base :months 13)]
                     [:discount-code "SUMMER20" (assoc base :discount-code "SUMMER20")]]]
      (doseq [[expected-field expected-value invalid-sub] test-cases]
        (let [error (try
                      (sut/calculate-subscription invalid-sub)
                      nil
                      (catch clojure.lang.ExceptionInfo e
                        e))]
          (is (some? error))
          (is (= expected-field (:field (ex-data error))))
          (is (= expected-value (:value (ex-data error)))))))))
