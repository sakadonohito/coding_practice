<?php
declare(strict_types=1);
namespace App;
use InvalidArgumentException;

final class ShippingRequestFactory
{
  /**
   * @param list<string> $productCodes
   */
  public static function create(
    string $orderNumber,
    string $recipientName,
    ?string $postalCode,
    string $deliveryMethod,
    array $productCodes,
  ): ShippingRequest {
    $normalizedOrderNumber =
      $orderNumber
      |> trim(...)
      |> strtoupper(...);

    $normalizedRecipientName = trim($recipientName);

    $normalizedPostalCode = match ($postalCode) {
      null => null,
      default => preg_replace('/\D/', '', $postalCode),
    };

    $normalizedProductCodes = array_map(
      static fn (string $productCode): string =>
        $productCode
        |> trim(...)
        |> strtoupper(...),
      $productCodes,
    );

    $method = DeliveryMethod::tryFrom(
      strtolower(trim($deliveryMethod)),
    );

    if ($method === null) {
      throw new InvalidArgumentException(
        "Unsupported delivery method: {$deliveryMethod}",
      );
    }

    return new ShippingRequest(
      orderNumber: $normalizedOrderNumber,
      recipientName: $normalizedRecipientName,
      postalCode: $normalizedPostalCode,
      deliveryMethod: $method,
      productCodes: $normalizedProductCodes,
    );
  }
}
