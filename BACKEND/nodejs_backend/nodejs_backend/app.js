var createError = require('http-errors');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var cors = require('cors')

const {config} = require("dotenv");
config();

var app = express();
app.use(cors());
app.use(bodyParser.json());

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 5000);
  res.render('error');
});

const cart_item = Schema({
  id: Number,
  productId: String,
  productName: String,
  initPrice: mongoose.Types.Decimal128,
  productPrice: mongoose.Types.Decimal128,
  size: Number,
  ValueNotifier<int>? quantity: ,
  unitTag: String,
  image: String,
  productStatus: String
});

// getting cart items
app.get(function() {
  init = ;
});

app.post({
  ;
});

app.update();

// deleting cart items
app.delete({
  ;
});

mongoose.connect();

const PORT = process.env.PORT || 5000;

module.exports = app;
