<?php
declare(strict_types=1);

namespace App;

enum ExpenseCategory: string
{
  case Travel = 'travel';
  case Meal = 'meal';
  case Supplies = 'supplies';

  public function approvalLimit(): int
  {
    return match ($this) {
      self::Travel => 20_000,
      self::Meal => 3_000,
      self::Supplies => 10_000,
    };
  }
}
