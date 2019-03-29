import express from 'express';

export default ({ port = 8080 } = {}) => {
  const app = express();

  app.get('*', (req, res) => {
    res.send(`Hello world ${new Date().toISOString()}\n`);
  });

  app.listen(port, () => {
    console.log(`App listening to http://localhost:${port}`);
  });
}
