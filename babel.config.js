module.exports = function babelConfig(api) {
    api.cache(true);
    return {
        presets: ["babel-preset-expo"],
        plugins: [
            // Required for expo-router
            "expo-router/babel",
            "react-native-paper/babel",
        ],
    };
};
