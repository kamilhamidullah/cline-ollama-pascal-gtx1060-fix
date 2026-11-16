# Cline + Ollama + Qwen 2.5 Coder — Windows 11 / 10 Kurulum ve Sorun Giderme Rehberi
## GTX 1060 6GB (Pascal Mimarisi / Düşük VRAM) Kararlılık Çözümü

[![Lisans: MIT](https://img.shields.io/badge/Lisans-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ollama](https://img.shields.io/badge/Ollama-0.40.16+-blue.svg)](https://ollama.com/)
[![Test Durumu](https://img.shields.io/badge/Testler-213%2F213%20Ge%C3%A7ti-brightgreen.svg)]()

> **Bu proje neden var?**  
> 6 GB VRAM'e sahip ekran kartlarında (özellikle NVIDIA GTX 1060 ve Pascal cc 6.1 serisi) **Cline**, **VS Code** ve **Ollama (qwen2.5-coder:7b)** çalıştırmak; beklenmedik çökmeler, 32 ardışık `@` karakteri döngüleri, bilgisayar kilitlenmeleri ve C: diski dolma sorunları yaratabilir.  
> Bu depo; yaşanan tüm sorunların kanıtlanmış kök nedenlerini, derlenmiş ve test edilmiş hazır VSIX eklenti paketini ve tek tıkla kurulum araçlarını sunar.

---

## 1. Tespit Edilen Kök Nedenler ve Çözümleri

### 1. 32 Ardışık '@' Karakteri Hatası
* **Belirti:** Cline penceresinde `32 consecutive '@' characters at the start of the response` hatası çıkar ve akış durur.
* **Kök Neden:** 
  1. Cline, modele 6 adet araç tanımlar ve sistem talimatında `"Her zaman araç çağrısı kullan"` der.
  2. Kullanıcı ise örneğin *"Sadece metin yaz, araç kullanma"* gibi bir talimat verdiğinde 7B parametreli model ikilemde kalır ve araç çağırma sembolü olan `@` işaretini üretir.
  3. Cline akışı durdurur fakat **bu `@` işaretlerini sohbet geçmişine (asistan mesajı olarak) kaydeder**.
  4. Kullanıcı tekrar bir şey yazdığında, Cline bu 200+ adet `@` karakterini modele geri gönderir. Model geçmişinde bunu görüp 300+ tane daha `@` üretmeye başlar (zehirlenmiş geçmiş döngüsü).
* **Çözüm:** `@` hatası alındığında o görevi sürdürmek yerine yeni bir temiz görev (Task) açılmalıdır. Depoda bulunan özel VSIX paketi, modelin ürettiği ham yanıtları `Captures/` klasörüne kaydederek hatayı kesin olarak teşhis etmenizi sağlar.

---

### 2. GTX 1060 (Pascal cc 6.1) ve Ollama CUDA Geçişi
* **Belirti:** Ollama açılışında `skipping CUDA device "NVIDIA GeForce GTX 1060 6GB" (compute capability 6.1 not in architectures)` uyarısı görülür.
* **Kök Neden:** Ollama `cuda_v13` ve `cuda_v12` kütüphanelerini birlikte taşır. `cuda_v13` Pascal mimarisini atlasa bile, Ollama otomatik olarak `cuda_v12` kütüphanesine geçer ve kartı **5.1 GB VRAM** ile CUDA olarak başarıyla kullanır.
* **Sürücü Gereksinimi:** NVIDIA GeForce sürücünüzün **572.70** veya üstü olması şarttır. Eski sürücüler PTX uyumsuzluk hatası verir.

---

### 3. llama-server Çökmesi (0xc0000409) ve Soket Kapanması
* **Belirti:** Cline'da `SocketError: other side closed` hatası alınır.
* **Kök Neden:** Cline varsayılan olarak `num_ctx: 32768` (32 bin token) context gönderir. 6 GB VRAM'li bir kartta 32K context, Windows Masaüstü Yöneticisi (DWM) ile birleşince VRAM'i ve sanal belleği aşar, `llama-server` çöker.
* **Çözüm:** Cline ayarlarından **Context Window** değerini **4096** veya en fazla **8192** yapınız.

---

### 4. C: Sürücüsü Alan Yetersizliği ve Bilgisayarın Kilitlenmesi
* **Kök Neden:** C: sürücüsünde 1-2 GB'tan az boş alan kaldığında, modelin bellek takas dosyası (pagefile.sys) yazılamaz ve Windows kilitlenir.
* **Çözüm:** Ollama modelleri ve çalışma ortamı tamamen ikincil sürücüye (D: veya E:) taşınmalıdır (`OLLAMA_MODELS=D:\Ollama\Models`).

---

## 2. Gerekli Programlar ve Kesin Sürüm Eşleşmeleri

> [!WARNING]
> **ÖNEMLİ — BAĞLANTI ZAMAN AŞIMI VE SÜRÜM UYARISI:**  
> İnternetteki indirme linkleri zamanla değişebilir veya ölebilir (kırık link). Daha da önemlisi, **rastgele en güncel sürümü indirmeyiniz**. Gelecekte çıkacak NVIDIA sürücüleri veya yeni Ollama runner sürümleri GTX 1060 (Pascal cc 6.1) mimarisini tamamen devre dışı bırakabilir.  
> Bu sistemde bizzat test edilip doğrulanan **kesin sürüm ve dosya adları** şunlardır:

| Program / Araç | Doğrulanan Kesin Sürüm | İndirilen Dosya Adı | Neden Bu Sürüm? |
| :--- | :--- | :--- | :--- |
| **NVIDIA Sürücüsü** | **572.70** (veya 570+) | `572.70-desktop-win10-win11-64bit-international-dch-whql.exe` | Eski sürücüler PTX hatası verir, bu sürümde CUDA 12.x Pascal uyumu tamdır. |
| **Git for Windows** | **2.56.0.4** (veya 2.47+) | `Git-2.56.0.4-64-bit.exe` | Kararlı Windows 64-bit git altyapısı. |
| **Bun Runtime** | **1.4.4** (baseline) | `bun-windows-x64-baseline.zip` | Cline eklenti test ve derleme ortamı bu sürümü gerektirir. |
| **Ollama** | **0.40.16** | `OllamaSetup.exe` | İçerisinde sm_61 desteği derlenmiş `cuda_v12` taşır. |
| **Model** | **qwen2.5-coder:7b** | `qwen2.5-coder:7b` (Q4_K_M ~4.36GB) | 6 GB VRAM'e tam sığar (4096 context ile). |
| **Hazır Eklenti** | **Cline 4.1.26** | `Cline-4.1.26-WireResponse-Capture.vsix` | Ham yanıt yakalama yamalı ve 213 test onaylı. |

- **NVIDIA Sürücü Bağlantısı:** [NVIDIA Resmi Sürücü 280050](https://www.nvidia.com/en-us/drivers/details/280050/)
- **Git for Windows:** [Git Resmi Sayfası](https://git-scm.com/download/win)
- **Bun Runtime:** [Bun Resmi Sayfası](https://bun.sh/)
- **Ollama for Windows:** [Ollama Resmi Sayfası](https://ollama.com/download)

---

## 3. Tek Tıkla Kurulum ve Güvenli Kaldırma (Uninstall)

Bu depoda tüm testleri geçmiş hazır eklenti paketi bulunmaktadır:  
`bin/Cline-4.1.26-WireResponse-Capture.vsix` (213/213 test başarılı).

### Kurulum: `install.bat`
1. `install.bat` dosyasına çift tıklayarak çalıştırın.
2. Eklenti VS Code profilinize kurulur.
3. `start-ollama.bat` ile modelleri D: sürücüsünde saklayacak şekilde Ollama'yı başlatın.
4. VS Code'da Cline ayarlarından:
   * **API Provider:** `Ollama`
   * **Model:** `qwen2.5-coder:7b`
   * **Context Window:** `4096` veya `8192` olarak ayarlayın.

### Güvenli Kaldırma: `uninstall.bat`
Eklentiyi ve masaüstü kısayollarını kaldırmak istediğinizde `uninstall.bat` dosyasına çift tıklayın.  
> [!NOTE]  
> **Kullanıcı Verisi Güvencesi:** Kaldırma aracı `D:\Ollama\Models` altındaki yapay zeka modellerinize ve çalışma projelerinize **ASLA DOKUNMAZ**. Yalnızca Cline eklentisini ve kısayolu güvenle temizler.

---

## 4. Lisans ve Sorumluluk Reddi
Bu proje MIT lisansı ile sunulmaktadır. Yapay zeka destekli araştırma ve doğrulama süreçleri ile üretilmiştir. Üretim ortamlarında kullanmadan önce yedek almanız önerilir.
