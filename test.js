// Generated by CoffeeScript 1.4.0
(function() {
  var Address, address1, address2, address3, address4, address5, address6, go, q, validateAddress, validator, _;

  validator = require('./index');

  Address = validator.Address;

  _ = require('underscore');

  q = [];

  validateAddress = function(input, type) {
    return q.push([input, type]);
  };

  go = function() {
    var input, inputAddress, type, _ref;
    if (q.length) {
      _ref = q.pop(), input = _ref[0], type = _ref[1];
      inputAddress = new Address(input);
      validator.validate(inputAddress, type, function(err, validAddresses, inexactMatches) {
        console.log("input: " + (inputAddress.toString()) + " -- type: " + type);
        if (err) {
          console.log(err);
        } else {
          console.log('address: ', _.map(validAddresses, function(a) {
            return "" + (a.toString()) + " -- type: " + a.matchType;
          }));
          console.log('did you mean: ', _.map(inexactMatches, function(a) {
            return "" + (a.toString()) + " -- type: " + a.matchType;
          }));
        }
        return console.log('\n');
      });
      return setTimeout(go, 300);
    }
  };

  address1 = {
    street: '100 North Washington St',
    city: 'Boston',
    state: 'MA',
    country: 'US'
  };

  address2 = {
    street: '100 North Washington St',
    city: 'Poop',
    state: 'MA',
    country: 'US'
  };

  address3 = {
    street: '1 Shitstorm St',
    city: 'Boston',
    state: 'MA',
    country: 'US'
  };

  address4 = {
    street: '1 Main St',
    city: 'San Diego',
    state: 'CA',
    country: 'US'
  };

  address5 = {
    street: '12 proctor rd',
    state: 'Massachussetts',
    country: 'US'
  };

  address6 = {
    street: '1 Main St',
    city: 'San Diego',
    country: 'US'
  };

  console.log("********* There is a 300ms pause between requests as not to go over the API rate limit *********\n\n");

  validator.setOptions({
    countryMatch: "us"
  });

  validateAddress(address1, validator.match.unknown);

  validateAddress(address2, validator.match.unknown);

  validateAddress(address3, validator.match.unknown);

  validateAddress(address4, validator.match.unknown);

  validateAddress(address5, validator.match.unknown);

  validateAddress(address6, validator.match.unknown);

  validateAddress('100 north washington st, bostont', validator.match.unknown);

  validateAddress('100 North Washington Street, Boston, MA, US', validator.match.unknown);

  validateAddress('100 north washington st, boston, ma, us', validator.match.unknown);

  validateAddress('100 N washington st, boston, ma, us', validator.match.unknown);

  validateAddress('12 proctor rd townsend, Mass', validator.match.unknown);

  validateAddress('Boston, MA', validator.match.unknown);

  validateAddress('Boston, MA, USA', validator.match.unknown);

  validateAddress('MA', validator.match.unknown);

  validateAddress('Sibirskaya 22, Novosibirks, Russia', validator.match.unknown);

  validateAddress(address1, validator.match.streetAddress);

  validateAddress(address2, validator.match.streetAddress);

  validateAddress(address3, validator.match.streetAddress);

  validateAddress(address4, validator.match.streetAddress);

  validateAddress(address5, validator.match.streetAddress);

  validateAddress(address6, validator.match.streetAddress);

  validateAddress('100 north washington st, bostont', validator.match.streetAddress);

  validateAddress('100 North Washington Street, Boston, MA, US', validator.match.streetAddress);

  validateAddress('100 north washington st, boston, ma, us', validator.match.city);

  validateAddress('100 N washington st, boston, ma, us', validator.match.streetAddress);

  validateAddress('12 proctor rd townsend, Mass', validator.match.streetAddress);

  validateAddress('Boston, MA', validator.match.city);

  validateAddress('Boston, MA, USA', validator.match.city);

  validateAddress('US', validator.match.country);

  validateAddress('Sibirskaya 22, Novosibirks, Russia', validator.match.streetAddress);

  go();

}).call(this);
