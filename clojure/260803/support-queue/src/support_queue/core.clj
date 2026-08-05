(ns support-queue.core
  (:require
   [clojure.string :as str]))

(def valid-customer-tiers
  #{:standard :premium})

(def valid-severities
  #{:low :medium :high})

(def valid-statuses
  #{:open :in-progress :closed})

(def severity-scores
  {:low 10
   :medium 30
   :high 60})

(def customer-tier-scores
  {:standard 0
   :premium 20})

(defn validate-ticket
  "チケットの各フィールドを検証する。
   正常ならnil、不正ならExceptionInfoを投げる。"
  [{:keys
    [id
     customer-tier
     severity
     waiting-minutes
     status]}]
  (when (str/blank? id)
    (throw
     (ex-info
      "id must not be blank"
      {:field :id
       :value id})))

  (when-not (nat-int? waiting-minutes)
    (throw
     (ex-info
      (str "waiting-minutes must be a non-negative integer: " waiting-minutes)
      {:field :waiting-minutes
       :value waiting-minutes
       :ticket-id id})))

  (when-not (contains? valid-customer-tiers customer-tier)
    (throw
     (ex-info
      (str "unsupported customer-tier: " customer-tier)
      {:field :customer-tier
       :value customer-tier
       :ticket-id id})))

  (when-not (contains? valid-severities severity)
    (throw
     (ex-info
      (str "unsupported severity: " severity)
      {:field :severity
       :value severity
       :ticket-id id})))

  (when-not (contains? valid-statuses status)
    (throw
     (ex-info
      (str "unsupported status: " status)
      {:field :status
       :value status
       :ticket-id id})))
  nil)

(defn waiting-score
  "待ち時間から0、10、25、40のいずれかを返す。"
  [waiting-minutes]
  (cond
    (>= waiting-minutes 120) 40
    (>= waiting-minutes 60) 25
    (>= waiting-minutes 30) 10
    (>= waiting-minutes 0) 0
    :else
  (throw
   (ex-info
    (str "waiting-minutes must be a non-negative integer: " waiting-minutes)
    {:field :waiting-minutes
     :value waiting-minutes}))))

(defn priority-score
  "重要度、顧客区分、待ち時間の点数を合計する。"
  [{:keys
    [severity
     customer-tier
     waiting-minutes]}]
  (+ (severity-scores severity)
     (customer-tier-scores customer-tier)
     (waiting-score waiting-minutes)))

(defn queue-level
  "優先度スコアから:critical、:urgent、:normalを返す。"
  [score]
  (cond
    (>= score 100) :critical
    (>= score 60) :urgent
    (>= score 0) :normal
    :else
    (throw
     (ex-info
      (str "score must be a non-negative integer: " score)
      {:field :score
       :value score}))))

(defn enrich-ticket
  "元のチケットへスコアとレベルを追加した新しいマップを返す。"
  [ticket]
  (let [score (priority-score ticket)
        level (queue-level score)]
    (assoc
     ticket
     :priority-score score
     :queue-level level)))

(defn validate-unique-ids
  "チケットIDの重複を検証する。正常ならnilを返す。"
  [tickets]
  (when-let [dup-id
             (some (fn [[id n]]
                     (when (> n 1)
                       id))
                   (frequencies (map :id tickets)))]
    (throw
     (ex-info
      (str "duplicate ticket id: " dup-id)
      {:field :id
       :value dup-id}))))

(defn build-queue
  "チケットを検証し、対応対象を優先順で返す。"
  [tickets]
  (doseq [ticket tickets]
    (validate-ticket ticket))
  (validate-unique-ids tickets)
  (->> tickets
       ;; (remove #(= (:status %) :closed))
       (filter #(not= (:status %) :closed))
       (map enrich-ticket)
       (sort-by (fn [{:keys
                      [priority-score
                       waiting-minutes
                       id]}]
                  [(- priority-score)
                   (- waiting-minutes)
                   id]))
       vec))

(defn summarize-queue
  "対応キューの件数、レベル別件数、最長待ちIDを返す。"
  [queue]
  ;; TODO:
  ;; :total
  ;; countを使う。
  ;; :counts-by-level
  ;; mapで:queue-levelだけを取り出し、
  ;; frequenciesを使う。
  ;; :longest-waiting-ticket-id
  ;; max-keyでは同値時の扱いが仕様とずれる可能性がある。
  ;; (- waiting-minutes)とidでsort-byし、
  ;; firstから:idを取り出す。
  ;; 空ならnilを返す。
  (let [
        total (count queue)
        count-by-levels
        (frequencies (map :queue-level queue))
        longest-id
        (some-> (sort-by (fn [{:keys
                               [waiting-minutes
                                id]}]
                           [(- waiting-minutes)
                            id]) queue)
                first
                :id)]
    {:total total
     :counts-by-level count-by-levels
     :longest-waiting-ticket-id longest-id}))
