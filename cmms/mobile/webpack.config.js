const createExpoWebpackConfigAsync = require('@expo/webpack-config');
const webpack = require('webpack');

module.exports = async function (env, argv) {
    const config = await createExpoWebpackConfigAsync(
        {
            ...env,
            babel: {
                dangerouslyAddModulePathsToTranspile: ['@stomp/stompjs'],
            },
        },
        argv
    );

    // Define process globally for all modules
    config.plugins.push(
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
            'process.platform': JSON.stringify('web'),
            'process.version': JSON.stringify(''),
        })
    );

    // Provide process for modules that need it
    config.plugins.push(
        new webpack.ProvidePlugin({
            process: 'process/browser',
        })
    );

    // Add aliases for react-native modules that don't work on web
    config.resolve.alias = {
        ...config.resolve.alias,
        'react-native-fs': require.resolve('./mocks/react-native-fs.js'),
        'react-native-image-viewing': require.resolve('./mocks/react-native-image-viewing.js'),
    };

    return config;
};
