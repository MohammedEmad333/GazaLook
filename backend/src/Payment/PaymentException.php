<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Payment;

/** Thrown for invalid top-up input or a failed gateway call (HTTP 422). */
final class PaymentException extends \RuntimeException
{
}
