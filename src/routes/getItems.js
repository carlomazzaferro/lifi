const db = require('../persistence');
const cache = require('../cache');


module.exports = async (req, res) => {
    let items = {};
    const client  = await cache.cache();
    try {
        items = await client.get('items');
        if (items) {
            console.log('using cached items');
            items = res.json(JSON.parse(items));
            await client.set('items', JSON.stringify(items));
        } else {
            items = await db.getItems();  
        }
    } catch (err) {
        console.error(err);
    }
    try {
        await cache.disconnect(client);
    } catch (err) {
        console.error(err);
    }
    res.send(items);
};
