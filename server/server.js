const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const bcrypt = require('bcrypt');
const session = require('express-session');

const app = express();
app.use(express.json());


app.use(session({
  secret: 'your_secret_key_here',
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false } // set to true if using HTTPS
}));


// PostgreSQL bağlantısı için konfigürasyon objesi
const config = {
user: 'postgres',
host: 'localhost',
database: 'GeekchainDB',
password: 'gizem',
port: 5433, // default Postgres port
};

// PostgreSQL veritabanına bağlan
const pool = new pg.Pool(config);

// Postgresql bağlantısının başarısız olması durumunda hata mesajı ver
pool.on('error', function (err) {
console.error('idle client error', err.message, err.stack)
});

app.use(bodyParser.urlencoded({ extended: true }));

app.post('/api/login', async (req, res) => {
  let { email, password } = req.body;

  try {
    const user = await pool.query(
      `SELECT * FROM users
      WHERE email = $1`,
      [email]
    );

    if (user.rows.length === 0) {
      return res.status(401).send({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, user.rows[0].password);

    if (!isMatch) {
      return res.status(401).send({ message: "Invalid email or password" });
    }

    // Kullanıcının kimlik doğrulaması başarılı oldu, bir oturum oluşturabiliriz
    req.session.user = user.rows[0].id;

    res.status(200).send({ message: "Login successful" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});


app.post('/api/logout', (req, res) => {
  // Kullanıcının oturumunu sonlandırın
  req.session.destroy((err) => {
    if (err) {
      console.error(err.message);
      res.status(500).send({ message: "Server error" });
    } else {
      res.send({ message: "Logout successful" });
    }
  });
});

app.post('/api/register', async (req, res) => {
  let {fName, lname, email, password, password2, phone, birthday} = req.body;

  let errors = [];

  console.log({
    fName,
    lname,
    email,
    password,
    password2,
    phone,
    birthday
  });

  if (!fName || !lname || !email || !password || !password2) {
    errors.push({ message: "Please enter all fields" });
  }

  if (password.length < 6) {
    errors.push({ message: "Password must be a least 6 characters long" });
  }

  if (password !== password2) {
    errors.push({ message: "Passwords do not match" });
  }

  if (errors.length > 0) {
    res.status(400).json({ errors });
  } else {
    try {
      const hashedPassword = await bcrypt.hash(password, 10);
      console.log(hashedPassword);

      const user = await pool.query(
        `SELECT * FROM users
        WHERE email = $1`,
        [email]
      );

      console.log(user.rows);

      if (user.rows.length > 0) {
        res.status(400).json({ message: "Email already registered" });
      } else {
        const newUser = await pool.query(
          `INSERT INTO users (fName, lName, email, password, phoneNumber, dateOfBirth)
          VALUES ($1, $2, $3, $4,$5,$6)
          RETURNING id, password`,
          [fName, lname, email, hashedPassword, phone, birthday]
        );

        console.log(newUser.rows);
        res.status(201).json({ id: newUser.rows[0].id });
      }
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server Error');
    }
  }
});


app.post('/api/products', async (req, res) => {
  const { brand, pname, sellerid, price, ppicture, category } = req.body;

const base64EncodedImage = Buffer.from(ppicture, "base64"); // base64 decode işlemi ve bytea türüne dönüştürme

try {
  const newProduct = await pool.query(
    `INSERT INTO product (brand, "pname", "sellerid", price, "ppicture", category)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [brand, pname, sellerid, price, base64EncodedImage, category]
  );
  res.status(201).json(newProduct.rows[0]);
} catch (err) {
  console.error(err.message);
  res.status(500).send({ message: "Server error" });
}

  
});

app.delete('/api/products/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deletedProduct = await pool.query(
      `DELETE FROM product
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (deletedProduct.rows.length === 0) {
      return res.status(404).send({ message: "Product not found" });
    }

    res.json({ message: "Product deleted", product: deletedProduct.rows[0] });
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});

app.put('/api/products/:id', async (req, res) => {
  const { id } = req.params;
  const { brand, pname, sellerid, price, ppicture, category } = req.body;

  try {
    const updatedProduct = await pool.query(
      `UPDATE product
       SET brand = $1, "pname" = $2, "sellerid" = $3, price = $4, "ppicture" = $5, category = $6
       WHERE id = $7
       RETURNING *`,
      [brand, pname, sellerid, price, ppicture, category, id]
    );

    if (updatedProduct.rows.length === 0) {
      return res.status(404).send({ message: "Product not found" });
    }

    res.json(updatedProduct.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});

// Tüm ürünleri almak için endpoint
app.get('/api/products', async (req, res) => {
  try {
    const allProducts = await pool.query('SELECT * FROM product');
    res.json(allProducts.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});

// Bir ürünü ID'si ile almak için endpoint
app.get('/api/products/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const product = await pool.query('SELECT * FROM product WHERE id = $1', [id]);
    if (product.rowCount === 0) {
      return res.status(404).send({ message: "Product not found" });
    }
    res.json(product.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});




app.listen(3000, () => {
console.log('Server is listening on port 3000');
});