_ = require('underscore')
request = require('request')

###
    Address object that provides useful methods. Create a new one by
      1. passing a map with these props: {street:'123 main st', city: 'boston', state: 'MA'|'massachussetts', country: 'US'|'United States'}
        None of the props are required, but chances are you wont have a valid address if you omit any of them (except for state)
      2. passing a string containing an address (the address class does not parse the string into parts)
      3. passing a result object from a google geocoding response. ie: geoResponse.results[0]


    The validator.validate callback will return to you these objects, except they will have all or some of the following properties:
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


###
exports.Address = class Address

    constructor: (address) ->
      if _.isObject(address) #this gives you higher accuracy because we can compare resulting address parts to the input's address parts and see if its they are the same or not
        @isObject = true
        if address.address_components #the address is parsed from a response from google geocoding
          @generated = true
          location =
            lat: address.geometry?.location?.lat
            lon: address.geometry?.location?.lng

          getComponent = @componentFinder(address.address_components)
          [x, streetNum] = getComponent('street_number', false)
          [streetAbbr, street] = getComponent('route', false)
          [x, city] = getComponent('locality')
          [stateAbbr, state] = getComponent('administrative_area_level_1')
          [countryAbbr, country] = getComponent('country')
          [postalCode, x] = getComponent('postal_code', false)
          address =
            streetNumber: streetNum
            street: street
            streetAbbr: streetAbbr
            city: city
            state: state
            stateAbbr: stateAbbr
            country: country
            countryAbbr: countryAbbr
            postalCode: postalCode
            location: location

        _.each(address, (val, key) =>
            this[key] = val
        )
      else
        @isObject = false
        @addressStr = address

    componentFinder: (components) ->
        return (type, type2="political") ->
            it = _.find(components, (c) ->
                return c.types[0] == type && (!type2 || c.types[1] == type2)
            )
            return [it?.short_name, it?.long_name]

    toString: (useCountryAbbr=true, useStateAbbr=true, useStreetAbbr=false) ->
        return @addressStr if not @isObject
        arr = []
        stateVal = if useStateAbbr and @generated then 'stateAbbr' else 'state'
        countryVal = if useCountryAbbr and @generated then 'countryAbbr' else 'country'
        streetVal = if useStreetAbbr and @generated then 'streetAbbr' else 'street'
        for prop in [streetVal, 'city', stateVal, countryVal]
            arr.push(this[prop]) if this[prop]
        str = arr.join(', ')
        if @streetNumber
            str = "#{this.streetNumber} #{str}"
        return str

    equals: (address) ->
        compare = (prop) =>
            if this[prop] and address[prop]
                if this[prop].toLowerCase() == address[prop].toLowerCase()
                    return true
                if address.generated and address[prop+'Abbr']
                    return this[prop].toLowerCase() == address[prop+'Abbr'].toLowerCase()
                else if this.generated and this[prop+'Abbr']
                    return this[prop+'Abbr'].toLowerCase() == address[prop].toLowerCase()
                else
                    return false
            return !this[prop] and !address[prop]
        if @isObject and address.isObject
            return compare('city') && compare('state') && compare('country')
        else if @isObject and not address.isObject
            #address was provided as a string, and now we must check if the provided address is indeed one of the ones returned
            props = ['streetNumber', 'street', 'city', 'state', 'country', 'postalCode']
            otherAddress = address.toString().toLowerCase();

            foundProps = 0
            haveProps = 0
            find = (val) ->
                val = val.toLowerCase()
                oldlen = otherAddress.length
                otherAddress = otherAddress.replace(new RegExp("\\b"+val+"\\b"), "")
                if oldlen != otherAddress.length
                    foundProps++
                    return true
                return false

            for prop in props
                value = @[prop]
                if value != undefined
                    found = find(@[prop])
                    if not found and prop in ["state", "country", "street"] and @[prop+"Abbr"] != undefined
                        found = find(@[prop+"Abbr"])
                    if not found and prop == "country" and value.toLowerCase() == "united states"
                        found = find("usa")
                    if not found and prop == "street"
                        value = value.replace(/( street)/i, ' st')
                        found = find(value)
                        if not found
                            value = value.replace(/( road)/i, ' rd')
                            find(value)
                    haveProps++

            otherAddress = otherAddress.replace(/[ ,]/g, '')
            #console.log("found:"+foundProps+" have:"+haveProps+" left: ["+otherAddress+"]")
            return foundProps == haveProps and otherAddress.length == 0




        else
            return @toString().toLowerCase() == address.toString().toLowerCase()


###
    validate an input address.

    inputAddr: validator.Address object or map with 'street', 'city', 'state', 'country' keys, or string address
    cb: function(err, validAddresses, inexactMatches, geocodingResponse)
        err - something went wrong calling the google api
        validAddresses - list of Address objects. These are exact matches to your input, and will have proper spelling, caps etc. Its best that you use this instead of what you had
        inexactMatches - list of Address objects. Incomplete addresses or addresses that do not match your input address. useful for 'did you mean?' type UIs
        geocodingResponse - the json object that i got from google API

###
exports.validate = (inputAddr, cb) ->
    inputAddress =  if inputAddr instanceof Address then inputAddr else new Address(inputAddr)

    qs = {'sensor':false, 'address': inputAddress.toString()}

    opts =
        json: true,
        url: "http://maps.googleapis.com/maps/api/geocode/json"
        method: 'GET'
        qs: qs

    request(opts, (err, response, body) ->
        return cb(err, null, null) if err
            if body.results.length == 0
                return cb(null, [], [], body)
            if response.statusCode != 200
                return cb(new Error('Google geocode API returned status code of #{response.statusCode}', [], [], body))

            validAddresses = []
            inexactMatches = []
            _.each(body.results, (result) ->
                address = new Address(result)

                if address.equals(inputAddress)
                    validAddresses.push(address)
                else
                    inexactMatches.push(address)

            )
            cb(null, validAddresses, inexactMatches, body)

    )
