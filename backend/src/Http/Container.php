<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Http;

use GazaLook\Wallet\Database\Connection;
use GazaLook\Wallet\Payment\PaymentService;
use GazaLook\Wallet\Payment\Strategies\BankOfPalestineStrategy;
use GazaLook\Wallet\Payment\Strategies\JawwalPayStrategy;
use GazaLook\Wallet\Payment\Strategies\ManualReceiptUploadStrategy;
use GazaLook\Wallet\Repository\ChannelRepository;
use GazaLook\Wallet\Repository\TransactionRepository;
use GazaLook\Wallet\Repository\WalletRepository;
use GazaLook\Wallet\Wallet\WalletService;
use PDO;

/**
 * Tiny hand-rolled composition root. Builds the object graph once and wires the
 * strategies into the {@see PaymentService}. Swap this for a real DI container
 * if the backend grows.
 */
final class Container
{
    private PDO $db;
    private ChannelRepository $channels;
    private TransactionRepository $transactions;
    private WalletRepository $wallets;
    private WalletService $walletService;
    private PaymentService $paymentService;

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? Connection::get();
        $this->channels = new ChannelRepository($this->db);
        $this->transactions = new TransactionRepository($this->db);
        $this->wallets = new WalletRepository($this->db);
        $this->walletService = new WalletService($this->db, $this->transactions, $this->wallets);

        $this->paymentService = new PaymentService($this->channels);
        // Phase 1: manual receipt review handles every channel today.
        $this->paymentService->register(
            new ManualReceiptUploadStrategy($this->transactions, $this->wallets)
        );
        // Phase 2: register the gateway strategies (skeletons until credentials
        // exist). Flip a channel's `mode` to `gateway` to route through these.
        $this->paymentService->register(
            new JawwalPayStrategy($this->transactions, $this->wallets, $this->walletService)
        );
        $this->paymentService->register(
            new BankOfPalestineStrategy($this->transactions, $this->wallets, $this->walletService)
        );
    }

    public function walletController(): WalletController
    {
        return new WalletController(
            $this->paymentService,
            $this->walletService,
            $this->channels,
            $this->transactions,
        );
    }

    public function adminController(): AdminController
    {
        return new AdminController($this->walletService, $this->transactions);
    }
}
