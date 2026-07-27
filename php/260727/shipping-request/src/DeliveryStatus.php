<?php
declare(strict_types=1);
namespace App;

enum DeliveryStatus: string
{
  case Pending = 'pending';
  case Confirmed = 'confirmed';
}
