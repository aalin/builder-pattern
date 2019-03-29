const start = require('./dist/bundle.js').default;

start({
  port: Number(process.env.PORT || 8080)
});
