const db = require('../persistence');
const cache = require('../cache');



module.exports = async (req, res) => {
    let items = {};
    await cache.redisClient.connect();
    try {
        items = await cache.redisClient.get('items');
        if (items) {
            console.log('using cached items');
            items = res.json(JSON.parse(items));
            await cache.redisClient.set('items', JSON.stringify(items));
        } else {
            items = await db.getItems();  
        }
    } catch (err) {
        console.error(err);
    }
    res.send(items);
    await cache.redisClient.disconnect();
};
