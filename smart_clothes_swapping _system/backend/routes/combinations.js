const express = require('express');
const db = require('../db/connection');
const router = express.Router();

// Kombin oluşturma
router.post('/create', (req, res) => {
  const { name, description, clothing_ids } = req.body;
  const user_id = 1; // Sabit kullanıcı ID

  // Gelen veriyi kontrol et
  if (!name || !clothing_ids || clothing_ids.length === 0) {
    return res.status(400).json({ message: 'Tüm bilgiler gereklidir.' });
  }

  // Kombin oluşturma sorgusu
  const insertCombination = `
    INSERT INTO combinations (user_id, name, description)
    VALUES (?, ?, ?)
  `;

  db.query(insertCombination, [user_id, name, description], (err, result) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      return res.status(500).json({ message: 'Kombin oluşturma hatası' });
    }

    const combinationId = result.insertId;
    console.log('Kombin ID: ', combinationId); // Kombin ID'si doğru alınıyor mu kontrol et

    // Kombin öğelerini ekleme
    const insertItems = `
      INSERT INTO combination_items (combination_id, clothing_id)
      VALUES ?
    `;
    const itemsData = clothing_ids.map((id) => [combinationId, id]);

    db.query(insertItems, [itemsData], (err) => {
      if (err) {
        console.error('Kombin öğelerini eklerken hata:', err);
        return res.status(500).json({ message: 'Kombin öğelerini ekleme hatası' });
      }

      console.log('Kombin öğeleri başarıyla eklendi!');
      res.status(200).json({ message: 'Kombin başarıyla oluşturuldu!' });
    });
  });
});

// Kombin silme
router.delete('/:id', (req, res) => {
  const combinationId = req.params.id;

  // Önce kombin öğelerini sil
  const deleteItemsQuery = 'DELETE FROM combination_items WHERE combination_id = ?';
  db.query(deleteItemsQuery, [combinationId], (err) => {
    if (err) {
      console.error('Kombin öğelerini silme hatası:', err);
      return res.status(500).json({ message: 'Kombin öğelerini silme hatası' });
    }

    // Sonra kombin kendisini sil
    const deleteCombinationQuery = 'DELETE FROM combinations WHERE id = ?';
    db.query(deleteCombinationQuery, [combinationId], (err, result) => {
      if (err) {
        console.error('Kombin silme hatası:', err);
        return res.status(500).json({ message: 'Kombin silme hatası' });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Kombin bulunamadı.' });
      }

      res.status(200).json({ message: 'Kombin başarıyla silindi.' });
    });
  });
});

// Kombin öğesi silme
router.delete('/:combinationId/items/:itemId', (req, res) => {
  const combinationId = req.params.combinationId;
  const itemId = req.params.itemId;

  const deleteItemQuery = 'DELETE FROM combination_items WHERE combination_id = ? AND id = ?';
  db.query(deleteItemQuery, [combinationId, itemId], (err, result) => {
    if (err) {
      console.error('Kombin öğesi silme hatası:', err);
      return res.status(500).json({ message: 'Kombin öğesi silme hatası' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Kombin öğesi bulunamadı.' });
    }

    res.status(200).json({ message: 'Kombin öğesi başarıyla silindi.' });
  });
});

const checkClothingIds = (clothingIds, callback) => {
  const query = 'SELECT clothing_id FROM combination_items WHERE clothing_id IN (?)';
  db.query(query, [clothingIds], (err, results) => {
    if (err) {
      console.error('Kıyafet ID kontrol hatası:', err);
      return callback(err, null);
    }

    console.log('Seçili kıyafetler:', clothingIds);
    console.log('Bulunan kıyafetler:', results);

    // Eğer sonuçların uzunluğu, gönderilen ID'lerin uzunluğu ile eşleşmiyorsa geçersiz ID'ler var demektir
    callback(null, results.length === clothingIds.length);
  });
};

router.put('/:id', (req, res) => {
  const combinationId = req.params.id;
  const { name, description } = req.body;

  if (!name || !description) {
    return res.status(400).json({ message: 'Lütfen tüm alanları doldurun.' });
  }

  // Sadece kombin bilgilerini güncelle
  const updateCombinationQuery = `
    UPDATE combinations
    SET name = ?, description = ?
    WHERE id = ?
  `;

  db.query(updateCombinationQuery, [name, description, combinationId], (err, result) => {
    if (err) {
      console.error('Kombin güncelleme hatası:', err);
      return res.status(500).json({ message: 'Kombin güncellenirken bir hata oluştu' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Kombin bulunamadı.' });
    }

    res.status(200).json({ message: 'Kombin başarıyla güncellendi!' });
  });
});


// Tüm kombinleri listeleme
router.get('/list', (req, res) => {
  const user_id = 1; // Sabit kullanıcı ID

  const query = `
    SELECT c.id, c.name, c.description, c.created_at
    FROM combinations c
    WHERE c.user_id = ?
    ORDER BY c.created_at DESC
  `;

  db.query(query, [user_id], (err, results) => {
    if (err) {
      console.error('Kombinleri listeleme hatası:', err);
      return res.status(500).json({ message: 'Kombinleri listeleme hatası' });
    }

    res.status(200).json({ combinations: results });
  });
});

// Bir kombin içindeki öğeleri listeleme
router.get('/:id/items', (req, res) => {
  const combinationId = req.params.id;

  const query = `
    SELECT ci.id AS combination_item_id, cl.id AS clothing_id,
           cl.category, cl.color, cl.size, cl.brand, cl.photo_path
    FROM combination_items ci
    JOIN clothing cl ON ci.clothing_id = cl.id
    WHERE ci.combination_id = ?
  `;

  db.query(query, [combinationId], (err, results) => {
    if (err) {
      console.error('Kombin öğelerini listeleme hatası:', err);
      return res.status(500).json({ message: 'Kombin öğelerini listeleme hatası' });
    }

    res.status(200).json({ items: results });
  });
});

router.post('/:id/items', (req, res) => {
  const combinationId = req.params.id;
  const { clothing_ids } = req.body;

  if (!clothing_ids || clothing_ids.length === 0) {
    return res.status(400).json({ message: 'Lütfen en az bir kıyafet seçin.' });
  }

  const insertItemsQuery = `
    INSERT INTO combination_items (combination_id, clothing_id)
    VALUES ?
  `;
  const itemsData = clothing_ids.map((id) => [combinationId, id]);

  db.query(insertItemsQuery, [itemsData], (err, result) => {
    if (err) {
      console.error('Kıyafetler eklenirken hata:', err);
      return res.status(500).json({ message: 'Kıyafetler eklenirken bir hata oluştu' });
    }

    res.status(200).json({ message: 'Kıyafetler başarıyla eklendi!' });
  });
});

module.exports = router;
