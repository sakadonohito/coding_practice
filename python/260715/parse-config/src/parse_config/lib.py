#!/usr/bin/env python3

from dataclasses import dataclass
from enum import Enum, auto

@dataclass(frozen=True)
class ConfigEntry:
    key: str
    value: str

class ParseError(Enum):
    INVALID_FORMAT = auto()
    EMPTY_KEY = auto()
    EMPTY_VALUE = auto()

@dataclass(frozen=True)
class Success:
    value: ConfigEntry

@dataclass(frozen=True)
class Failure:
    error: ParseError

def parse_config_line(text: str):
    if "=" not in text:
        return Failure(ParseError.INVALID_FORMAT)

    key, value = text.split("=", 1)

    key = key.strip()
    value = value.strip()

    if key == "":
        return Failure(ParseError.EMPTY_KEY)

    if value == "":
        return Failure(ParseError.EMPTY_VALUE)

    return Success(ConfigEntry(key, value))
