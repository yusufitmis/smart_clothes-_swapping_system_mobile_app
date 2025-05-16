const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');  // Dosya yollarını işlemek için
const db = require('./db/connection');  // "../" yerine "./" kullan
const multer = require("multer");
const fs = require("fs");
const WebSocket = require("ws");

const clothingRoutes = require('./routes/clothing');
const favoriteRoutes = require('./routes/favorites');
const combinationRoutes = require('./routes/combinations');

const app = express();
const port = 3000;



// Multer yapılandırması
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = "uploads";
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });
// WebSocket Sunucusu
const wss = new WebSocket.Server({ noServer: true });
let connectedClients = [];

wss.on("connection", (ws) => {
  console.log("Yeni bir WebSocket bağlantısı.");
  connectedClients.push(ws);

  ws.on("message_text", (message_text) => {
    console.log("Alınan mesaj:", message_text);
    // Gelen mesajı diğer tüm istemcilere yayınla
    connectedClients.forEach((client) => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(message_text);
      }
    });
  });

  ws.on("close", () => {
    console.log("WebSocket bağlantısı kapandı.");
    connectedClients = connectedClients.filter((client) => client !== ws);
  });
});
// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Rotaları bağla
app.use('/clothing', clothingRoutes);
app.use('/favorites', favoriteRoutes);
app.use('/combinations', combinationRoutes);

app.get('/user-profile', (req, res) => {
  console.log('Received request for /user-profile');
  const { userId } = req.query;

  if (!userId) {
    console.log('No userId provided');
    return res.status(400).json({ success: false, message: 'User ID gerekli.' });
  }

  const query = `
    SELECT
      u.id, u.fullname, u.username, u.email, u.profile_pic_path,
      (SELECT COUNT(*) FROM followers WHERE followed_id = u.id) AS followers_count,
      (SELECT COUNT(*) FROM followers WHERE follower_id = u.id) AS following_count
    FROM users u
    WHERE u.id = ?
  `;

  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      return res.status(500).json({ success: false, message: 'Profil alınamadı.' });
    }

    if (results.length === 0) {
      console.log('No user found');
      return res.status(404).json({ success: false, message: 'Kullanıcı bulunamadı.' });
    }

    const user = results[0];

    // Profil fotoğrafı varsa tam dosya yolunu ekle
    if (user.profile_pic_path) {
      user.profile_pic_path = `http://10.0.2.2:3000/${user.profile_pic_path.replace(/\\/g, '/')}`;
    } else {
      user.profile_pic_path = null; // Fotoğraf yoksa null döndür
    }

    res.json({
      success: true,
      user: {
        id: user.id,
        fullname: user.fullname,
        username: user.username,
        email: user.email,
        profile_pic_path: user.profile_pic_path,
        followers_count: user.followers_count,
        following_count: user.following_count,
      },
    });
  });
});

app.get('/posts', (req, res) => {
  const userId = req.query.userId;
  const query = `
    SELECT
  content,
  CONCAT('http://10.0.2.2:3000/', image_path) AS image_path,
  created_at
  FROM posts
  WHERE user_id = ?
  ORDER BY created_at DESC;

  `;
  db.query(query, [userId], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veri alınırken hata oluştu.', error: err });
    }
    res.status(200).json(results);
  });
});

app.post('/create-post', upload.single('image'), (req, res) => {
  const { user_id, content } = req.body;
  const image_path = req.file ? `uploads/${req.file.filename}` : null;

  if (!user_id || !content) {
    return res.status(400).json({ message: 'user_id and content are required.' });
  }

  const query = `
    INSERT INTO posts (user_id, content, image_path)
    VALUES (?, ?, ?)
  `;

  db.query(query, [user_id, content, image_path], (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ message: 'Post could not be created.', error: err });
    }
    res.status(200).json({ message: 'Post created successfully.', postId: result.insertId });
  });
});

app.get("/search-users", (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ success: false, message_text: "Arama kriteri gerekli." });
  }

  const searchQuery = `
    SELECT id, username, fullname
    FROM users
    WHERE username LIKE ? OR fullname LIKE ?
  `;
  const searchValue = `%${query}%`;

  db.query(searchQuery, [searchValue, searchValue], (err, results) => {
    if (err) {
      console.error("Arama sırasında hata oluştu: ", err);
      return res.status(500).json({ success: false, message_text: "Arama yapılamadı." });
    }

    res.json({ success: true, users: results });
  });
});

app.post('/unfollow', (req, res) => {
  const { follower_id, followed_id } = req.body;

  if (!follower_id || !followed_id) {
    return res.status(400).json({ message: 'Eksik parametreler' });
  }

  const query = `
    DELETE FROM followers
    WHERE follower_id = ? AND followed_id = ?
  `;

  db.query(query, [follower_id, followed_id], (err, result) => {
    if (err) {
      console.error('Takipten çıkma işlemi sırasında hata oluştu:', err);
      return res.status(500).json({ message: 'Takipten çıkma işlemi sırasında hata oluştu.' });
    }

    if (result.affectedRows > 0) {
      res.status(200).json({ message: 'Takipten çıkıldı' });
    } else {
      res.status(404).json({ message: 'Takip ilişkisi bulunamadı.' });
    }
  });
});
// Takip edilen kullanıcı sayısını alma
app.get('/followers-count', (req, res) => {
  const { userId } = req.query;

  db.query(
    'SELECT COUNT(*) AS followers_count FROM followers WHERE followed_id = ?',
    [userId],
    (err, results) => {
      if (err) {
        console.error("Takipçi sayısı alınırken hata oluştu:", err);
        return res.status(500).json({ message: "Takipçi sayısı alınırken hata oluştu." });
      }
      res.status(200).json({ followers_count: results[0].followers_count });
    }
  );
});
app.get('/check-follow', (req, res) => {
  const { follower_id, followed_id } = req.query;

  if (!follower_id || !followed_id) {
    return res.status(400).json({ message: 'Eksik parametreler' });
  }

  const query = `
    SELECT COUNT(*) AS count
    FROM followers
    WHERE follower_id = ? AND followed_id = ?
  `;

  db.query(query, [follower_id, followed_id], (err, results) => {
    if (err) {
      console.error("Takip durumu kontrol edilirken hata oluştu:", err);
      return res.status(500).json({ message: 'Sunucu hatası' });
    }

    const isFollowing = results[0].count > 0;
    res.status(200).json({ isFollowing });
  });
});
app.get('/following-posts', (req, res) => {
  const userId = req.query.userId; // Query param kullanımı

  const query = `
    SELECT
      posts.content,
      CONCAT('http://10.0.2.2:3000/', posts.image_path) AS image_path,
      posts.created_at,
      users.username
    FROM posts
    JOIN followers ON followers.followed_id = posts.user_id
    JOIN users ON users.id = posts.user_id
    WHERE followers.follower_id = ?
    ORDER BY posts.created_at DESC;
  `;

  db.query(query, [userId], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veri alınırken hata oluştu.', error: err });
    }
    res.status(200).json(results);
  });
});

app.post('/follow', (req, res) => {
  const { follower_id, followed_id } = req.body;

  if (!follower_id || !followed_id) {
    return res.status(400).json({ message: 'Eksik parametreler' });
  }

  // Takip işlemi eklemek için query
  const query = `
    INSERT INTO followers (follower_id, followed_id)
    VALUES (?, ?)
  `;

  db.query(query, [follower_id, followed_id], (err, result) => {
    if (err) {
      console.error('Takip etme işlemi sırasında hata oluştu:', err);
      return res.status(500).json({ message: 'Takip etme işlemi sırasında hata oluştu.' });
    }

    if (result.affectedRows > 0) {
      res.status(200).json({ message: 'Takip edilmeye başlandı' });
    } else {
      res.status(400).json({ message: 'Takip işlemi başarısız' });
    }
  });
});

  // Mesaj gönderme ve alma (HTTP üzerinden)
app.post("/send-message", (req, res) => {
  const { sender_id, receiver_id, message_text } = req.body;

  if (!sender_id || !receiver_id || !message_text) {
    return res.status(400).json({ success: false, message_text: "Eksik bilgiler." });
  }

  const query = "INSERT INTO messages (sender_id, receiver_id, message_text, sent_at) VALUES (?, ?, ?, NOW())";
  db.query(query, [sender_id, receiver_id, message_text], (err, result) => {
    if (err) {
      console.error("Mesaj gönderme hatası: ", err);
      return res.status(500).json({ success: false, message_text: "Mesaj gönderilemedi." });
    }

    // Mesajı WebSocket üzerinden yayınla
    connectedClients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ sender_id, receiver_id, message_text }));
      }
    });

    res.json({ success: true, message_text: "Mesaj başarıyla gönderildi." });
  });
});


app.get("/chat", (req, res) => {
  const { senderId, receiverId } = req.query;

  if (!senderId || !receiverId) {
    return res.status(400).json({ success: false, message_text: "Eksik bilgiler." });
  }

  const query = `
    SELECT m.*, u.username AS senderUsername
    FROM messages m
    JOIN users u ON m.sender_id = u.id
    WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?)
    ORDER BY m.sent_at ASC
  `;

  db.query(query, [senderId, receiverId, receiverId, senderId], (err, results) => {
    if (err) {
      console.error("Mesajları getirme hatası: ", err);
      return res.status(500).json({ success: false, message_text: "Mesajlar getirilemedi." });
    }

    res.json({ success: true, messages: results });
  });
});

app.get("/inbox", (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ success: false, message: "Kullanıcı ID gerekli." });
  }

  const query = `
    SELECT m.receiver_id, m.sender_id, m.message_text AS lastMessage, u.username AS senderUsername, m.sent_at
    FROM messages m
    JOIN users u ON m.sender_id = u.id
    WHERE m.receiver_id = ?
    AND m.sent_at = (SELECT MAX(sent_at) FROM messages WHERE receiver_id = ? AND sender_id = m.sender_id)
    ORDER BY m.sent_at DESC
  `;

  db.query(query, [userId, userId], (err, results) => {
    if (err) {
      console.error("Gelen kutusu hatası: ", err);
      return res.status(500).json({ success: false, message: "Gelen kutusu alınamadı." });
    }

    res.json({ success: true, messages: results });
  });
});
app.post('/update-profile-picture', upload.single('profilePicture'), (req, res) => {
  const { userId } = req.body;
  const filePath = req.file.path;

  const query = `UPDATE users SET profile_pic_path = ? WHERE id = ?`;
  db.query(query, [filePath, userId], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ success: false, message: 'Fotoğraf güncellenemedi.' });
    }
    res.json({ success: true, message: 'Fotoğraf başarıyla güncellendi.' });
  });
});

// Sunucuyu başlat
app.listen(port, '0.0.0.0', () => {
  console.log('Server is running on port 3000');
});


app.post("/login", (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ success: false, message_text: "Eksik bilgiler." });
  }

  const query = "SELECT * FROM users WHERE username = ? AND password = ?";
  db.query(query, [username, password], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ success: false, message_text: "Giriş başarısız." });
    }

    if (results.length > 0) {
      const user = results[0];
      res.json({
        success: true,
        message_text: "Giriş başarılı.",
        user: {
          id: user.id,
          fullname: user.fullname,
          username: user.username,
          email: user.email,
          birth_date: user.birth_date,
          city: user.city,
          height: user.height,
          weight: user.weight,
          gender: user.gender,
          created_at: user.created_at,
        },
      });
    } else {
      res.status(401).json({ success: false, message_text: "Kullanıcı adı veya şifre hatalı." });
    }
  });
});

app.post("/register", (req, res) => {
  const { fullname, username, email, password } = req.body;

  if (!fullname || !username || !email || !password) {
    return res.status(400).json({ success: false, message_text: "Eksik bilgiler." });
  }

  const query = `
    INSERT INTO users 
    (fullname, username, email, password, created_at) 
    VALUES (?, ?, ?, ?, NOW())
  `;

  db.query(query, [fullname, username, email, password], (err, result) => {
    if (err) {
      console.error("Veritabanı Hatası:", err);
      return res.status(500).json({ success: false, message_text: "Kayıt başarısız.", error: err.sqlMessage });
    }
    
    console.log("Yeni kullanıcı kaydedildi:", result);
    res.json({ success: true, message_text: "Kullanıcı başarıyla kaydedildi." });
  });
});

app.post("/upload", upload.single("image"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: "Dosya yüklenemedi." });
    }

    const imagePath = req.file.path;
    res.json({ success: true, imagePath: imagePath });
  } catch (error) {
    console.error("Dosya yükleme hatası:", error);
    res.status(500).json({ success: false, message: "Dosya yüklenirken hata oluştu." });
  }
});

app.post("/addClothing", upload.single("photo"), (req, res) => {
  try {
    console.log("Gelen istek body:", JSON.stringify(req.body, null, 2));
    console.log("Gelen dosya:", req.file ? {
      filename: req.file.filename,
      path: req.file.path,
      originalname: req.file.originalname
    } : "Dosya yok");

    const { category, color, size, brand, user_id } = req.body;

    // Eksik bilgi kontrolü
    if (!category || !color || !size || !brand || !user_id || !req.file) {
      console.log("Eksik bilgiler:", {
        category: !category,
        color: !color,
        size: !size,
        brand: !brand,
        user_id: !user_id,
        file: !req.file
      });
      return res.status(400).json({ success: false, message: "Eksik bilgiler." });
    }

    // Sadece dosya adını kullan, uploads/ klasör yolunu kullanma
    const photo_path = req.file.filename;

    const query = `
      INSERT INTO clothing (category, color, size, brand, photo_path, user_id) 
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    
    console.log("SQL sorgusu:", query);
    console.log("Parametreler:", [category, color, size, brand, photo_path, user_id]);
    
    db.query(query, [category, color, size, brand, photo_path, user_id], (err, result) => {
      if (err) {
        console.error("Veritabanı hatası:", err);
        return res.status(500).json({ success: false, message: "Kıyafet eklenirken hata oluştu." });
      }

      console.log("Kıyafet başarıyla eklendi:", result);
      res.json({ success: true, message: "Kıyafet başarıyla eklendi.", id: result.insertId });
    });
  } catch (error) {
    console.error("Genel hata:", error);
    res.status(500).json({ success: false, message: "Sunucu hatası" });
  }













// HTTP sunucusu ve WebSocket entegrasyonu
const server = app.listen(port, () => {
  console.log(`Server çalışıyor: http://localhost:3000`);
});

server.on("upgrade", (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit("connection", ws, request);
  });
});

});

