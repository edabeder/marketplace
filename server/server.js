const express = require('express');
const bodyParser = require('body-parser');
const pg = require('pg');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());

// PostgreSQL bağlantısı için konfigürasyon objesi
const config = {
user: 'postgres',
host: 'localhost',
database: 'GeekchainDB',
password: '12345',
port: 5432, // default Postgres port
};

// PostgreSQL veritabanına bağlan
const pool = new pg.Pool(config);

// Postgresql bağlantısının başarısız olması durumunda hata mesajı ver
pool.on('error', function (err) {
console.error('idle client error', err.message, err.stack)
});

app.use(bodyParser.urlencoded({ extended: true }));

app.post('/api/users', async (req, res) => {
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
      //res.render("register", { errors, fName, lname, email, password, password2 });
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
          /*return res.render("register", {
            message: "Email already registered"
          });*/
        } else {
          const newUser = await pool.query(
            `INSERT INTO users (fName, lName, email, password, phoneNumber, dateOfBirth)
            VALUES ($1, $2, $3, $4,$5,$6)
            RETURNING id, password`,
            [fName, lname, email, hashedPassword, phone, birthday]
          );
  
          console.log(newUser.rows);
          req.flash("success_msg", "You are now registered. Please log in");
          res.redirect("/users/login");
        }
      } catch (err) {
        console.error(err.message);
      }
    }
  
});

app.listen(3000, () => {
console.log('Server is listening on port 3000');
});