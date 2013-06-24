address-validator
======================


Validate street addresses in nodejs using google geocoding api.

From an input address the lib will return to you a valid address with correct spelling and lat/lon coords, and/or a set of inexact matches that can be used to drive a 'did you mean?' widget.

Currently geared towards North American Addresses.

Install
-------
npm install address-validator

[on npm registry](https://npmjs.org/package/address-validator)

Using
-----


```
var addressValidator = require('address-validator');
var Address = addressValidator.Address;
var _ = require('underscore');

//any of the props in this object are optional, also spelling does not have to be exact.
var address = new Address({
    street: '100 North Washington St',
    city: 'Bostont',
    state: 'Mass',
    country: 'US'
});

//the passed in address does not need to be an address object it can be a string. (address objects will give you a better likelihood of finding an exact match)
address = '100 North Washington St, Boston, MA, US';

addressValidator.validate(address, function(err, exact, inexact){
    console.log('input: ', address.toString())
    console.log('match: ', _.map(exact, function(a) {
      return a.toString();
    }));
    console.log('did you mean: ', _.map(inexact, function(a) {
      return a.toString();
    }));

    //access some props on the exact match
    var first = exact[0];
    console.log(first.streetNumber + ' '+ first.street);
});

```

Some example inputs/outputs from above:

```
input:  12 proctor rd, Massachussetts, US
exact:  []
did you mean:  [ '12 Proctor Road, Chelmsford, MA, US',
  '12 Proctor Road, Townsend, MA, US',
  '12 Proctor Road, Braintree, MA, US',
  '12 Proctor Road, Everett, MA, US',
  '12 Proctor Road, Falmouth, MA, US' ]


input:  100 North Washington St, Boston, MA, US
exact:  [ '100 North Washington Street, Boston, MA, US' ]
did you mean:  []


input:  1 Main St, San Diego, US
address:  []
did you mean:  [ '1 Main Street, San Diego, CA, US' ]

```


API
=======

    addressValidator = require('address-validator');

    addressValidator.validate
    -------------------------

    validate an input address.

    inputAddr: validator.Address object or map with 'street', 'city', 'state', 'country' keys, or string address
    cb: function(err, validAddresses, inexactMatches, geocodingResponse)
        err - something went wrong calling the google api
        validAddresses - list of Address objects. These are exact matches to your input, and will have proper spelling, caps etc. Its best that you use this instead of what you had
        inexactMatches - list of Address objects. Incomplete addresses or addresses that do not match your input address. useful for 'did you mean?' type UIs
        geocodingResponse - the json object that i got from google API

    addressValidator.Address
    ------------------------

    Address object that provides useful methods. Create a new one by passing a map with these props: {street:'123 main st', city: 'boston', state: 'MA'|'massachussetts', country: 'US'|'United States'}
    None of the props are required, but chances are you wont have a valid address if you omit any of them (except for state)

    The validate callback will return to you these objects, except they will have all or some of the following properties:
        streetNumber: '100'
        street: 'North Main St'
        streetAbbr: 'N Main St'
        city: 'Boston'
        state: 'Massachussetts'
        stateAbbr: 'MA'
        country: 'United States'
        countryAbbr: 'US'
        postalCode: 02114
        location: {lat: 43.233332, lon: 23.2222243}

    Methods:
        toString(useCountryAbbr, useStateAbbr, useStreetAbbr) - returns a string representing the address. currently geared towards North American addresses
            useCountryAbbr = [optional] default: true - the resulting address string should use country abbr, not the full country name
            useStateAbbr   = [optional] default: true - the resulting address string should use state abbr, not the full state name
            useStreetAbbr  = [optional] default: false - the resulting address string should use street name abbr, not the full street name
            Note: the abbriviated values will only be used if they are available. The Address objects returned to you from the validate callback may have these available.
        equals(anotherAddress) - check if 2 addresses are probably* the same. IT DOES NOT CHECK STREET NAME/NUMBER

