validator = require('./index')
Address = validator.Address
_ = require('underscore')

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

q = []
validateAddress = (input) ->
    q.push(input)

go = -> #this is prevents us from going over the rate limit
  if q.length
    input = q.pop()
    inputAddress = new Address(input)
    validator.validate(inputAddress, (err, validAddresses, inexactMatches) ->
      console.log('input: ', inputAddress.toString())
      if err
        console.log(err)
      else
        console.log('address: ', _.map(validAddresses, (a) -> a.toString()))
        console.log('did you mean: ', _.map(inexactMatches, (a) -> a.toString()))
      console.log('\n')
    )
    setTimeout(go, 300)

console.log("********* There is a 300ms pause between requests as not to go over the API rate limit *********\n\n")
validateAddress(address1)
validateAddress(address2)
validateAddress(address3)
validateAddress(address4)
validateAddress(address5)
validateAddress(address6)

validateAddress('100 north washington st, bostont');
validateAddress('100 North Washington Street, Boston, MA, US');
validateAddress('100 north washington st, boston, ma, us');
validateAddress('100 N washington st, boston, ma, us');

validateAddress('12 proctor rd townsend, Mass')
validateAddress('Boston, MA')
validateAddress('Boston, MA, USA')
validateAddress('MA')
validateAddress('Sibirskaya 22, Novosibirks, Russia')

go() 