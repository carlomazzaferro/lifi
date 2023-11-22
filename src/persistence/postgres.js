const waitPort = require('wait-port');
const fs = require('fs');
const { Client } = require('pg');

const {
    POSTGRES_HOST: HOST,
    POSTGRES_USER: USER,
    POSTGRES_PASSWORD: PASSWORD,
    POSTGRES_DB: DB,
} = process.env;

let client;

async function init() {
    await waitPort({ 
        host: HOST, 
        port: 5432,
        timeout: 10000,
        waitForDns: true,
    });
    console.log({
      HOST,
      USER,
      PASSWORD,
      DB,
    })
    
    client = new Client({
        host: HOST,
        user: USER,
        password: PASSWORD,
        database: DB
    });

    return client.connect().then(async () => {
        console.log(`Connected to postgres db at host ${HOST}`);
        // Run the SQL instruction to create the table if it does not exist
        await client.query('CREATE TABLE IF NOT EXISTS todo_items (id varchar(36), name varchar(255), completed boolean)');
        console.log('Connected to db and created table todo_items if it did not exist');
    }).catch(err => {
        console.error('Unable to connect to the database:', err);
    });
}

// Get all items from the table
async function getItems() {
  return client.query('SELECT * FROM todo_items').then(res => {
    return res.rows.map(row => ({
      id: row.id,
      name: row.name,
      completed: row.completed
    }));
  }).catch(err => {
    console.error('Unable to get items:', err);
  });
}


// End the connection
async function teardown() {
  return client.end().then(() => {
    console.log('Client ended');
  }).catch(err => {
    console.error('Unable to end client:', err);
  });
}
  
// Get one item by id from the table
async function getItem(id) {
    return client.query('SELECT * FROM todo_items WHERE id = $1', [id]).then(res => {
      return res.rows.length > 0 ? res.rows[0] : null;
    }).catch(err => {
      console.error('Unable to get item:', err);
    });
}
  
// Store one item in the table
async function storeItem(item) {
    return client.query('INSERT INTO todo_items(id, name, completed) VALUES($1, $2, $3)', [item.id, item.name, item.completed]).then(() => {
      console.log('Stored item:', item);
    }).catch(err => {
      console.error('Unable to store item:', err);
    });
}
  
  
module.exports = {
  init,
  teardown,
  getItems,
  getItem,
  storeItem,
};
