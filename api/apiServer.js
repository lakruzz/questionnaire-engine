require('dotenv').load();
import express from 'express';
import bodyParser from 'body-parser'
import formsAPI from './controllers/formsAPI'
import resultsAPI from './controllers/resultsAPI'
import db from './config/dbConnection'
const cors = require('cors');

const port = process.env.PORT || 3030;
const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use('/api/forms', formsAPI);
app.use('/api/results', resultsAPI)


db.connect(function (err) {
  if (err) {
    console.log("Could not connect to Database");
    return 1;
  }
});

app.listen(port, function(err) {
  if (err) {
    console.log(err);
  } else {
    console.log('API server started on port ' + port);
  }
});

