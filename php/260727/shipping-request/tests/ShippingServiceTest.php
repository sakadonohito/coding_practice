<?php

declare(strict_types=1);

namespace Tests;

use App\DeliveryMethod;
use App\DeliveryStatus;
use App\ShippingRequest;
use App\ShippingRequestFactory;
use App\ShippingService;
use DomainException;
use InvalidArgumentException;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

final class ShippingServiceTest extends TestCase
{
    #[Test]
    public function 正常な配送依頼を確定できる(): void
    {
        /*
         * 要件:
         * 注文番号:
         * " order-001 "
         * 配送先氏名:
         * " 山田 太郎 "
         * 郵便番号:
         * "100-0001"
         * 配送方法:
         * "express"
         * 商品コード:
         * [" item-001 ", "item-002"]
         * ShippingRequestFactory::create()で生成する。
         * ShippingService::confirm()を実行する。
         * 確定後の値が次のとおりであることを確認する。
         * orderNumber:
         * "ORDER-001"
         * recipientName:
         * "山田 太郎"
         * postalCode:
         * "1000001"
         * status:
         * DeliveryStatus::Confirmed
         */
      $request = ShippingRequestFactory::create(
        orderNumber: " order-001 ",
        recipientName: " 山田 太郎 ",
        postalCode: "100-0001",
        deliveryMethod: "express",
        productCodes: [" item-001 ", "item-002"]
      );
      $service = new ShippingService();
      $confirmed = $service->confirm($request);
      $expected = new ShippingRequest(
        orderNumber: 'ORDER-001',
        recipientName: '山田 太郎',
        postalCode: '1000001',
        deliveryMethod: DeliveryMethod::Express,
        productCodes: ['ITEM-001', 'ITEM-002'],
        status: DeliveryStatus::Confirmed, // 期待するステータス
      );
      self::assertSame(
        DeliveryStatus::Confirmed,
        $confirmed->status,
      );
      self::assertEquals($expected, $confirmed);
    }

    #[Test]
    public function 確定しても元の依頼は変更されない(): void
    {
        /*
         * 要件:
         * Pending状態のShippingRequestを作成する。
         * confirm()の戻り値はConfirmedになる。
         * 元のShippingRequestはPendingのままである。
         * 元と戻り値が別インスタンスであることも確認する。
         * assertNotSame()を使用する。
         */
      $request = ShippingRequestFactory::create(
        orderNumber: " order-001 ",
        recipientName: " 山田 太郎 ",
        postalCode: "100-0001",
        deliveryMethod: "express",
        productCodes: [" item-001 ", "item-002"]
      );
      $service = new ShippingService();
      $confirmed = $service->confirm($request);
      $expected = new ShippingRequest(
        orderNumber: 'ORDER-001',
        recipientName: '山田 太郎',
        postalCode: '1000001',
        deliveryMethod: DeliveryMethod::Express,
        productCodes: ['ITEM-001', 'ITEM-002'],
        status: DeliveryStatus::Confirmed, // 期待するステータス
      );
      self::assertSame(
        DeliveryStatus::Confirmed,
        $confirmed->status,
      );
      self::assertEquals($expected, $confirmed);
      self::assertSame(DeliveryStatus::Pending, $request->status);
      self::assertNotSame($request, $confirmed);
    }

    #[Test]
    public function 通常配送で郵便番号が7桁でなければ失敗する(): void
    {
        /*
         * 要件:
         * 配送方法:
         * DeliveryMethod::Standard
         * 郵便番号:
         * "123"
         * ShippingService::confirm()で
         * DomainExceptionが発生することを確認する。
         * メッセージ:
         * "Postal code must contain exactly 7 digits"
         */
      $request = ShippingRequestFactory::create(
        orderNumber: " order-001 ",
        recipientName: " 山田 太郎 ",
        postalCode: "123",
        deliveryMethod: "standard",
        productCodes: [" item-001 ", "item-002"]
      );
      $this->expectException(DomainException::class);
      $this->expectExceptionMessage(
        "Postal code must contain exactly 7 digits"
      );

      $service = new ShippingService();
      $confirmed = $service->confirm($request);
    }

    #[Test]
    public function 店舗受取では郵便番号なしでも確定できる(): void
    {
        /*
         * 要件:
         * 配送方法:
         * DeliveryMethod::Pickup
         * 郵便番号:
         * null
         * confirm()が成功することを確認する。
         * 結果のstatusが
         * DeliveryStatus::Confirmedであることを確認する。
         */
      $request = ShippingRequestFactory::create(
        orderNumber: " order-001 ",
        recipientName: " 山田 太郎 ",
        postalCode: null,
        deliveryMethod: "pickup",
        productCodes: [" item-001 ", "item-002"]
      );
      $service = new ShippingService();
      $confirmed = $service->confirm($request);
      $expected = new ShippingRequest(
        orderNumber: 'ORDER-001',
        recipientName: '山田 太郎',
        postalCode: null,
        deliveryMethod: DeliveryMethod::Pickup,
        productCodes: ['ITEM-001', 'ITEM-002'],
        status: DeliveryStatus::Confirmed, // 期待するステータス
      );
      self::assertSame(
        DeliveryStatus::Confirmed,
        $confirmed->status,
      );
      self::assertEquals($expected, $confirmed);
    }

    #[Test]
    public function 未定義の配送方法は生成時に拒否される(): void
    {
        /*
         * 要件:
         * deliveryMethodに"drone"を指定する。
         * ShippingRequestFactory::create()で
         * InvalidArgumentExceptionが発生することを確認する。
         * メッセージ:
         * "Unsupported delivery method: drone"
         */
      $this->expectException(InvalidArgumentException::class);
      $this->expectExceptionMessage(
        "Unsupported delivery method: drone"
      );

      $request = ShippingRequestFactory::create(
        orderNumber: " order-001 ",
        recipientName: " 山田 太郎 ",
        postalCode: "100-0001",
        deliveryMethod: "drone",
        productCodes: [" item-001 ", "item-002"]
      );
      //$service = new ShippingService();
      //$confirmed = $service->confirm($request);
    }

    #[Test]
    public function 最初と最後の商品コードを取得できる(): void
    {
        /*
         * 要件:
         * 商品コード:
         * ["ITEM-001", "ITEM-002", "ITEM-003"]
         * firstProductCode()が"ITEM-001"を返す。
         * lastProductCode()が"ITEM-003"を返す。
         */
      $request = ShippingRequestFactory::create(
        orderNumber: " order-001 ",
        recipientName: " 山田 太郎 ",
        postalCode: "100-0001",
        deliveryMethod: "express",
        productCodes: [" item-001 ", "item-002", "item-003"]
      );
      $service = new ShippingService();
      $confirmed = $service->confirm($request);
      $expected = new ShippingRequest(
        orderNumber: 'ORDER-001',
        recipientName: '山田 太郎',
        postalCode: '1000001',
        deliveryMethod: DeliveryMethod::Express,
        productCodes: ['ITEM-001', 'ITEM-002', 'ITEM-003'],
        status: DeliveryStatus::Confirmed, // 期待するステータス
      );
      self::assertEquals($expected, $confirmed);
      self::assertSame(
        "ITEM-001",
        $confirmed->firstProductCode(),
      );
      self::assertSame(
        "ITEM-003",
        $confirmed->lastProductCode(),
      );
    }

    #[Test]
    #[DataProvider('invalidRequestProvider')]
    public function 不正な配送依頼を拒否する(
        ShippingRequest $request,
        string $expectedMessage,
    ): void {
        /*
         * 要件:
         * DataProviderから配送依頼と期待メッセージを受け取る。
         * ShippingService::confirm()を実行する。
         * DomainExceptionが発生することを確認する。
         * 例外メッセージがexpectedMessageと一致することを確認する。
         */
      $this->expectException(DomainException::class);
      $this->expectExceptionMessage($expectedMessage);

      $service = new ShippingService();
      /*
       *  例外発生を期待するテストなので、実行するだけ。
       *  なので(void)をつけて戻り値使わない宣言をする。
       */
      (void) $service->confirm($request);
    }

    public static function invalidRequestProvider(): iterable
    {
        yield '注文番号が空' => [
            new ShippingRequest(
                orderNumber: '',
                recipientName: '山田 太郎',
                postalCode: '1000001',
                deliveryMethod: DeliveryMethod::Standard,
                productCodes: ['ITEM-001'],
            ),
            'Order number must not be blank',
        ];

        yield '配送先氏名が空' => [
            new ShippingRequest(
                orderNumber: 'ORDER-001',
                recipientName: '',
                postalCode: '1000001',
                deliveryMethod: DeliveryMethod::Standard,
                productCodes: ['ITEM-001'],
            ),
            'Recipient name must not be blank',
        ];

        yield '商品が0件' => [
            new ShippingRequest(
                orderNumber: 'ORDER-001',
                recipientName: '山田 太郎',
                postalCode: '1000001',
                deliveryMethod: DeliveryMethod::Standard,
                productCodes: [],
            ),
            'At least one product code is required',
        ];
    }
}
