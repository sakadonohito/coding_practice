<?php
declare(strict_types=1);
namespace App;
use DomainException;

final class ShippingService
{
  #[\NoDiscard(
    message: '確定済みの配送依頼を受け取ってください',
  )]
  public function confirm(
    ShippingRequest $request,
  ): ShippingRequest {
    $this->validate($request);

    return $request->confirmed();
  }

  private function validate(
    ShippingRequest $request,
  ): void {
    if ($request->orderNumber === '') {
      throw new DomainException(
        'Order number must not be blank',
      );
    }

    if ($request->recipientName === ''){
      throw new DomainException(
        'Recipient name must not be blank',
      );
    }

    if ($request->productCodes === []) {
      throw new DomainException(
        'At least one product code is required',
      );
    }

    if (
      $request->deliveryMethod->requiresPostalCode()
      && !preg_match('/^\d{7}$/', $request->postalCode ?? '')
    ) {
        throw new DomainException(
          'Postal code must contain exactly 7 digits',
        );
    }

    foreach ($request->productCodes as $productCode) {
      if ($productCode === '') {
        throw new DomainException(
          'Product code must not be blank',
        );
      }
    }
  }
}
