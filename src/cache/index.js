if (process.env.REDIS_HOST) module.exports = require('./redis');
else module.exports = require('./local');
