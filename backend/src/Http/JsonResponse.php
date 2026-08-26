<?php

declare(strict_types=1);

namespace GazaLook\Wallet\Http;

/** Immutable HTTP response: a status code + a JSON-serialisable body. */
final class JsonResponse
{
    /** @param array<string,mixed>|list<mixed> $body */
    public function __construct(
        public readonly int $status,
        public readonly array $body,
    ) {
    }

    /** @param array<string,mixed>|list<mixed> $data */
    public static function ok(array $data): self
    {
        return new self(200, ['ok' => true, 'data' => $data]);
    }

    public static function error(int $status, string $message): self
    {
        return new self($status, ['ok' => false, 'error' => $message]);
    }

    public function send(): void
    {
        http_response_code($this->status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($this->body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }
}
