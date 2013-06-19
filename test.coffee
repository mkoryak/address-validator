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

validateAddress = (input) ->
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

validateAddress(address1)
validateAddress(address2)
validateAddress(address3)
validateAddress(address4)
validateAddress(address5)
validateAddress(address6)
validateAddress('12 proctor rd townsend Mass')
validateAddress('100 north washington st, bostont')