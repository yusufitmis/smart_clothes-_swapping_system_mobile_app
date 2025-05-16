# 👕 Akıllı Kıyafet Takas Sistemi | Smart Clothing Swap System

Sürdürülebilir moda ve dijital gardırop yönetimini bir araya getiren yenilikçi bir platform.  
An innovative platform that merges sustainable fashion with digital wardrobe management.

---

## 🧩 Özellikler | Features

### 🔐 Kullanıcı Kayıt & Giriş | User Registration & Login
- E-posta ve şifre ile güvenli kayıt.
- Oturum açma, şifre sıfırlama ve oturum yönetimi.

### 👚 Kıyafet Ekleme | Add Clothing
- Cihazdan görsel yükleme veya URL ile kıyafet ekleme.
- Yapay zekâ destekli **arka plan silme** (background removal).

### ❤️ Favorilere Ekleme | Add to Favorites
- Beğendiğiniz kıyafetleri favorilere ekleyin.
- Favori listenize kolay erişim.

### 👗 Kombin Oluşturma | Outfit Creation
- Kendi kıyafetlerinizle kombinler oluşturun.
- Kombinleri düzenleyin veya silin.

### 👥 Sosyal Özellikler | Social Features
- Kullanıcılar arasında arkadaşlık ekleyin.
- Gerçek zamanlı mesajlaşma desteği.

### 🔁 Kıyafet Takası | Clothing Swap
- Takas yapmak istediğiniz kıyafetleri seçin.
- Kullanıcılar arası kıyafet takası teklifleri oluşturun ve onaylayın.

### 🧍‍♀️ 3D Kıyafet Görselleştirme | 3D Garment Visualization
- Kıyafetleri 3D avatar üzerinde deneyimleyin.
- Beden, pozisyon ve kombin seçeneklerini simüle edin.

---

## ⚙️ Teknolojiler | Technologies Used

- **Frontend**: React.js / Flutter
- **Backend**: Node.js / Django / Firebase
- **Database**: PostgreSQL / Firebase Firestore
- **AI & Image Processing**: Python, OpenCV, RemBG, TensorFlow
- **3D Modelleme**: Three.js, Unity WebGL, Babylon.js

---

## 🛠 Kurulum Talimatları | Installation Instructions

```bash
# Projeyi klonla
git clone https://github.com/kullanici/akilli-kiyafet-takas.git
cd akilli-kiyafet-takas

# Bağımlılıkları yükle
npm install

# Uygulamayı başlat
npm start

## 📦 API Uç Noktaları | API Endpoints

| Metod | Endpoint | Açıklama / Description |
|-------|----------|-------------------------|
| POST  | `/api/register`           | Kullanıcı kaydı / User registration |
| POST  | `/api/login`              | Kullanıcı girişi / User login |
| POST  | `/api/clothes`            | Kıyafet ekleme / Add clothing |
| POST  | `/api/clothes/from-url`   | URL ile kıyafet ekleme / Add clothing via URL |
| POST  | `/api/clothes/remove-bg`  | Arka plan silme / Remove clothing background |
| POST  | `/api/favorites/:id`      | Favorilere ekle / Add to favorites |
| POST  | `/api/outfits`            | Kombin oluştur / Create outfit |
| PUT   | `/api/outfits/:id`        | Kombin güncelle / Update outfit |
| DELETE| `/api/outfits/:id`        | Kombin sil / Delete outfit |
| POST  | `/api/friends`            | Arkadaş ekle / Add friend |
| POST  | `/api/messages`           | Mesaj gönder / Send message |
| POST  | `/api/trades`             | Takas başlat / Start trade |
| GET   | `/api/3d-view/:id`        | 3D görüntüle / View in 3D |


## 👨‍💻 Ekip | Team

Bu proje, aşağıdaki ekip üyeleri tarafından geliştirilmiştir:

| İsim | E-posta |
|------|---------|
| **Burak Onur** | bonur167@gmail.com |
| **Abdulsamet Gülsüm** | abdulgulme@gmail.com |
| **Utku Ayyıldız** | utkuayyildiz@gmail.com |

## 📬 İletişim | Contact

Proje hakkında görüş, öneri veya destek talepleri için lütfen ekip üyeleriyle iletişime geçin:

- **Burak Onur** – bonur167@gmail.com  
- **Abdulsamet Gülsüm** – abdulgulme@gmail.com  
- **Utku Ayyıldız** – utkuayyildiz@gmail.com
