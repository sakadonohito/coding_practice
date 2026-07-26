from parse_config.lib import (
    parse_config_line,
    ConfigEntry,
    Success,
    Failure,
    ParseError,
)

def main():
    result = parse_config_line("timeout=30")
    print(result)


if __name__ == "__main__":
    main()
