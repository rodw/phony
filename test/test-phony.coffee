# # A Test Suite for Phony

# `Phony` is a tool for generating realistic-looking fake data.

# This ([mocha](http://visionmedia.github.com/mocha/)) test
# script both demonstrates and validates the use of Phony.

# The tests are written using the
# [should.js](https://github.com/visionmedia/should.js)
# assertion framework.
should = require('should')

# ## Setup

# This test script can be run in a handful of different contexts, so
# lets configure things accordingly.

# - `HOME_DIR` is the "root" directory for this project. Some of
#    our other paths will be relative to it.
HOME_DIR        = "#{__dirname}/.."
# - `IS_COFFEE` is `true` *iff* we're running in a CoffeeScript (rather
#   than JavaScript/node.js) environment.
IS_COFFEE       = process.argv[0].indexOf('coffee') >= 0
# - `IS_INSTRUMENTED` is `true` *iff* jscoverage-instrumented code is available.
IS_INSTRUMENTED = (require('path')).existsSync("#{HOME_DIR}/lib-cov")
# - `LIB_DIR` is the directory in which our source files can be found.
#   It is `lib-cov` when available, otherwise `lib`.
LIB_DIR         = if IS_INSTRUMENTED then "#{HOME_DIR}/lib-cov" else "#{HOME_DIR}/lib"
# - `FILE_SUFFIX` is `.coffee` when we're running within a CoffeeScript
#   interpreter, `.js` otherwise.
FILE_SUFFIX     = if IS_COFFEE then '.coffee' else '.js'
# - Finally, `PHONY` is the file we need to `require` (which may be in `lib`
#   or `lib-cov`, and may be a raw `.coffee` file or one that had already
#   been compiled into a `.js` file).
PHONY           = "#{LIB_DIR}/phony#{FILE_SUFFIX}"

# ## Tests

describe "Phony", ->

  # To use Phony, we simply `require` the module and initialize a new instance.
  @phony = require(PHONY).make_phony()

  # Phony can be used to generate fake data of several different types.

  # ### Generating Phony Names
  it "generates phony names", (done)->

    # Phony can generate realistic-looking person names.

    # By default these are randomly generated from the most popular
    # names in the United States.

    # `phony.name()` generates names like "Julia Ellis" or "Ron Warren":
    phony.name().should.match /^([A-Z][a-z]+)+ ([A-Z]\'?[a-z]+)+$/

    # You can also generate just first names and last names in isolation:
    phony.first_name().should.match /^([A-Z][a-z]+)+$/
    phony.surname().should.match /^([A-Z]\'?[a-z]+)+$/

    # Or male or female names specifically:
    phony.male_name().should.match /^([A-Z][a-z]+)+ ([A-Z]\'?[a-z]+)+$/
    phony.female_name().should.match /^([A-Z][a-z]+)+ ([A-Z]\'?[a-z]+)+$/
    phony.male_first_name().should.match /^([A-Z][a-z]+)+$/
    phony.female_first_name().should.match /^([A-Z][a-z]+)+$/

    # By default, the `name()` methods return strings.
    phony.name().should.be.a 'string'

    # But you can also obtain an `Array` (with the format
    # `[ firstname, surname ]`):
    pair = phony.name(return:'array')
    pair.should.be.an.instanceof Array
    pair[0].should.match /^([A-Z][a-z]+)+$/
    pair[1].should.match /^([A-Z](\'[A-Z])?[a-z]+)+$/

    # Or a map (`Object`) with the keys `first_name` and `surname`.
    map = phony.name(return:'map')
    map.should.be.an.instanceof Object
    map.first_name.should.match /^([A-Z][a-z]+)+$/
    map.surname.should.match /^([A-Z](\'[A-Z])?[a-z]+)+$/

    # This also works for `male_name` and `female_name`.
    phony.male_name(return:'string').should.be.a 'string'
    phony.male_name(return:'array').should.be.an.instanceof Array
    phony.male_name(return:'map').should.be.an.instanceof Object
    phony.male_name(return:'object').should.be.an.instanceof Object
    phony.female_name(return:'string').should.be.a 'string'
    phony.female_name(return:'array').should.be.an.instanceof Array
    phony.female_name(return:'map').should.be.an.instanceof Object
    phony.female_name(return:'object').should.be.an.instanceof Object

    done()

  # ### Generating Phony (Physical) Addresses
  it "generates phony physical addresses", (done)->

    # Phony can generate physical (postal) addresses.

    # Currently these are rather US-centric, but the infrastructure is
    # in place to support non-US addresses as well.

    # `phony.city()` returns a random city name.
    phony.city(country:'us').should.be.a 'string'
    phony.city(country:'us').should.match /^([A-Z][a-z]+)( [A-Z][a-z]+)*$/

    # `phony.state()` returns a random state name (in the two-letter
    # postal abbreviation format).
    phony.state(country:'us').should.be.a 'string'
    phony.state(country:'us').should.match /^[A-Z][A-Z]$/

    # `phony.postal_code()` generates six digit ZIP code.
    phony.postal_code(country:'us').should.be.a 'string'
    phony.postal_code(country:'us').should.match /^[0-9][0-9][0-9][0-9][0-9]$/

    # `phony.zip_code()` is an alias for `postal_code`.
    phony.zip_code().should.be.a 'string'
    phony.zip_code().should.match /^[0-9][0-9][0-9][0-9][0-9]$/

    # `phony.street()` generates a random street name such as `E Third St` or `Old Berkeley Road`.
    phony.street().should.be.a 'string'
    phony.street().should.match /^(([A-Z]|[0-9]+)[a-z]*)( (([A-Z]|[0-9]+)[a-z]*)*)*$/

    # `phony.street()` generates a street and "house number", such as
    # `1832 Drexel Court` or `5163 S Wicker Park Road`
    phony.street_address().should.be.a 'string'
    phony.street_address().should.match /^[0-9]+ (([A-Z]|[0-9]+)[a-z]*)( (([A-Z]|[0-9]+)[a-z]*)*)*$/

    # `phony.city_state()` selects a random city within a random state, such as
    # `Fairbanks AK` or `Springfield IL`
    phony.city_state(country:'us').should.be.a 'string'
    phony.city_state(country:'us').should.match /^([A-Z][a-z]+)( [A-Z][a-z]+)* [A-Z][A-Z]$/

    # By default, `phony.city_state()` returns a `String`, but you can also
    # obtain an `Array` (in the format `[ city, state ]`) or a map (`Object`)
    # (in the format `{ "city": city, "state":state }`).
    phony.city_state(return:'string').should.be.a 'string'
    phony.city_state(return:'array').should.be.an.instanceof Array
    phony.city_state(return:'map').should.be.an.instanceof Object
    phony.city_state(return:'object').should.be.an.instanceof Object

    # `phony.city_state_zip()` selects a random postal code within a random
    # city within a random state, such as `Juneau AK 99801` or `Athens AL 35613`.
    # Note that `city_state_zip` returns a valid combination. I.e., the given
    # city should exist in the given state, and the given zip code should exist
    # within the given city.
    phony.city_state_zip(country:'us').should.be.a 'string'
    phony.city_state_zip(country:'us').should.match /^([A-Z][a-z]+)( [A-Z][a-z]+)* [A-Z][A-Z] [0-9][0-9][0-9][0-9][0-9]$/

    # By default, `phony.city_state_zip()` returns a `String`, but you can also
    # obtain an `Array` (in the format `[ city, state, postal_code ]`) or a map (`Object`)
    # (in the format `{ 'city': city, 'state':state, 'postal_code':zip }`).
    phony.city_state_zip(return:'string').should.be.a 'string'
    phony.city_state_zip(return:'array').should.be.an.instanceof Array
    phony.city_state_zip(return:'map').should.be.an.instanceof Object
    phony.city_state_zip(return:'object').should.be.an.instanceof Object

    done()

  # ### Generating Phony Text Snippets

  it "generates phony text", (done)->

    # Phony can generate random text.

    # `phony.letter()` returns a single lowercase letter.
    phony.letter().should.be.a 'string'
    phony.letter().should.match /^[a-z]$/

    # `phony.letters()` returns *n* letters.
    phony.letters(5).should.be.a 'string'
    phony.letters(5).should.match /^[a-z][a-z][a-z][a-z][a-z]$/

    # By default `phony.letters()` simply concatentates
    # the selected letters with no delimiter at all.
    phony.letters(3).length.should.equal 3
    # But one can also specify an aribtrary delimiter:
    phony.letters(5,delimiter:'-').should.match /^[a-z]-[a-z]-[a-z]-[a-z]-[a-z]$/
    phony.letters(5,delimiter:' ').should.match /^[a-z] [a-z] [a-z] [a-z] [a-z]$/
    phony.letters(5,delimiter:', ').should.match /^[a-z], [a-z], [a-z], [a-z], [a-z]$/

    # `phony.lorem_word()` returns a word from the "lorem ipsum" text.
    phony.lorem_word().should.be.a 'string'
    phony.lorem_word().should.match /^[a-z]+$/

    # `phony.lorem_words()` returns *n* lorem words.
    phony.lorem_words(3).should.be.a 'string'
    phony.lorem_words(3).should.match /^[a-z]+ [a-z]+ [a-z]+$/

    # `phony.lorem_sentence()` returns a full "lorem ipsum" sentence.
    phony.lorem_sentence().should.be.a 'string'
    phony.lorem_sentence().should.match /^[A-Z][a-z]+(,? [a-z]+)+\.$/

    # `phony.lorem_sentences()` returns *n* lorem sentences.
    phony.lorem_sentences(2).should.be.a 'string'
    phony.lorem_sentences(2).should.match /^[A-Z][a-z]+(,? [a-z]+)+\. [A-Z][a-z]+(,? [a-z]+)+\.$/

    # `phony.lorem_paragraph()` returns several "lorem ipsum" sentences in a single paragraph.
    phony.lorem_paragraph().should.be.a 'string'
    # `phony.lorem_paragraphs()` returns *n* "lorem ipsum" paragraphs joined with newlines.
    phony.lorem_paragraphs(2).should.be.a 'string'

    # By default, the `phony.lorem_*()` methods return a string, but
    # one can also obtain an `Array` by specifying the rerturn format.
    phony.lorem_word(return:'array').should.be.an.instanceof Array
    phony.lorem_word(return:'array').length.should.equal 1
    phony.lorem_words(5,return:'array').should.be.an.instanceof Array
    phony.lorem_words(5,return:'array').length.should.equal 5

    # `phony.lorem_title()` generates a short "lorem ipsum" phrase in Title Case.
    phony.lorem_title().should.be.a 'string'
    phony.lorem_title().should.match /^[A-Z][a-z]+( [A-Z][a-z]+)*$/

    done()

  # ### Generating Phony (Virtual) Addresses
  it "generates phony virtual addresses", (done)->

    # Phony can generate Internet addresses of various types.

    # `phony.domain_name()` generates domain names such as
    # `lillie.org` or `griffin.ltd.uk`.
    phony.domain_name().should.be.a 'string'
    phony.domain_name().should.match /^[a-z]+(\.[a-z]+)+$/

    # `phony.host_name()` generates host names such as
    # `www.roberto.edu` or `preposterous.com`.
    # (Here, host names are domain names that sometimes, but
    # not always, have a "machine name" prefix such as "www" or "cdn".)
    phony.host_name().should.be.a 'string'
    phony.host_name().should.match /^[a-z]+(\.[a-z]+)+$/

    # `phony.username()` generates usernames such as
    # `jorge.brown` or `kkashley`.
    phony.username().should.be.a 'string'
    phony.username().should.match /^[a-z]([a-z-.]*)[a-z]+$/

    # `phony.email()` generates email addresses such as
    # `kpalmer@jordan.gov` or `ray@gray.se`.
    phony.email_address().should.be.a 'string'
    phony.email_address().should.match /^[a-z]([a-z-.]*)[a-z]+@[a-z]+(\.[a-z]+)+$/

    # `phony.uri()` generates URIs such as
    # `http://tranquillizing.edu/`,
    # `http://www.predisposition.state.md.us/gary/bolster/kimberly.doc`
    # or `http://www.crawford.edu:8080/ferguson/disaffecting/potenti/loretta.aspx`.
    phony.uri().should.be.a 'string'
    phony.uri().should.match /^https?:\/\/[a-z0-9\.\-]+(:[0-9]+)?\/([a-z0-9\.\-\/]*)$/

    done()
