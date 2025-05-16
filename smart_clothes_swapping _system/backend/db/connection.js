const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '1234',  // Şifreyi kendinize göre düzenleyin
  database: 'AKTS',  // Veritabanı ismini yazın
});

db.connect((err) => {
  if (err) {
    console.error('Veritabanı bağlantısı başarısız:', err);
  } else {
    console.log('Veritabanı bağlantısı başarılı!');
  }
});

module.exports = db;
