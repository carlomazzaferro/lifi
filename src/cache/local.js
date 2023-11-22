const cache = async () => {
    const map = new Map();
    return map
};
  
const disconnect = async (map) => {
    return  map.clear()
}

module.exports = {
    cache,
    disconnect
};
