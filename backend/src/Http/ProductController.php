<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Http;

use GazaLook\Wallet\Repository\ProductRepository;

/**
 * Read-only catalogue API consumed by the Flutter ProductRemoteDataSource.
 * Responses are already in the app's `ProductModel` JSON shape, so switching
 * the app from the demo catalog to this API needs no model changes.
 */
final class ProductController
{
    public function __construct(private readonly ProductRepository $products)
    {
    }

    /** GET /api/products */
    public function list(): JsonResponse
    {
        return JsonResponse::ok(['products' => $this->products->all()]);
    }

    /** GET /api/products/{id} */
    public function show(string $id): JsonResponse
    {
        $product = $this->products->find($id);
        if ($product === null) {
            return JsonResponse::error(404, 'المنتج غير موجود.');
        }

        return JsonResponse::ok(['product' => $product]);
    }
}
