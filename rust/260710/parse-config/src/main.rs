#[derive(Debug, PartialEq)]
pub struct ConfigEntry {
    pub key: String,
    pub value: String,
}

pub fn parse_config_line(line: &str) -> Option<ConfigEntry> {
    let trimmed = line.trim();

    if trimmed.is_empty() {
        return None;
    }

    // これはタプル表記の変数宣言やで
    let (key, value) = match trimmed.split_once('=') {
        // pair という名前の仮変数名でデータを受け取ってそのままreturn
        Some(pair) => pair,
        None => return None,
    };

    let key = key.trim();
    let value = value.trim();

    if key.is_empty() || value.is_empty() {
        return None;
    }

    Some(ConfigEntry {
        key: key.to_string(),
        value: value.to_string()
    })
}

fn main() {
    let line = "thme = dark";

    match parse_config_line(line) {
        Some(entry) => {
            println!("key: {}", entry.key);
            println!("value: {}", entry.value);
        }
        None => {
            println!("設定行として読み取れませんでした");
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_valid_config_line() {
        // 1. "theme=dark" のような正しい設定文字列を用意してください。
        let line = "fruit=apple";
        // 2. parse_config_line を呼び出してください。
        let result = parse_config_line(line);
        // 3. Some(ConfigEntry { key: "theme", value: "dark" }) が返ることを確認してください。
        let expected = Some(ConfigEntry{
            key: "fruit".to_string(),
            value: "apple".to_string(),
        });

        assert_eq!(result, expected);
    }

    #[test]
    fn parse_config_line_with_spaces() {
        // 1. " theme = dark " のように前後や = の周辺に空白がある文字列を用意してください。
        let line = "  theme  =  light  ";
        // 2. parse_config_line を呼び出してください。
        let result = parse_config_line(line);
        // 3. key と value の空白が取り除かれていることを確認してください。
        let expected = Some(ConfigEntry{
            key: "theme".to_string(),
            value: "light".to_string(),
        });

        assert_eq!(result, expected);
    }

    #[test]
    fn return_none_when_equal_sign_is_missing() {
        // 1. "theme" のように = がない文字列を用意してください。
        let line = "  theme  ";
        // 2. parse_config_line を呼び出してください。
        let result = parse_config_line(line);
        // 3. None が返ることを確認してください。
        //let expected = None;

        //assert_eq!(result, expected);
        assert!(result.is_none());
    }

    #[test]
    fn return_none_when_key_or_value_is_empty() {
        // 1. "=dark" または "theme=" のような不完全な文字列を用意してください。
        let line = "  theme=  ";
        // 2. parse_config_line を呼び出してください。
        let result = parse_config_line(line);
        // 3. None が返ることを確認してください。
        //let expected = None;

        //assert_eq!(result, expected);
        assert!(result.is_none());
    }
}
