(ns config-parser.application.core-test
  (:require [clojure.test :refer [deftest is testing]]
            [config-parser.application.core :refer [parse-config-line]]))

(deftest parse-config-line-test

  (testing "KEY=VALUE形式の文字列を解析できる"
    ;; "timeout=30"を渡す。
    ;; {:ok {:key "timeout" :value "30"}}になることを確認する。
    (is (= {:ok {:key   "timeout"
                 :value "30"}}
           (parse-config-line "timeout=30"))))

  (testing "キーと値の前後にある空白を除去する"
    ;; "  timeout  =  30  "を渡す。
    ;; keyが"timeout"、valueが"30"になることを確認する。
    (is (= {:ok {:key   "timeout"
                 :value "30"}}
           (parse-config-line "  timeout  =  30  "))))

  (testing "nilは空行エラーになる"
    ;; nilを渡す。
    ;; {:error :blank-line}になることを確認する。
    (is (= {:error :blank-line}
           (parse-config-line nil))))

  (testing "空白だけの文字列は空行エラーになる"
    ;; "   "を渡す。
    ;; {:error :blank-line}になることを確認する。
    (is (= {:error :blank-line}
           (parse-config-line "   "))))

  (testing "区切り文字がない場合は形式エラーになる"
    ;; "timeout"を渡す。
    ;; {:error :invalid-format}になることを確認する。
    (is (= {:error :invalid-format}
           (parse-config-line "timeout"))))

  (testing "区切り文字が複数ある場合は形式エラーになる"
    ;; "url=https://example.com"を渡す。;; ← サンプルコードコメントが間違っている
    ;; "url=https://example.com="を渡す。
    ;; {:error :invalid-format}になることを確認する。
    (is (= {:error :invalid-format}
           (parse-config-line "url=https://example.com="))))

  (testing "キーが空の場合はキー不足エラーになる"
    ;; "=30"を渡す。
    ;; {:error :missing-key}になることを確認する。
    (is (= {:error :missing-key}
           (parse-config-line "=30"))))

  (testing "値が空の場合は値不足エラーになる"
    ;; "timeout="を渡す。
    ;; {:error :missing-value}になることを確認する。
    (is (= {:error :missing-value}
           (parse-config-line "timeout=")))))
