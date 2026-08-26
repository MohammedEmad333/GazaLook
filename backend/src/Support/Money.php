<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Support;

/**
 * Money is stored everywhere as an integer number of the currency's smallest
 * unit (agora/piaster — 1 ILS = 100 units) so there is never any floating
 * point rounding on balances. This helper is the single place that converts
 * to/from the human-facing shekel amount.
 */
final class Money
{
    public const UNITS_PER_SHEKEL = 100;

    /** Convert a shekel amount (e.g. 25.50) to integer units (2550). */
    public static function toUnits(float $shekels): int
    {
        // round() before cast guards against 25.50 * 100 == 2549.999…
        return (int) round($shekels * self::UNITS_PER_SHEKEL);
    }

    /** Convert integer units (2550) back to a shekel amount (25.5). */
    public static function toShekels(int $units): float
    {
        return $units / self::UNITS_PER_SHEKEL;
    }

    /** Human string, e.g. "25.50 ₪". */
    public static function format(int $units): string
    {
        return number_format(self::toShekels($units), 2) . ' ₪';
    }
}
