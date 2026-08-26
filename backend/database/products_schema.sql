-- =============================================================================
-- GazaLook — Products catalogue
-- =============================================================================
-- Real data source for the catalog, replacing the in-app demo list. Column
-- names map to the Flutter `ProductModel` fields (see ProductRepository::toApi).
-- Seeded with the same 12 products the app shipped with, so switching the app
-- to the API changes nothing the shopper sees.
-- Engine: MySQL 8 / MariaDB 10.4+.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS products (
  id           VARCHAR(40)     NOT NULL,          -- app-facing id, e.g. 'p1'
  name         VARCHAR(200)    NOT NULL,
  price        DECIMAL(10,2)   NOT NULL,
  old_price    DECIMAL(10,2)   NULL,              -- set => on offer
  image_url    VARCHAR(1024)   NOT NULL,
  category     VARCHAR(40)     NOT NULL,          -- women|men|kids|accessories
  description  TEXT            NULL,
  images       JSON            NULL,              -- extra gallery images (list)
  sizes        JSON            NULL,              -- e.g. ["S","M","L"]
  rating       DECIMAL(3,2)    NOT NULL DEFAULT 0,
  rating_count INT             NOT NULL DEFAULT 0,
  is_local     TINYINT(1)      NOT NULL DEFAULT 0,
  in_stock     TINYINT(1)      NOT NULL DEFAULT 1,
  store_name   VARCHAR(200)    NULL,
  sort_order   INT             NOT NULL DEFAULT 0,
  created_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_products_category (category),
  KEY idx_products_sort (sort_order)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Seed: the launch catalog (imagery from the approved design mock-ups).
-- -----------------------------------------------------------------------------
INSERT INTO products
  (id, name, price, old_price, category, description, sizes, rating, rating_count,
   is_local, in_stock, store_name, sort_order, image_url)
VALUES
  ('p1', 'فستان صيفي حريري', 120, NULL, 'women',
   'فستان صيفي انسيابي من الحرير بألوان دافئة، مثالي للإطلالات النهارية.',
   '["S","M","L","XL"]', 4.8, 124, 1, 1, 'متجر خيوط، مدينة غزة', 1,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuCY97bZpTGs7HxBwOvhwOWHH6cFtAP1lRIPm2KAZf4upTol9It-8lCUpU21treg5Sj03yf99MQ0g_0F6Q5ewzIZwKRAM_lEpNMKv1ZjM1ipqcLuL-TBAAwNktXX0_2SrzJv36aUBANcJ0H8SWDPNQOkNR-yrFIrM0k2_Ov-W3bBeuCi4-156wj71vE2kOWe7aEIQznSrzuwBjpRmWkashMnVtfNAlb1qdBDnrjlIUEixRmJ_laSxMmG'),
  ('p2', 'حقيبة جلد كلاسيكية', 250, NULL, 'accessories',
   'حقيبة يد من الجلد الطبيعي بتصميم كلاسيكي أنيق ومساحة واسعة.',
   '[]', 4.6, 88, 0, 1, NULL, 2,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuBcjHtacD2VxZcUjv76ky7as1W6aWJ7_TCgtfTWA6CrwgP7YDftu0ihK1aKpFOyWFbJGAwqEtpy5dJeLZEs6G5fC7kN6bgD56UdPkcmpeWzjCvQxzRSpDEMbuvb37N52Go_vlnaF7gPNDh9GtoLKZqZ7_l7QneL8wAZ7M4_LTPcG5DN-4QAW-35QEY20nWOEEkmVuNvLYlTkFseSP5Rr4ny-Wp59enoIBZtkypoW0Ag9Gi_Ey8Jk50G'),
  ('p3', 'قميص كتان خفيف', 95, 130, 'men',
   'قميص كتان خفيف ومريح مناسب لأجواء الصيف، بقصة عصرية.',
   '["M","L","XL"]', 4.4, 61, 0, 1, NULL, 3,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuDV9g4PrdXvWeZkgMdk1HKvUIMLtGyKBVF8tfGLrLr0-n7H29651ByzDTausHJ1g1bUO94PuTq0Oy903giH-yI1rMbUeieu9N8t0H9M90UE9A16nJ5lNO_vptPYocOyCzMzd0pGvtXfqQNgei_Tq9pSaTU8Uh-0j5AEA6k8SONKvV07xbkmQaIst1nMTQB15XfoQkNHSiQY5FzyN3w1lFuHCFR4pT2vG7FKxkacnUfhag3_Nub31ZXS'),
  ('p4', 'أقراط سيراميك يدوية', 45, NULL, 'accessories',
   'أقراط سيراميك مصنوعة يدوياً بألوان باستيلية هادئة.',
   '[]', 4.9, 203, 1, 1, NULL, 4,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuBwIvwOJ2bD9ms-VyX6TR42A2POTUgQTNGAUNZoekEgugxpLy9iuPEZZXgvhtgS79Op14Es__1tA556p8why9MwTJyufY28wcP7HIeEx5g9x8ohRuG4STfoCJPAV_7zX4asv898giPdOImoCydmki8dAkyjJ_DBClfUtGD3Jt4vYwZFphxqVc_NXIfna1FnC98676lMEqL8hvfOtrGldPRDrUyNHMW1PgmQAmf9EZVq0xqsEmE1N-V0'),
  ('p5', 'فستان تطريز عصري - يافا', 350, NULL, 'women',
   'فستان يافا يجمع بين الأصالة والحداثة، كتان مريح مع تطريز يدوي متقن.',
   '["S","M","L","XL"]', 5.0, 47, 1, 1, 'متجر خيوط، مدينة غزة', 5,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuAJWsVwQfc9o3QwNgs9_NXZPm72jeONNHA2-ZL45-_7GeByomKXNy7zproG5G2B-rN6JNeXQeFmX1d2dnWD7ewqkbh0n01Zf4PYuBEzXmFp91M0XObm_XKoko1nU4I7Ky4PcLPzAu9iK-yYnX2hLYJeEhHaul1eYGqoxlcu7CF1uXXwGjaNDyyUPApq48kFG-Uul4bfaELfS6IIolteTBBrQker9QEiWxM9QJfkg3m8WGNAHA1lzBMB'),
  ('p6', 'ثوب مطرز كلاسيكي', 250, NULL, 'women',
   'ثوب فلسطيني مطرز بغرزة الصليب التقليدية بألوان حمراء وسوداء.',
   '["M","L","XL"]', 4.7, 156, 1, 1, NULL, 6,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuCTFtVz69h2t8iamgbYyxX8B-bbmiq5yMw_CkMUVyF_oXfirA_kuvi-cV0bTm-VxcFLjc0_PshsYLcrSIB831UuL2WOjcbii77TSbyrj17FSX0lp5-InnXLeLJJTK3NNNExgjbIVgD2m_P2cXh-1cD_3h2PFClyJvv_dzYMAdidIUR28Db3GjHmcQpr0SRVgFt96sOYiEyzbpwui7Zhli9LYeI6ImtQOQO6xJbBWTDeu9d-gURWMsjV'),
  ('p7', 'حقيبة قماشية بتطريز حديث', 120, 160, 'accessories',
   'حقيبة يد قماشية بيج مع تطريز فلسطيني عصري وردي وبني.',
   '[]', 4.5, 72, 1, 1, NULL, 7,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuDVd67T6-UpWupmv9Vf-sXtTl_tGxhGvhSrubqAQCPKW1o-FWS5_B90byko9RwmI9LB-3t-xKSFsDhnBtbcJMQHoLCSXzKBO9XhU6Gpt4xx-wbtxxsYaHfcwGUROsoswBVCrJ64EFv8qCXy_VT-P2HZeEMrY-H8PyH-o4XIlPS1oTpZdtbqMbQQH6keMeUPayebb1qWgxOCNX_oxH-M37ajI-OUQJVjWmnQudZd2zStwamT_R0ySdKe'),
  ('p8', 'بلوزة حرير وردية', 140, NULL, 'women',
   'بلوزة حرير ناعمة بلون وردي باستيلي بقصة أنيقة ومريحة.',
   '["S","M","L"]', 4.3, 39, 0, 1, NULL, 8,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuCt4YXtXixrL2joNCvGdju19WPt4iKc3XGRVtiRD62qgVQmZYmtsP5w1NjbyxYrYfZVYocJZc1mPhjzYyXmKKHhDwnU06m5YVXwbF0mA9WXXx3I1FI21AUaxmJov-tVgLFS-B8EemehKiBZjWqpRP2o9-npEn913aZrhY_AdpOT5JswYBE4-OTWMJmqUB-w4sN1uGcJX_vQNzbCwDZPT5sUP8iUKe4WCuZTCHVN-a1uDOeBTlB5uFGv'),
  ('p9', 'قميص كتان بيج للرجال', 110, NULL, 'men',
   'قميص كتان بلون بيج فاتح بملمس ناعم وإطلالة كلاسيكية.',
   '["M","L","XL"]', 4.2, 28, 0, 1, NULL, 9,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuD-sfwgEBMuXdl55-ziy-vWAueIFyBU0BeZwQo4LTr00CiRkcHCaRDhJlnB1Wm93DK1IeDfj73_d6za-8htIBmVns5Q01pTY7HgMfN_g8MlWF0wredZqMosWrs_288AuSjJtxnOGnFVG0Ay_EtbFz_sONQni2VonzjXDFa-zFlLTPunKoh6iGkLZCIVFdTRgZZiesbHNq70yOfK7XqChi2hFB3fmnfrsJ0g0Bf1baPHk3Q1B4YFACq5'),
  ('p10', 'كنزة أطفال صوفية', 75, 95, 'kids',
   'كنزة صوفية دافئة للأطفال بلون أصفر ناعم وملمس مريح.',
   '["2-3Y","4-5Y","6-7Y"]', 4.8, 54, 0, 1, NULL, 10,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuB0K1w0lONBZGzqFBjKfQmYqvO0EtvhYNmDPi5y1TORFwNBxvEzdU02pfl44sweyA_FhNgQR7QomNiUEoZy15a3K7BeJyt5QAptexvZX_NpI2pebmmZPx3JhK6rKYS6P1dDIf9I7Gf9gn-tMMQ0gLORee-sG4KHUxFU1HQMuDMbrEnC0F3CLku8ddRPicydDbO1QBY1Rv1G8WM0P_-XZ51CwFJBw4rMERPh0CslepQU3wyjWJU955Xz'),
  ('p11', 'قلادة ذهبية بسيطة', 60, NULL, 'accessories',
   'قلادة ذهبية بتصميم مينيمال أنيق يناسب كل الإطلالات.',
   '[]', 4.6, 91, 0, 1, NULL, 11,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuBbqA-QhwczwyPyByCa3ap-UkZs4O0lK_osAFBFX1WqA0KSmiQ39WgakzexF2DBMdTfTmd-UBcsflLogoRGwld-38DPkyyQsj6n5ETueU2M-dC856OS2FowRulut5MTNtAUcvWIKS2IO1ymKyKsPPRcNkndf5V5icH7X328TRRUm1hwJ7vZOlFNoS-9bmwfUVk1Shi9s2D7IDHtsdZtVGGIOJfyAngH2iFVVCA3XOIRIenejBeE3YLm'),
  ('p12', 'فستان أطفال قطني', 85, NULL, 'kids',
   'فستان قطني ناعم للأطفال بألوان زاهية مريح للحركة واللعب.',
   '["2-3Y","4-5Y"]', 4.5, 33, 0, 0, NULL, 12,
   'https://lh3.googleusercontent.com/aida-public/AB6AXuCt4YXtXixrL2joNCvGdju19WPt4iKc3XGRVtiRD62qgVQmZYmtsP5w1NjbyxYrYfZVYocJZc1mPhjzYyXmKKHhDwnU06m5YVXwbF0mA9WXXx3I1FI21AUaxmJov-tVgLFS-B8EemehKiBZjWqpRP2o9-npEn913aZrhY_AdpOT5JswYBE4-OTWMJmqUB-w4sN1uGcJX_vQNzbCwDZPT5sUP8iUKe4WCuZTCHVN-a1uDOeBTlB5uFGv')
ON DUPLICATE KEY UPDATE name = VALUES(name), price = VALUES(price);
