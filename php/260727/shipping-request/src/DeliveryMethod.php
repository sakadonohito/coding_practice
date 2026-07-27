<?php
declare(strict_types=1);
namespace App;

enum DeliveryMethod: string
{
  case Standard = 'standard';
  case Express = 'express';
  case Pickup = 'pickup';

  public function requiresPostalCode(): bool
  {
    return match ($this) {
      self::Standard,
      self::Express => true,
      self::Pickup => false,
    };
  }
}
