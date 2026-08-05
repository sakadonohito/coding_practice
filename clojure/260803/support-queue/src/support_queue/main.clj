(ns support-queue.main
  (:require
   [support-queue.core :as queue]))

(def sample-tickets
  [{:id "T-001"
    :customer-tier :standard
    :severity :medium
    :waiting-minutes 20
    :status :open}

   {:id "T-002"
    :customer-tier :premium
    :severity :high
    :waiting-minutes 75
    :status :open}

   {:id "T-003"
    :customer-tier :standard
    :severity :high
    :waiting-minutes 130
    :status :in-progress}

   {:id "T-004"
    :customer-tier :premium
    :severity :low
    :waiting-minutes 200
    :status :closed}])

(defn -main
  [& _args]
  (let [tickets
        (queue/build-queue sample-tickets)

        summary
        (queue/summarize-queue tickets)]
    (doseq [ticket tickets]
      (println
       (:id ticket)
       (:priority-score ticket)
       (:queue-level ticket)))

    (println summary)))
