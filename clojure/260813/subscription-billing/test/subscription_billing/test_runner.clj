(ns subscription-billing.test-runner
  (:require [clojure.test :as test]
            [subscription-billing.core-test]))

(defn -main
  [& _args]
  (let [{:keys [fail error]}
        (test/run-tests 'subscription-billing.core-test)]
    (when (pos? (+ fail error))
      (System/exit 1))))
