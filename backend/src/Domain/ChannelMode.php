<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Domain;

/**
 * How a funding channel is processed. This is the switch the Strategy Pattern
 * keys off: `Manual` → {@see \GazaLook\Wallet\Payment\Strategies\ManualReceiptUploadStrategy},
 * `Gateway` → the channel's official gateway strategy (Phase 2). Changing a
 * channel's mode is all it takes to migrate it from manual to automatic.
 */
enum ChannelMode: string
{
    case Manual = 'manual';
    case Gateway = 'gateway';
}
