import sys
import tempfile
import webbrowser
import markdown
from pygments.formatters import HtmlFormatter

def main():
    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        text = f.read()

    # 1. Pygments の CSS スタイルを自動生成 (テーマ: "default" や "github-dark", "monokai" 等)
    # .codehilite クラスに対してハイライト色を当てる
    formatter = HtmlFormatter(style="friendly")
    pygments_css = formatter.get_style_defs(".codehilite")

    # 2. Markdown を HTML に変換
    html_body = markdown.markdown(
        text,
        extensions=["fenced_code", "codehilite", "tables"],
        extension_configs={
            "codehilite": {
                "guess_lang": False,
                "css_class": "codehilite",
            }
        },
    )

    # 3. pygments_css をスタイルの中に組み込む
    html = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Markdown Viewer</title>
  <style>
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      max-width: 850px;
      margin: 40px auto;
      padding: 0 20px;
      line-height: 1.6;
      color: #333;
    }}
    pre {{
      padding: 14px;
      overflow-x: auto;
      border-radius: 6px;
      background-color: #f6f8fa;
      border: 1px solid #e1e4e8;
    }}
    code {{
      font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
      font-size: 85%;
    }}
    /* Pygments の自動生成スタイルを組み込む */
    {pygments_css}
  </style>
</head>
<body>
  {html_body}
</body>
</html>"""

    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
        f.write(html)
        webbrowser.open("file://" + f.name)

if __name__ == "__main__":
    main()
