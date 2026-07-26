#[derive(Debug, PartialEq, Eq)]
pub struct RetryConfig {
    pub retry_count: u8,
}

#[derive(Debug, PartialEq, Eq)]
pub enum RetryConfigError {
    EmptyInput,
    InvalidNumber,
    OutOfRange { value: u8, min: u8, max: u8 },
}

pub fn parse_retry_config(input: &str) -> Result<RetryConfig, RetryConfigError> {
    let trimmed = input.trim();

    if trimmed.is_empty() {
        return Err(RetryConfigError::EmptyInput);
    }

    let retry_count = match trimmed.parse::<u8>() {
        Ok(value) => value,
        Err(_) => {
            return Err(RetryConfigError::InvalidNumber);
        }
    };

    const MIN_RETRY_COUNT: u8 = 1;
    const MAX_RETRY_COUNT: u8 = 5;

    if !(MIN_RETRY_COUNT..=MAX_RETRY_COUNT).contains(&retry_count) {
        return Err(RetryConfigError::OutOfRange {
            value: retry_count,
            min: MIN_RETRY_COUNT,
            max: MAX_RETRY_COUNT,
        });
    }

    Ok(RetryConfig { retry_count })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn valid_retry_count_returns_config() {
        // "3"をparse_retry_configへ渡してください。
        let actual = parse_retry_config("3");
        // Ok(RetryConfig { retry_count: 3 })になることを確認してください。
        assert_eq!(actual, Ok(RetryConfig { retry_count: 3 }));
    }

    #[test]
    fn surrounding_spaces_are_ignored() {
        // " 5 "をparse_retry_configへ渡してください。
        let actual = parse_retry_config(" 　5　 ");
        // Ok(RetryConfig { retry_count: 5 })になることを確認してください。
        assert_eq!(actual, Ok(RetryConfig { retry_count: 5 }));
    }

    #[test]
    fn empty_text_returns_empty_input_error() {
        // 空文字列をparse_retry_configへ渡してください。
        let actual = parse_retry_config("");
        // Err(RetryConfigError::EmptyInput)になることを確認してください。
        assert_eq!(actual, Err(RetryConfigError::EmptyInput));
    }

    #[test]
    fn whitespace_only_returns_empty_input_error() {
        // 空白だけの文字列をparse_retry_configへ渡してください。
        let actual = parse_retry_config(" 　");
        // Err(RetryConfigError::EmptyInput)になることを確認してください。
        assert_eq!(actual, Err(RetryConfigError::EmptyInput));
    }

    #[test]
    fn non_numeric_text_returns_invalid_number_error() {
        // "three"をparse_retry_configへ渡してください。
        let actual = parse_retry_config("three");
        // Err(RetryConfigError::InvalidNumber)になることを確認してください。
        assert_eq!(actual, Err(RetryConfigError::InvalidNumber));
    }

    #[test]
    fn zero_returns_out_of_range_error() {
        // "0"をparse_retry_configへ渡してください。
        let actual = parse_retry_config("0");
        // valueが0、minが1、maxが5の
        // Err(RetryConfigError::OutOfRange { ... })
        // になることを確認してください。
        let expected = Err(RetryConfigError::OutOfRange {
            value: 0,
            min: 1,
            max: 5,
        });
        assert_eq!(actual, expected);
    }

    #[test]
    fn six_returns_out_of_range_error() {
        // "6"をparse_retry_configへ渡してください。
        let actual = parse_retry_config("6");
        // valueが6、minが1、maxが5の
        // Err(RetryConfigError::OutOfRange { ... })
        // になることを確認してください。
        let expected = Err(RetryConfigError::OutOfRange {
            value: 6,
            min: 1,
            max: 5,
        });
        assert_eq!(actual, expected);
    }

    #[test]
    fn negative_number_returns_invalid_number_error() {
        // "-1"をparse_retry_configへ渡してください。
        let actual = parse_retry_config("-1");
        // u8には負数を格納できないため、
        // Err(RetryConfigError::InvalidNumber)になることを確認してください。
        assert_eq!(actual, Err(RetryConfigError::InvalidNumber));
    }
}
