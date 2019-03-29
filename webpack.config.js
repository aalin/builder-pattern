const mode = process.env.NODE_ENV === 'production' ? 'production' : 'development';

module.exports = {
  mode,

  target: 'node',

  entry: {
    bundle: './src/index.js',
  },

  output: {
    path: __dirname + '/dist',
    filename: 'bundle.js',
    libraryTarget: 'umd',
  },
};
