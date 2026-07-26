(ns build
  (:require
   [clojure.tools.build.api :as b]))

(def lib
  'inventory-service/inventory-service)

(def version
  "0.1.0")

(def class-dir
  "target/classes")

(def uber-file
  (format "target/inventory-service-%s-standalone.jar"
          version))

(def basis
  (delay
    (b/create-basis
     {:project "deps.edn"})))

(defn clean
  "targetディレクトリを削除する。"
  [_]
  (b/delete {:path "target"})
  (println "Cleaned target directory."))

(defn uber
  "依存ライブラリを含む実行可能Uberjarを作る。"
  [_]
  (clean nil)

  (b/copy-dir
   {:src-dirs ["src" "resources"]
    :target-dir class-dir})

  (b/compile-clj
   {:basis @basis
    :src-dirs ["src"]
    :class-dir class-dir
    :ns-compile '[inventory-service.main]})

  (b/uber
   {:class-dir class-dir
    :uber-file uber-file
    :basis @basis
    :main 'inventory-service.main})

  (println "Created" uber-file))
