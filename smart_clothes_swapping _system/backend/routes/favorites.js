const express = require('express');
const router = express.Router();
const db = require('../db/connection');



// 1. Favori kıyafetlerin detaylarını getirme
router.get('/details', (req, res) => {
  const {user_id} = req.query;
  const query = `
    SELECT clothing.id, clothing.category, clothing.color, clothing.size, clothing.brand, clothing.photo_path
    FROM favorites
    INNER JOIN clothing ON favorites.clothing_id = clothing.id
    WHERE favorites.user_id = ?
  `;

  db.query(query, [user_id], (err, results) => {
    if (err) {
      console.error('Favori detaylarını çekerken hata:', err);
      return res.status(500).json({ message: 'Favori detaylarını getirme hatası' });
    }

    res.status(200).json(results);
  });
});

// 2. Kullanıcının favorilerini getirme (sadece clothing_id döndürür)
router.get('/', (req, res) => {
  const {user_id} = req.query;
  const query = 'SELECT clothing_id FROM favorites WHERE user_id = ?';

  db.query(query, [user_id], (err, results) => {
    if (err) {
      console.error('Favorileri çekerken hata:', err);
      return res.status(500).json({ message: 'Favori çekme hatası' });
    }

    res.status(200).json(results);
  });
});

// 3. Favori ekleme işlemi
router.post('/add', (req, res) => {
  const { user_id, clothing_id } = req.body;

  console.log('Gelen istek:', req.body); // Gelen isteği logla

  if (!user_id || !clothing_id) {
    console.error('Eksik parametre: user_id veya clothing_id');
    return res.status(400).json({ message: 'Kullanıcı ID ve Kıyafet ID gereklidir.' });
  }

  const checkQuery = 'SELECT * FROM favorites WHERE user_id = ? AND clothing_id = ?';
  db.query(checkQuery, [user_id, clothing_id], (err, results) => {
    if (err) {
      console.error('Favori kontrolünde hata:', err);
      return res.status(500).json({ message: 'Favori kontrol hatası' });
    }

    if (results.length > 0) {
      console.error('Bu kıyafet zaten favorilerde:', clothing_id);
      return res.status(400).json({ message: 'Bu kıyafet zaten favorilerde.' });
    }

    const query = 'INSERT INTO favorites (user_id, clothing_id) VALUES (?, ?)';
    db.query(query, [user_id, clothing_id], (err) => {
      if (err) {
        console.error('Favorilere ekleme sırasında hata:', err);
        return res.status(500).json({ message: 'Favorilere ekleme hatası' });
      }

      console.log('Kıyafet favorilere eklendi:', clothing_id);
      res.status(200).json({ message: 'Kıyafet favorilere eklendi!' });
    });
  });
});

// 4. Favori silme işlemi
router.post('/remove', (req, res) => {
  const { user_id, clothing_id } = req.body;

  if (!user_id || !clothing_id) {
    return res.status(400).json({ message: 'Kullanıcı ID ve Kıyafet ID gereklidir.' });
  }

  const query = 'DELETE FROM favorites WHERE user_id = ? AND clothing_id = ?';
  db.query(query, [user_id, clothing_id], (err) => {
    if (err) {
      console.error('Favorilerden silme sırasında hata:', err);
      return res.status(500).json({ message: 'Favorilerden silme hatası' });
    }

    res.status(200).json({ message: 'Kıyafet favorilerden çıkarıldı!' });
  });
});

module.exports = router;
