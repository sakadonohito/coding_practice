(ns config-parser.application.core
  (:require [clojure.string :as str]))

(defn parse-config-line
  "KEY=VALUE形式の文字列を解析する。

  成功:
  {:ok {:key \"timeout\" :value \"30\"}}

  失敗:
  {:error :blank-line}
  {:error :invalid-format}
  {:error :missing-key}
  {:error :missing-value}"
  [line]
  (cond
    (or (nil? line)
        (str/blank? line))
    {:error :blank-line}

    :else
    (let [parts (str/split line #"=" -1)]
      (if (not= 2 (count parts))
        {:error :invalid-format}

        (let [[raw-key raw-value] parts
              key-text (str/trim raw-key)
              value-text (str/trim raw-value)]
          (cond
            (str/blank? key-text)
            {:error :missing-key}

            (str/blank? value-text)
            {:error :missing-value}

            :else
            {:ok {:key key-text
                  :value value-text}}))))))
