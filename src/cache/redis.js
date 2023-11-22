const { createClient } = require('redis');

const {
    REDIS_HOST: HOST,
} = process.env;


const redisClient = createClient({
    url: HOST
  });
  
  
  
module.exports = {
    redisClient
};
