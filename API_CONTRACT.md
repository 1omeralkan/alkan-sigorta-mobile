# API CONTRACT

Bu doküman, Flutter mobil uygulaması ile backend Spring Boot mikroservisleri arasındaki API sözleşmesini tanımlar.

---

## 1. APPLICATION MICROSERVICE
**Base URL:** `http://localhost:8081/api/v1/applications`

### 1.1. Başvuru Oluştur
- **Method:** `POST`
- **Endpoint:** `/`
- **Request Body:**
```json
{
  "customerId": 1,
  "productId": 2,
  "description": "Sağlık sigortası başvurusu",
  "paymentTypeCode": "CREDIT_CARD",
  "installmentCount": 12,
  "requestedCoverageCodes": ["ACCIDENT", "HEALTH"],
  "age": 35,
  "height": 175,
  "weight": 78.5,
  "gender": "M"
}
```
- **Response (201 CREATED):**
```json
{
  "id": 100,
  "applicationNumber": "APP-2026-001",
  "customerId": 1,
  "customerName": "Ahmet Yılmaz",
  "productId": 2,
  "productName": "Sağlık Sigortası Premium",
  "productAmountId": 45,
  "amount": 5000.00,
  "applicationDate": "2026-05-14",
  "status": "PENDING",
  "description": "Sağlık sigortası başvurusu",
  "isActive": true,
  "paymentTypeCode": "CREDIT_CARD",
  "paymentTypeName": "Kredi Kartı",
  "installmentCount": 12,
  "installmentAmount": 416.67
}
```

### 1.2. Başvuru Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/{id}`
- **Response (200 OK):** ApplicationResponseDto

### 1.3. Başvuru Getir (Başvuru Numarası ile)
- **Method:** `GET`
- **Endpoint:** `/number/{applicationNumber}`
- **Response (200 OK):** ApplicationResponseDto

### 1.4. Tüm Başvuruları Listele
- **Method:** `GET`
- **Endpoint:** `/`
- **Response (200 OK):** `List<ApplicationResponseDto>`

### 1.5. Müşteri Başvurularını Listele
- **Method:** `GET`
- **Endpoint:** `/customer/{customerId}`
- **Response (200 OK):** `List<ApplicationResponseDto>`

### 1.6. Başvuru Durumu Güncelle
- **Method:** `PATCH`
- **Endpoint:** `/{id}/status?status={status}`
- **Query Param:** `status` (String) - örn: "APPROVED", "REJECTED"
- **Response (200 OK):** ApplicationResponseDto

### 1.7. Başvuru Sil
- **Method:** `DELETE`
- **Endpoint:** `/{id}`
- **Response (204 NO CONTENT)**

---

## 2. COLLECTION MICROSERVICE
**Base URL:** `http://localhost:8082/api/v1/collections`

### 2.1. Başvuruya Ait Taksit Planı Oluştur
- **Method:** `POST`
- **Endpoint:** `/application/{applicationId}`
- **Response (201 CREATED):**
```json
[
  {
    "id": 1,
    "applicationId": 100,
    "policyId": null,
    "installmentNumber": 1,
    "installmentAmount": 416.67,
    "dueDate": "2026-06-14",
    "isActive": true,
    "isPaid": false
  },
  {
    "id": 2,
    "applicationId": 100,
    "policyId": null,
    "installmentNumber": 2,
    "installmentAmount": 416.67,
    "dueDate": "2026-07-14",
    "isActive": true,
    "isPaid": false
  }
]
```

### 2.2. Tüm Tahsilatları Listele
- **Method:** `GET`
- **Endpoint:** `/`
- **Response (200 OK):** `List<CollectionResponseDto>`

### 2.3. Tahsilat Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/{id}`
- **Response (200 OK):** CollectionResponseDto

### 2.4. Başvuruya Ait Tahsilatları Listele
- **Method:** `GET`
- **Endpoint:** `/application/{applicationId}`
- **Response (200 OK):** `List<CollectionResponseDto>`

### 2.5. Taksit Ödeme Yap
- **Method:** `PATCH`
- **Endpoint:** `/{id}/pay`
- **Request Body:**
```json
{
  "cardNumber": "4111111111111111",
  "cardHolderName": "AHMET YILMAZ",
  "expireMonth": "12",
  "expireYear": "26",
  "cvv": "123",
  "amount": 416.67
}
```
- **Response (200 OK):** CollectionResponseDto

### 2.6. Tahsilat Sil
- **Method:** `DELETE`
- **Endpoint:** `/{id}`
- **Response (204 NO CONTENT)**

---

## 3. CUSTOMER MICROSERVICE
**Base URL:** `http://localhost:8083/api/v1/customers`

### 3.1. Müşteri Kaydet
- **Method:** `POST`
- **Endpoint:** `/`
- **Request Body:**
```json
{
  "ad": "Ahmet",
  "soyad": "Yılmaz",
  "tcNo": "12345678901",
  "email": "ahmet.yilmaz@example.com",
  "dogumTarihi": "1990-05-15",
  "dogumYeri": "İstanbul",
  "addressCountryId": 1,
  "addressCityId": 34,
  "openAddress": "Kadıköy Mahallesi, Örnek Sokak No:5 Daire:10",
  "phoneCountryId": 1,
  "phoneNumber": "5551234567"
}
```
- **Validasyonlar:**
  - `ad`: 2-50 karakter, zorunlu
  - `soyad`: 2-50 karakter, zorunlu
  - `tcNo`: Tam 11 haneli, @ValidTcNo ile doğrulama, zorunlu
  - `email`: Geçerli email formatı, max 100 karakter, zorunlu
  - `dogumTarihi`: Geçmişte bir tarih olmalı, zorunlu
  - `dogumYeri`: 2-50 karakter
  - `openAddress`: Max 250 karakter
  - `phoneNumber`: 5 ile başlamalı, 10 haneli (regex: `^(5)\\d{9}$`)

- **Response (201 CREATED):**
```json
{
  "id": 1,
  "ad": "Ahmet",
  "soyad": "Yılmaz",
  "email": "ahmet.yilmaz@example.com",
  "tcNo": "12345678901",
  "addressCountryId": 1,
  "addressCountryName": "Türkiye",
  "addressCityId": 34,
  "addressCityName": "İstanbul",
  "openAddress": "Kadıköy Mahallesi, Örnek Sokak No:5 Daire:10",
  "phoneCountryId": 1,
  "phoneCode": "+90",
  "phoneNumber": "5551234567"
}
```

### 3.2. Müşteri Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/{id}`
- **Response (200 OK):** CustomerResponse

### 3.3. Tüm Müşterileri Listele
- **Method:** `GET`
- **Endpoint:** `/`
- **Response (200 OK):** `List<CustomerResponse>`

### 3.4. Müşteri Güncelle
- **Method:** `PUT`
- **Endpoint:** `/{id}`
- **Request Body:** CustomerSaveRequest (aynı yapı)
- **Response (200 OK):** CustomerResponse

### 3.5. Müşteri Sil
- **Method:** `DELETE`
- **Endpoint:** `/{id}`
- **Response (204 NO CONTENT)**

---

## 4. PARAMETER MICROSERVICE
**Base URL:** `http://localhost:8084/api/v1`

### 4.1. COUNTRY ENDPOINTS

#### 4.1.1. Ülke Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/countries/{id}`
- **Response (200 OK):**
```json
{
  "id": 1,
  "name": "Türkiye",
  "isoCode": "TR",
  "phoneCode": "+90"
}
```

#### 4.1.2. Ülke Getir (ISO Code ile)
- **Method:** `GET`
- **Endpoint:** `/countries/code/{isoCode}`
- **Response (200 OK):** CountryDto

#### 4.1.3. Ülke Oluştur
- **Method:** `POST`
- **Endpoint:** `/countries`
- **Request Body:**
```json
{
  "name": "Türkiye",
  "isoCode": "TR",
  "phoneCode": "+90"
}
```
- **Validasyonlar:**
  - `name`: Zorunlu, max 100 karakter
  - `isoCode`: Zorunlu, tam 2 karakter
  - `phoneCode`: Zorunlu, max 10 karakter
- **Response (200 OK):** CountryDto

#### 4.1.4. Ülke Güncelle
- **Method:** `PUT`
- **Endpoint:** `/countries/{id}`
- **Request Body:** CountryUpdateDto (aynı yapı)
- **Response (200 OK):** CountryDto

#### 4.1.5. Ülke Sil
- **Method:** `DELETE`
- **Endpoint:** `/countries/{id}`
- **Response (204 NO CONTENT)**

### 4.2. CITY ENDPOINTS

#### 4.2.1. Şehir Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/cities/{id}`
- **Response (200 OK):**
```json
{
  "id": 34,
  "name": "İstanbul",
  "plateCode": "34",
  "countryId": 1
}
```

#### 4.2.2. Ülkeye Ait Şehirleri Listele
- **Method:** `GET`
- **Endpoint:** `/cities/country/{countryId}`
- **Response (200 OK):** `List<CityDto>`

#### 4.2.3. Şehir Getir (Plaka Kodu ile)
- **Method:** `GET`
- **Endpoint:** `/cities/plate/{plateCode}`
- **Response (200 OK):** CityDto

#### 4.2.4. Şehir Oluştur
- **Method:** `POST`
- **Endpoint:** `/cities`
- **Request Body:**
```json
{
  "name": "İstanbul",
  "plateCode": "34",
  "countryId": 1
}
```
- **Validasyonlar:**
  - `name`: Zorunlu, max 100 karakter
  - `plateCode`: Zorunlu, max 5 karakter
  - `countryId`: Zorunlu
- **Response (200 OK):** CityDto

#### 4.2.5. Şehir Güncelle
- **Method:** `PUT`
- **Endpoint:** `/cities/{id}`
- **Request Body:** CityUpdateDto (aynı yapı)
- **Response (200 OK):** CityDto

#### 4.2.6. Şehir Sil
- **Method:** `DELETE`
- **Endpoint:** `/cities/{id}`
- **Response (204 NO CONTENT)**

### 4.3. TOWN ENDPOINTS

#### 4.3.1. Şehre Ait İlçeleri Listele
- **Method:** `GET`
- **Endpoint:** `/towns/city/{cityId}`
- **Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Kadıköy",
    "cityId": 34
  },
  {
    "id": 2,
    "name": "Beşiktaş",
    "cityId": 34
  }
]
```

#### 4.3.2. İlçe Oluştur
- **Method:** `POST`
- **Endpoint:** `/towns`
- **Request Body:**
```json
{
  "name": "Kadıköy",
  "cityId": 34
}
```
- **Validasyonlar:**
  - `name`: Zorunlu, max 100 karakter
  - `cityId`: Zorunlu
- **Response (200 OK):** TownDto

#### 4.3.3. İlçe Güncelle
- **Method:** `PUT`
- **Endpoint:** `/towns/{id}`
- **Request Body:** TownUpdateDto (aynı yapı)
- **Response (200 OK):** TownDto

#### 4.3.4. İlçe Sil
- **Method:** `DELETE`
- **Endpoint:** `/towns/{id}`
- **Response (204 NO CONTENT)**

### 4.4. PAYMENT TYPE ENDPOINTS

#### 4.4.1. Tüm Aktif Ödeme Tiplerini Listele
- **Method:** `GET`
- **Endpoint:** `/payment-types`
- **Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "CREDIT_CARD",
    "name": "Kredi Kartı",
    "minInstallment": 1,
    "maxInstallment": 12,
    "isActive": true
  },
  {
    "id": 2,
    "code": "CASH",
    "name": "Nakit",
    "minInstallment": 1,
    "maxInstallment": 1,
    "isActive": true
  }
]
```

#### 4.4.2. Ödeme Tipi Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/payment-types/{id}`
- **Response (200 OK):** PaymentTypeDto

#### 4.4.3. Ödeme Tipi Getir (Code ile)
- **Method:** `GET`
- **Endpoint:** `/payment-types/code/{code}`
- **Response (200 OK):** PaymentTypeDto

#### 4.4.4. Ödeme Tipi Oluştur
- **Method:** `POST`
- **Endpoint:** `/payment-types`
- **Request Body:**
```json
{
  "code": "CREDIT_CARD",
  "name": "Kredi Kartı",
  "minInstallment": 1,
  "maxInstallment": 12
}
```
- **Response (201 CREATED):** PaymentTypeDto

#### 4.4.5. Ödeme Tipi Sil
- **Method:** `DELETE`
- **Endpoint:** `/payment-types/{id}`
- **Response (204 NO CONTENT)**

### 4.5. COVERAGE PARAMETER ENDPOINTS

#### 4.5.1. Kapsam Kodu ile Çarpan Getir
- **Method:** `GET`
- **Endpoint:** `/coverage-parameters/{code}/multiplier`
- **Response (200 OK):** `BigDecimal` (örn: `1.25`)

### 4.6. RISK PARAMETER ENDPOINTS

#### 4.6.1. Risk Parametresi Getir (Key ile)
- **Method:** `GET`
- **Endpoint:** `/risk-parameters/{key}/value`
- **Response (200 OK):** `BigDecimal` (örn: `0.15`)

#### 4.6.2. Tüm Risk Parametrelerini Getir
- **Method:** `GET`
- **Endpoint:** `/risk-parameters/all`
- **Response (200 OK):**
```json
{
  "AGE_RISK_FACTOR": 0.05,
  "BMI_RISK_FACTOR": 0.10,
  "GENDER_RISK_MALE": 1.15,
  "GENDER_RISK_FEMALE": 1.00
}
```

---

## 5. POLICY MICROSERVICE
**Base URL:** `http://localhost:8085/api/v1/policies`

### 5.1. Poliçe Oluştur
- **Method:** `POST`
- **Endpoint:** `/`
- **Request Body:**
```json
{
  "productId": 2,
  "amount": 5000.00,
  "currencyCode": "TRY",
  "startDate": "2026-06-01",
  "endDate": "2027-06-01",
  "coverages": [
    {
      "coverageCode": "ACCIDENT",
      "name": "Kaza Teminatı",
      "amount": 50000.00
    },
    {
      "coverageCode": "HEALTH",
      "name": "Sağlık Teminatı",
      "amount": 30000.00
    }
  ]
}
```
- **Validasyonlar:**
  - `productId`: Zorunlu
  - `amount`: Zorunlu, pozitif
  - `currencyCode`: Zorunlu, 3 haneli (örn: TRY)
  - `startDate`: Zorunlu, bugün veya gelecekte
  - `endDate`: Zorunlu

- **Response (201 CREATED):**
```json
{
  "id": 50,
  "productId": 2,
  "startDate": "2026-06-01",
  "endDate": "2027-06-01",
  "amount": 5000.00,
  "currencyCode": "TRY",
  "policyStatus": "ACTIVE",
  "isActive": true,
  "coverages": [
    {
      "id": 100,
      "coverageCode": "ACCIDENT",
      "name": "Kaza Teminatı",
      "amount": 50000.00
    },
    {
      "id": 101,
      "coverageCode": "HEALTH",
      "name": "Sağlık Teminatı",
      "amount": 30000.00
    }
  ]
}
```

### 5.2. Poliçe Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/{id}`
- **Response (200 OK):** PolicyResponseDto

### 5.3. Tüm Poliçeleri Listele
- **Method:** `GET`
- **Endpoint:** `/`
- **Response (200 OK):** `List<PolicyResponseDto>`

### 5.4. Poliçe Sil
- **Method:** `DELETE`
- **Endpoint:** `/{id}`
- **Response (204 NO CONTENT)**

---

## 6. PRODUCT MICROSERVICE
**Base URL:** `http://localhost:8086/api/v1`

### 6.1. CATEGORY ENDPOINTS

#### 6.1.1. Kategori Oluştur
- **Method:** `POST`
- **Endpoint:** `/categories`
- **Request Body:**
```json
{
  "name": "Sağlık Sigortaları",
  "description": "Tüm sağlık sigortası ürünleri"
}
```
- **Response (201 CREATED):**
```json
{
  "id": 1,
  "name": "Sağlık Sigortaları",
  "description": "Tüm sağlık sigortası ürünleri",
  "isActive": true
}
```

#### 6.1.2. Kategori Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/categories/{id}`
- **Response (200 OK):** CategoryResponseDto

#### 6.1.3. Tüm Kategorileri Listele
- **Method:** `GET`
- **Endpoint:** `/categories`
- **Response (200 OK):** `List<CategoryResponseDto>`

#### 6.1.4. Kategori Güncelle
- **Method:** `PUT`
- **Endpoint:** `/categories/{id}`
- **Request Body:** CategoryRequestDto
- **Response (200 OK):** CategoryResponseDto

#### 6.1.5. Kategori Sil
- **Method:** `DELETE`
- **Endpoint:** `/categories/{id}`
- **Response (204 NO CONTENT)**

### 6.2. PRODUCT ENDPOINTS

#### 6.2.1. Ürün Oluştur
- **Method:** `POST`
- **Endpoint:** `/products`
- **Request Body:**
```json
{
  "productCode": "HEALTH-PREM-001",
  "name": "Sağlık Sigortası Premium",
  "description": "Kapsamlı sağlık sigortası paketi",
  "categoryIds": [1, 3]
}
```
- **Response (201 CREATED):**
```json
{
  "id": 2,
  "productCode": "HEALTH-PREM-001",
  "name": "Sağlık Sigortası Premium",
  "description": "Kapsamlı sağlık sigortası paketi",
  "isActive": true,
  "categories": [
    {
      "id": 1,
      "name": "Sağlık Sigortaları",
      "description": "Tüm sağlık sigortası ürünleri",
      "isActive": true
    }
  ],
  "coverages": []
}
```

#### 6.2.2. Ürün Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/products/{id}`
- **Response (200 OK):** ProductResponseDto

#### 6.2.3. Tüm Ürünleri Listele
- **Method:** `GET`
- **Endpoint:** `/products`
- **Response (200 OK):** `List<ProductResponseDto>`

#### 6.2.4. Ürün Güncelle
- **Method:** `PUT`
- **Endpoint:** `/products/{id}`
- **Request Body:** ProductRequestDto
- **Response (200 OK):** ProductResponseDto

#### 6.2.5. Ürün Sil
- **Method:** `DELETE`
- **Endpoint:** `/products/{id}`
- **Response (204 NO CONTENT)**

### 6.3. PRODUCT AMOUNT ENDPOINTS

#### 6.3.1. Ürün Tutarı Oluştur
- **Method:** `POST`
- **Endpoint:** `/product-amounts`
- **Request Body:**
```json
{
  "productId": 2,
  "amount": 5000.00,
  "effectiveDate": "2026-06-01"
}
```
- **Validasyonlar:**
  - `productId`: Zorunlu
  - `amount`: Zorunlu, pozitif
  - `effectiveDate`: Zorunlu, bugün veya gelecekte

- **Response (201 CREATED):**
```json
{
  "id": 45,
  "productId": 2,
  "productName": "Sağlık Sigortası Premium",
  "amount": 5000.00,
  "effectiveDate": "2026-06-01",
  "expiryDate": null,
  "isActive": true
}
```

#### 6.3.2. Ürün Tutarı Getir (ID ile)
- **Method:** `GET`
- **Endpoint:** `/product-amounts/{id}`
- **Response (200 OK):** ProductAmountResponseDto

#### 6.3.3. Tüm Ürün Tutarlarını Listele
- **Method:** `GET`
- **Endpoint:** `/product-amounts`
- **Response (200 OK):** `List<ProductAmountResponseDto>`

#### 6.3.4. Ürüne Ait Tutarları Listele
- **Method:** `GET`
- **Endpoint:** `/product-amounts/product/{productId}`
- **Response (200 OK):** `List<ProductAmountResponseDto>`

#### 6.3.5. Ürünün Aktif Tutarını Getir
- **Method:** `GET`
- **Endpoint:** `/product-amounts/product/{productId}/active`
- **Response (200 OK):** ProductAmountResponseDto

#### 6.3.6. Ürün Tutarı Sil
- **Method:** `DELETE`
- **Endpoint:** `/product-amounts/{id}`
- **Response (204 NO CONTENT)**

### 6.4. PRODUCT COVERAGE ENDPOINTS

#### 6.4.1. Ürüne Teminat Ekle
- **Method:** `POST`
- **Endpoint:** `/product-coverages`
- **Request Body:**
```json
{
  "productId": 2,
  "coverageCode": "ACCIDENT",
  "name": "Kaza Teminatı"
}
```
- **Response (201 CREATED)**

#### 6.4.2. Ürüne Ait Teminatları Listele
- **Method:** `GET`
- **Endpoint:** `/product-coverages/product/{productId}`
- **Response (200 OK):**
```json
[
  {
    "productId": 2,
    "coverageCode": "ACCIDENT",
    "name": "Kaza Teminatı"
  },
  {
    "productId": 2,
    "coverageCode": "HEALTH",
    "name": "Sağlık Teminatı"
  }
]
```

#### 6.4.3. Teminat Güncelle
- **Method:** `PUT`
- **Endpoint:** `/product-coverages/{id}`
- **Request Body:** ProductCoverageRequestDto
- **Response (200 OK)**

#### 6.4.4. Teminat Sil
- **Method:** `DELETE`
- **Endpoint:** `/product-coverages/{id}`
- **Response (204 NO CONTENT)**

---

## GENEL NOTLAR

### HTTP Status Kodları
- **200 OK:** Başarılı GET/PUT/PATCH işlemleri
- **201 CREATED:** Başarılı POST (kayıt oluşturma) işlemleri
- **204 NO CONTENT:** Başarılı DELETE işlemleri
- **400 BAD REQUEST:** Validasyon hatası
- **404 NOT FOUND:** Kayıt bulunamadı
- **500 INTERNAL SERVER ERROR:** Sunucu hatası

### Validasyon Hata Formatı
Backend validasyon hatası döndüğünde şu format beklenir:
```json
{
  "timestamp": "2026-05-14T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "errors": {
    "email": "Lütfen geçerli bir e-posta adresi giriniz.",
    "tcNo": "TC Kimlik Numarası tam 11 haneli olmalıdır."
  }
}
```

### Tarih Formatı
- Tüm tarih alanları `ISO 8601` formatında (YYYY-MM-DD) gönderilir ve alınır.
- Örnek: `"2026-05-14"`

### Para Birimi
- Tüm tutar alanları `BigDecimal` tipindedir ve JSON'da sayısal değer olarak iletilir.
- Örnek: `5000.00`, `416.67`

### Boolean Değerler
- `true` / `false` şeklinde küçük harfle iletilir.

### Mikroservis Port Bilgileri (Lokal Ortam)
- **Application MS:** 8081
- **Collection MS:** 8082
- **Customer MS:** 8083
- **Parameter MS:** 8084
- **Policy MS:** 8085
- **Product MS:** 8086
