<?php
declare(strict_types=1);
namespace App;
use DomainException;

readonly class ShippingRequest
{
  /**
   * //@param non-empty-list<string> $productCodes
   * @param list<string> $productCodes
   */
  public function __construct(
      public string $orderNumber,
      public string $recipientName,
      public ?string $postalCode,
      public DeliveryMethod $deliveryMethod,
      public array $productCodes,
      public DeliveryStatus $status = DeliveryStatus::Pending,
  )
  {
  }

  public function firstProductCode(): ?string
  {
    return array_first($this->productCodes);
  }

  public function lastProductCode(): ?string
  {
    return array_last($this->productCodes);
  }

  public function confirmed(): self
  {
    if ($this->status !== DeliveryStatus::Pending) {
      throw new DomainException("Status must be Pending: {$this->status->name}");
    }
    return clone(
      $this,
        [
          'status' => DeliveryStatus::Confirmed,
      ],
    );
  }
}
