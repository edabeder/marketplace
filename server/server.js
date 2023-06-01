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
}

// PostgreSQL veritabanına bağlan
const pool = new pg.Pool(config);

// Postgresql bağlantısının başarısız olması durumunda hata mesajı ver
pool.on('error', function (err) {
console.error('idle client error', err.message, err.stack)
});

let globalUserId = null;

app.use(bodyParser.urlencoded({ extended: true }));

app.post('/api/login', async (req, res) => {
  let { email, password } = req.body;

  try {
    const customer = await pool.query(
      `SELECT * FROM customer
      WHERE email = $1`,
      [email]
    );

    const seller = await pool.query(
      `SELECT * FROM seller
      WHERE email = $1`,
      [email]
    );

    let user = null;
    let customerId = null;

    if (customer.rows.length > 0) {
      user = customer.rows[0];
      customerId = user.id;
    } else if (seller.rows.length > 0) {
      user = seller.rows[0];
      // Eğer seller tablosunda da bir customerid sütunu varsa,
      // o sütunu da customerId değişkenine atayabilirsiniz.
      customerId = user.customerid;
    }

    if (!user) {
      return res.status(401).send({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).send({ message: "Invalid email or password" });
    }

    // Kullanıcının kimlik doğrulaması başarılı oldu, bir oturum oluşturabilir
    req.session.user = user.id;
    globalUserId = user.id;

    // customerId'ı yanıt olarak gönderebilirsiniz
    res.status(200).send({ message: "Login successful", customerId: customerId });
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});

app.get('/api/get-global-user-id', (req, res) => {
  // globalUserId'yi döndür
  res.status(200).send({ customerId: globalUserId });
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

app.get('/api/isUserSeller/:email', async (req, res) => {
  const { email } = req.params;
  try {
    const result = await pool.query(
      `SELECT * FROM seller WHERE email = $1`,
      [email]
    );
    if (result.rows.length === 0) {
      res.status(200).send({ isSeller: false });
    } else {
      res.status(200).send({ isSeller: true });
    }
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});

app.get('/api/customerIdByEmail', async (req, res) => {
  const { email } = req.query;

  try {
    // E-posta adresine göre müşteri kimliğini veritabanından alın
    const customerId = await pool.query(
      `SELECT customerid FROM customer
      WHERE email = $1`,
      [email]
    );

    res.status(200).send({ customerId });
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});


app.get('/api/history/:customerId', async (req, res) => {
  const { customerId } = req.params;

  try {
    const history = await pool.query(
      `SELECT * FROM history
      WHERE customerid = $1`,
      [customerId]
    );

    console.log(history.rows); // Konsol çıktısı
    console.log(customerId);

    res.status(200).send(history.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: "Server error" });
  }
});


app.post('/api/register', async (req, res) => {
  let {fname, lname, email, password, password2, phonenumber, dateofbirth, isseller} = req.body;

  let errors = [];

  console.log({
    fname,
    lname,
    email,
    password,
    password2,
    phonenumber,
    dateofbirth,
    isseller
  });

  if (!fname || !lname || !email || !password || !password2) {
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
        `SELECT * FROM customer
        WHERE email = $1`,
        [email]
      );

      console.log(user.rows);

      if (user.rows.length > 0) {
        res.status(400).json({ message: "Email already registered" });
      } else {
        if (isseller === 'Seller') {
          const newSeller = await pool.query(
            `INSERT INTO seller (fname, lname, email, password, phonenumber, dateofbirth)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, password`,
            [fname, lname, email, hashedPassword, phonenumber, dateofbirth]
          );
          console.log(newSeller.rows);
          res.status(201).json({ id: newSeller.rows[0].id });
        } else {
          const newCustomer = await pool.query(
            `INSERT INTO customer (fname, lname, email, password, phonenumber, dateofbirth)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, password`,
            [fname, lname, email, hashedPassword, phonenumber, dateofbirth]
          );
          console.log(newCustomer.rows);
          res.status(201).json({ id: newCustomer.rows[0].id });
        }
      }
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server Error');
    }
  }
});


app.post('/api/products', async (req, res) => {
  const { brand, pname, sellerid, productprice, ppicture, category } = req.body;

//const base64EncodedImage = Buffer.from(ppicture, "base64"); // base64 decode işlemi ve bytea türüne dönüştürme

try {
  const newProduct = await pool.query(
    `INSERT INTO product (brand, "pname", "sellerid", productprice, "ppicture", category)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [brand, pname, sellerid, productprice, ppicture, category]
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
  const { brand, pname, sellerid, productprice, ppicture, category } = req.body;

  try {
    const updatedProduct = await pool.query(
      `UPDATE product
       SET brand = $1, "pname" = $2, "sellerid" = $3, productprice
 = $4, "ppicture" = $5, category = $6
       WHERE id = $7
       RETURNING *`,
      [brand, pname, sellerid, productprice
, ppicture, category, id]
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

// Arama işlemini yapacak endpoint
app.get('/api/products/search/:query', async (req, res) => {
  try {
    const searchQuery = req.params.query;
    const searchResults = await pool.query(
      'SELECT * FROM product WHERE brand LIKE $1 OR "pname" LIKE $1',
      [`%${searchQuery}%`]
    );
    res.json(searchResults.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send({ message: 'Server error' });
  }
});

app.listen(3000, () => {
console.log('Server is listening on port 3000');
});