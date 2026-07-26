#!/usr/bin/env python3

import pytest

from parse_config.lib import (
    parse_config_line,
    ConfigEntry,
    Success,
    Failure,
    ParseError,
)


def test_valid_line():
    # "timeout=30" を解析してください。
    result = parse_config_line("timeout=30")
    # Success(ConfigEntry("timeout", "30"))
    # になることを確認してください。
    expected = Success(ConfigEntry("timeout", "30"))
    assert result == expected


def test_spaces_are_trimmed():
    # " host = localhost "
    # を解析してください。
    # Success(ConfigEntry("host", "localhost"))
    # になることを確認してください。
    result = parse_config_line(" host = localhost ")
    expected = Success(ConfigEntry("host", "localhost"))
    assert result == expected


def test_missing_equal():
    # "timeout"
    # を解析してください。
    # Failure(ParseError.INVALID_FORMAT)
    # になることを確認してください。
    result = parse_config_line("timeout")
    expected = Failure(ParseError.INVALID_FORMAT)
    assert result == expected


def test_empty_key():
    # "=value"
    # を解析してください。
    # Failure(ParseError.EMPTY_KEY)
    # になることを確認してください。
    result = parse_config_line("=value")
    expected = Failure(ParseError.EMPTY_KEY)
    assert result == expected


def test_empty_value():
    # "name="
    # を解析してください。
    # Failure(ParseError.EMPTY_VALUE)
    # になることを確認してください。
    result = parse_config_line("name=")
    expected = Failure(ParseError.EMPTY_VALUE)
    assert result == expected
