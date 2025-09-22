const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: 5432,
  ssl: {
    rejectUnauthorized: false,
  },
});

pool.on("connect", () => {
  console.log("connected to the db");
  createTable();
});

const createTable = () => {
  const queryText = `CREATE TABLE IF NOT EXISTS
      todos(
        id UUID PRIMARY KEY,
        text VARCHAR(128) NOT NULL,
        done BOOLEAN,
        "userId" VARCHAR(128) NOT NULL
      )`;

  pool
    .query(queryText)
    .then((res) => {
      console.log(res);
      pool.end();
    })
    .catch((err) => {
      console.log(err);
      pool.end();
    });
};

module.exports = {
  query: (text, params) => pool.query(text, params),
};
