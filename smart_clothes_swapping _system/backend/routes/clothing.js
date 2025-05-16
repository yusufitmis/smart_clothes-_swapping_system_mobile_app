const express = require('express');
const axios = require('axios');
const db = require('../db/connection');
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const router = express.Router();

// Remove.bg API key
const REMOVE_BG_API_KEY = 'BUF2tAy23JzyhmGaV8gSzM3j';


// Fotoğraf URL'si ile kıyafet ekleme ve arka plan silme
router.post('/upload-image', async (req, res) => {
  const { image_url, brand, size, category, user_id } = req.body; // user_id'yi body'den al


  if (!image_url || !brand || !size || !category|| !user_id) {
    return res.status(400).json({ message: 'Tüm alanlar doldurulmalıdır!' });
  }

  try {
    // 1. Görseli Remove.bg kullanarak arka planını kaldır ve kaydet
    const response = await axios.post(
      'https://api.remove.bg/v1.0/removebg',
      { image_url },
      {
        headers: { 'X-Api-Key': REMOVE_BG_API_KEY },
        responseType: 'arraybuffer',
      }
    );

    const imageBuffer = response.data;
    const uploadsDir = path.join(__dirname, '..', 'uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    const imageFileName = `image_${Date.now()}.png`;
    const savedImagePath = path.join(uploadsDir, imageFileName);
    fs.writeFileSync(savedImagePath, imageBuffer);

    // 2. Sharp ile görseli işleyelim ve renk çözümleme için yeniden boyutlandıralım
    const sharpResult = await sharp(savedImagePath)
      .resize(100, 100)  // Küçük bir boyutta çözümleme yapalım
      .raw()  // Piksel verisini ham formatta alalım
      .toBuffer({ resolveWithObject: true });

    const { data, info } = sharpResult;  // `data` ham piksel verisi, `info` resim hakkında bilgi
    const width = info.width;
    const height = info.height;

    // Hata ayıklama için Sharp resim bilgilerini kontrol et
    console.log('Resim Bilgileri:', info);

    let r = 0, g = 0, b = 0;
    let pixelCount = 0;

    // Piksel verisini çözümleyelim ve renkleri hesaplayalım
    for (let i = 0; i < data.length; i += 4) {  // 4: R, G, B, A kanalını alıyoruz
      r += data[i];     // Kırmızı kanal
      g += data[i + 1]; // Yeşil kanal
      b += data[i + 2]; // Mavi kanal
      pixelCount++;
    }

    // Ortalama renk hesapla
    r = Math.round(r / pixelCount);
    g = Math.round(g / pixelCount);
    b = Math.round(b / pixelCount);

    // Ortaya çıkan dominant rengi `rgb` formatında kaydedelim
    const dominantColorRgb = `rgb(${r}, ${g}, ${b})`;
    console.log('Dominant Renk:', dominantColorRgb);

    // Eğer dominant renk hesaplanamadıysa hata verelim
    if (!dominantColorRgb || dominantColorRgb === 'rgb(0, 0, 0)') {
      console.error('Renk verisi alınamadı veya yanlış renk.');
      throw new Error('Renk verisi alınamadı.');
    }

    // 3. Veritabanına kaydet
    const query = `
      INSERT INTO clothing (photo_path, user_id, brand, size, category, color)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    db.query(
      query,
      [imageFileName, user_id, brand, size, category, dominantColorRgb],
      (err, result) => {
        if (err) throw err;
        res.status(200).json({ message: 'Kıyafet başarıyla eklendi!', color: dominantColorRgb, id: result.insertId });
      }
    );
  } catch (error) {
    console.error('Bir hata oluştu:', error);
    res.status(500).json({ message: 'Bir hata oluştu.', error: error.message });
  }
});

// Kıyafetleri çekme API'si (GET)
router.get('/', (req, res) => {
  const { user_id } = req.query; // Query parametresi olarak userId'yi alın

  if (!user_id) {
    return res.status(400).json({ message: 'Kullanıcı ID\'si gereklidir.' });
  }

  const query = 'SELECT id, category, color, size, brand, photo_path FROM clothing WHERE user_id = ?';

  db.query(query, [user_id], (err, results) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      return res.status(500).json({ message: 'Kıyafetleri çekerken bir hata oluştu.' });
    }

    res.status(200).json(results);
  });
});

// Kıyafet güncelleme API'si (PUT)
router.put('/:id', (req, res) => {
  const clothingId = req.params.id;
  const {id, brand, size, category } = req.body;

  if (!brand || !size || !category) {
    return res.status(400).json({ message: 'Tüm alanlar doldurulmalıdır!' });
  }

  const query = `
    UPDATE clothing
    SET brand = ?, size = ?, category = ?
    WHERE id = ?
  `;

  db.query(query, [brand, size, category, clothingId], (err, result) => {
    if (err) {
      console.error('Güncelleme hatası:', err);
      return res.status(500).json({ message: 'Kıyafet güncellenirken bir hata oluştu.' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Kıyafet bulunamadı.' });
    }

    res.status(200).json({ message: 'Kıyafet başarıyla güncellendi.' });
  });
});

// Kıyafet silme API'si (DELETE)
router.delete('/:id', (req, res) => {
  const clothingId = req.params.id;

  const query = 'DELETE FROM clothing WHERE id = ?';

  db.query(query, [clothingId], (err, result) => {
    if (err) {
      console.error('Silme hatası:', err);
      return res.status(500).json({ message: 'Kıyafet silinirken bir hata oluştu.' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Kıyafet bulunamadı.' });
    }

    res.status(200).json({ message: 'Kıyafet başarıyla silindi.' });
  });
});

module.exports = router;
