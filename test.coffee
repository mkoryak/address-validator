validator = require('./index')
Address = validator.Address
_ = require('underscore')

q = []
validateAddress = (input, type) ->
  q.push([input, type])

go = -> #this is prevents us from going over the rate limit
  if q.length
    [input, type] = q.pop()
    inputAddress = new Address(input)
    validator.validate(inputAddress, type, (err, validAddresses, inexactMatches) ->
      console.log("input: #{inputAddress.toString()} -- type: #{type}")
      if err
        console.log(err)
      else
        console.log('address: ', _.map(validAddresses, (a) -> 
          "#{a.toString()} -- type: #{a.matchType}"
        ))
        console.log('did you mean: ', _.map(inexactMatches, (a) ->
          "#{a.toString()} -- type: #{a.matchType}"
        ))
      console.log('\n')
    )
    setTimeout(go, 300)
    

address1 =
    street: '100 North Washington St'
    city: 'Boston'
    state: 'MA'
    country: 'US'

address2 =
    street: '100 North Washington St'
    city: 'Poop'
    state: 'MA'
    country: 'US'

address3 =
    street: '1 Shitstorm St'
    city: 'Boston'
    state: 'MA'
    country: 'US'


address4 =
    street: '1 Main St'
    city: 'San Diego'
    state: 'CA'
    country: 'US'

address5 =
    street: '12 proctor rd'
    state: 'Massachussetts'
    country: 'US'


address6 =
    street: '1 Main St'
    city: 'San Diego'
    country: 'US'

console.log("********* There is a 300ms pause between requests as not to go over the API rate limit *********\n\n")
validator.setOptions(
  countryMatch: "us" #all results must be from the US. 
)
validateAddress(address1, validator.match.unknown)
validateAddress(address2, validator.match.unknown)
validateAddress(address3, validator.match.unknown)
validateAddress(address4, validator.match.unknown)
validateAddress(address5, validator.match.unknown)
validateAddress(address6, validator.match.unknown)

validateAddress('100 north washington st, bostont', validator.match.unknown);
validateAddress('100 North Washington Street, Boston, MA, US', validator.match.unknown);
validateAddress('100 north washington st, boston, ma, us', validator.match.unknown);
validateAddress('100 N washington st, boston, ma, us', validator.match.unknown);

validateAddress('12 proctor rd townsend, Mass', validator.match.unknown)
validateAddress('Boston, MA', validator.match.unknown)
validateAddress('Boston, MA, USA', validator.match.unknown)
validateAddress('MA', validator.match.unknown)
validateAddress('Sibirskaya 22, Novosibirks, Russia', validator.match.unknown)

## now lets mix it up by giving the validator info about the type of an address we asked to validate:
validateAddress(address1, validator.match.streetAddress)
validateAddress(address2, validator.match.streetAddress)
validateAddress(address3, validator.match.streetAddress)
validateAddress(address4, validator.match.streetAddress)
validateAddress(address5, validator.match.streetAddress)
validateAddress(address6, validator.match.streetAddress)

    
validateAddress('100 north washington st, bostont', validator.match.streetAddress);
validateAddress('100 North Washington Street, Boston, MA, US', validator.match.streetAddress);
validateAddress('100 north washington st, boston, ma, us', validator.match.city);
validateAddress('100 N washington st, boston, ma, us', validator.match.streetAddress);

    
validateAddress('12 proctor rd townsend, Mass', validator.match.streetAddress)
validateAddress('Boston, MA', validator.match.city)
validateAddress('Boston, MA, USA', validator.match.city)
validateAddress('US', validator.match.country)
validateAddress('Sibirskaya 22, Novosibirks, Russia', validator.match.streetAddress)

go() 