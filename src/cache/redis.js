const { createClient } = require('redis');

const {
    REDIS_HOST: HOST,
} = process.env;


const redisClient = createClient({
    url: HOST
  });
  
const cache = async () => {
    return await redisClient.connect();
};
  
const disconnect = async (client) => {
    return await client.disconnect();
}
  
module.exports = {
    cache,
    disconnect
};
