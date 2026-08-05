(ns support-queue.core-test
  (:require
   [clojure.test
    :refer
    [deftest
     is
     testing]]
   [support-queue.core :as queue]))

(deftest calculates-waiting-score-at-boundaries
  (testing
   "待ち時間の境界値を表形式で検証する"
    (let [tests
          [{:minutes 0 :expected 0}
           {:minutes 29 :expected 0}
           {:minutes 30 :expected 10}
           {:minutes 59 :expected 10}
           {:minutes 60 :expected 25}
           {:minutes 119 :expected 25}
           {:minutes 120 :expected 40}]]
      (doseq [{:keys [minutes expected]} tests]
        (testing (str expected "?")
           (is (= expected
                  (queue/waiting-score minutes))))))))

(deftest calculates-priority-score-and-level
  (testing
      "重要度、顧客区分、待ち時間から優先度を計算する"
    (let [ticket {:id "T-001"
                  :customer-tier :premium
                  :severity :high
                  :waiting-minutes 75
                  :status :open}
          actual-score
          (queue/priority-score ticket)
          actual-level
          (queue/queue-level actual-score)
          actual-enrich
          (queue/enrich-ticket ticket)]

      (is (= 105 actual-score))
      (is (= :critical actual-level))
      (is (= 105 (:priority-score actual-enrich)))
      (is (= :critical (:queue-level actual-enrich))))))

(deftest validates-ticket-fields
  (testing
   "バリデーションパターンを全て検査する"
    (let [tests
          [{:name "IDが空"
            :ticket {:id "　" :customer-tier :standard :severity :medium :waiting-minutes 10 :status :open}
            :expected-field :id}
           {:name "待ち時間がマイナス"
            :ticket {:id "T-001" :customer-tier :standard :severity :medium :waiting-minutes -1 :status :open}
            :expected-field :waiting-minutes}
           {:name "不正なcustomer-tier"
            :ticket {:id "T-002" :customer-tier :vip :severity :medium :waiting-minutes 10 :status :open}
            :expected-field :customer-tier}
           {:name "不正なseverity"
            :ticket {:id "T-003" :customer-tier :standard :severity :ignore :waiting-minutes 10 :status :open}
            :expected-field :severity}
           {:name "不正なstatus"
            :ticket {:id "T-004" :customer-tier :standard :severity :medium :waiting-minutes 10 :status :freeze}
            :expected-field :status}
]]
      (doseq [{:keys [name ticket expected-field]} tests]
        (testing name
          (let [err (try
                      (queue/validate-ticket ticket)
                      nil
                      (catch clojure.lang.ExceptionInfo e
                        e))]
            (is (some? err)
                (str name "でExceptionInfoが必要"))
            (is (= expected-field (:field (ex-data err))))))))))

(deftest builds-queue-in-priority-order
  (testing
      "closedを除外し、スコアと待ち時間で並べる"
    (let [tickets [{:id "T-001"
                    :customer-tier :premium
                    :severity :high
                    :waiting-minutes 75
                    :status :open}
                   {:id "T-002"
                    :customer-tier :standard
                    :severity :high
                    :waiting-minutes 130
                    :status :in-progress}
                   {:id "T-003"
                    :customer-tier :standard
                    :severity :medium
                    :waiting-minutes 20
                    :status :open}
                   {:id "T-004"
                    :customer-tier :premium
                    :severity :high
                    :waiting-minutes 200
                    :status :closed}]
          actual (queue/build-queue tickets)]
      (is (= ["T-001" "T-002" "T-003"] (map :id actual)))
      (is (not (contains? (set (map :id actual)) "T-004" )))
      ;; 先頭のチケットが〜ではなくT-001のqueue-levelが〜だったのでこうした。
      (let [t1 (first (filter #(= (:id %) "T-001") actual))]
        (is (= :critical (:queue-level t1))))
      )))

(deftest uses-waiting-time-and-id-as-tie-breakers
  (testing
   "同点なら待ち時間、さらに同点ならIDで並べる"
    (let [tickets [{:id "T-001"
                    :customer-tier :standard
                    :severity :high
                    :waiting-minutes 20
                    :status :open}
                   {:id "T-002"
                    :customer-tier :premium
                    :severity :medium
                    :waiting-minutes 50
                    :status :open}
                   {:id "T-003"
                    :customer-tier :premium
                    :severity :medium
                    :waiting-minutes 50
                    :status :open}]
          actual (queue/build-queue tickets)]
      (is (= ["T-002" "T-003" "T-001"] (map :id actual))))))

(deftest rejects-duplicate-ticket-id
  (testing
   "同じIDが2件あればExceptionInfoを投げる"
    (let [tickets [{:id "T-001"
                    :customer-tier :standard
                    :severity :medium
                    :waiting-minutes 15
                    :status :open}
                   {:id "T-002"
                    :customer-tier :standard
                    :severity :medium
                    :waiting-minutes 15
                    :status :open}
                   {:id "T-001"
                    :customer-tier :standard
                    :severity :medium
                    :waiting-minutes 15
                    :status :open}]
          exception
          (try
            ;; validate-unique-ids 単体テスト
            ;; (queue/validate-unique-ids tickets)
            (queue/build-queue tickets)
            nil
            (catch clojure.lang.ExceptionInfo error
              error))
          expected
          (ex-info
           "duplicate ticket id: T-001"
           {:field :id
            :value "T-001"})]
      (is (some? exception))
      (is (= (ex-message expected)
             (ex-message exception)))
      (is (= (ex-data expected)
             (ex-data exception))))))

(deftest summarizes-queue
  (testing
   "合計、レベル別件数、最長待ちIDを集計する"
    (let [tickets [{:id "T-001"
                    :customer-tier :standard
                    :severity :high
                    :waiting-minutes 60
                    :status :open}

                   {:id "T-002"
                    :customer-tier :premium
                    :severity :high
                    :waiting-minutes 60
                    :status :open}

                   {:id "T-003"
                    :customer-tier :standard
                    :severity :medium
                    :waiting-minutes 130
                    :status :open}

                   {:id "T-004"
                    :customer-tier :standard
                    :severity :low
                    :waiting-minutes 10
                    :status :open}]
          queued-tickets (queue/build-queue tickets)
          actual (queue/summarize-queue queued-tickets)]

      (is (= "T-003" (:longest-waiting-ticket-id actual)))
      (is (= {:total 4
              :counts-by-level
              {:critical 1
               :urgent 2
               :normal 1}
              :longest-waiting-ticket-id "T-003"}
             actual))
      )))
