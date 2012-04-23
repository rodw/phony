#---------------------------------------------------------------------
HOMEDIR         = __dirname + "/.."
IS_COFFEE       = process.argv[0].indexOf("coffee") >= 0
IS_INSTRUMENTED = (require('path')).existsSync(HOMEDIR+'/lib-cov')
LIB_DIR         = if IS_INSTRUMENTED then HOMEDIR+"/lib-cov" else HOMEDIR+"/lib"
FILE_SUFFIX     = if IS_COFFEE then ".coffee" else ".js"
PHONY_DATA      = LIB_DIR + "/phony-data"  + FILE_SUFFIX
#---------------------------------------------------------------------

class Phony
  constructor:()->

  data: require(PHONY_DATA).data

  # returns a random element of the array `a`
  re:(a)->a[Math.floor(Math.random()*a.length)]

  # returns a random integer `n` where `min` <= `n` < `max`
  # `min` and `max` are assumed to be integers
  ri:(min,max)->
    return Math.floor(@rf(min,max))

  # returns a random floating-point number `f` where `min` <= `f` < `max`
  rf:(min,max)->
    if !max?
      max = min
      min = 0
    delta = max - min
    return min + Math.random()*delta

  rb:(t=1,f=1)->(@ri(t+f) <= t)

  # roulette selection
  # Given an array `a` of frequencies (weights),
  rs:(a,b)->
    sum = 0
    for e in a
      sum += e
    val = Math.random()*sum
    for e,i in a
      val -= e
      if val <= 0
        if b?
          return b[i]
        else
          return i
    throw "Should never get here"

  options: {
    min_street_number: 10,
    max_street_number: 9999,
    street_name_prefix_frequency: 0.75,
    min_sentences_per_paragraph: 3,
    max_sentences_per_paragraph: 6
    male_female_ratio: [1,1]
  }

  surname:()=>@re(@data.NAMES_US_SURNAME)
  male_first_name:()=>@re(@data.NAMES_US_MALE)
  male_name:(opts={})=>
    return switch opts['return']
      when 'array'        then [ @male_first_name(), @surname() ]
      when 'map','object' then { first_name:@male_first_name(), surname:@surname() }
      else "#{@male_first_name()} #{@surname()}"
  female_first_name:()=>@re(@data.NAMES_US_FEMALE)
  female_name:(opts={})=>
    return switch opts['return']
      when 'array'        then [ @female_first_name(), @surname() ]
      when 'map','object' then { first_name:@female_first_name(), surname:@surname() }
      else "#{@female_first_name()} #{@surname()}"
  first_name:()=>
    if @rs(@options.male_female_ratio) == 0
      return @male_first_name()
    else
      return @female_first_name()
  name:(opts={})=>
    return switch opts['return']
      when 'array'        then [ @first_name(), @surname() ]
      when 'map','object' then { first_name:@first_name(), surname:@surname() }
      else "#{@first_name()} #{@surname()}"

  street:()=>
    str = "#{@re(@data.STREET_NAMES)} #{@re(@data.STREET_NAME_SUFFIX)}"
    if @rs([@options.street_name_prefix_frequency,1-@options.street_name_prefix_frequency]) == 0
      str = "#{@re(@data.STREET_NAME_PREFIXES)} #{str}"
    return str

  street_address:()=>"#{@ri(@options.min_street_number,@options.max_street_number+1)} #{@street()}"

  city:(opts={})=>
    if opts.state?
      return @re(Object.keys(@data.GEO.US[opts.state]))
    else
      return @re(@data.CITIES)

  state:()=>@re(@data.STATES)
  postal_code:(opts={})=>
    if opts.state? && opts.city?
      return @re(@data.GEO.US[opts.state][opts.city])
    else
      return @re(@data.POSTAL_CODES)
  zip_code:(opts)=>return @postal_code(opts)

  city_state:(opts={})=>
    state = @state()
    city = @city(state:state)
    return switch opts['return']
      when 'array'        then [ city, state ]
      when 'map','object' then { city:city, state:state }
      else "#{city} #{state}"

  city_state_zip:(opts={})=>
    state = @state()
    city = @city(state:state)
    zip = @postal_code(state:state,city:city)
    return switch opts['return']
      when 'array'        then [ city, state, zip ]
      when 'map','object' then { city:city, state:state, postal_code:zip }
      else "#{city} #{state} #{zip}"

  letter:()=>@letters(1)
  letters:(n,opts={})=>
    delim = if opts.delimiter? then opts.delimiter else ''
    letters = []
    while n > 0
      letters.push @re(@data.LETTERS)
      n -= 1
    return switch opts['return']
      when 'array' then letters
      else letters.join(delim)

  word:(opts)=>@words(1,opts)
  words:(n,opts={})=>
    words = []
    while n>0
      words.push @re(@data.MANY_WORDS)
      n -= 1
    return switch opts['return']
      when 'array' then words
      else words.join(' ')

  # TODO allow caller to specify word sources, e.g., `words()`, `words(source:"lorem")`, `words(source:"english")`, etc.

  lorem_word:(opts)=>@lorem_words(1,opts)
  lorem_words:(n,opts={})=>
    words = []
    while n>0
      words.push @re(@data.LOREM_WORDS)
      n -= 1
    return switch opts['return']
      when 'array' then words
      else words.join(' ')

  lorem_sentence:(opts)=>@lorem_sentences(1,opts)
  lorem_sentences:(n,opts={})=>
    sentences = []
    while n>0
      sentences.push @re(@data.LOREM_LINES)
      n -= 1
    return switch opts['return']
      when 'array' then sentences
      else sentences.join(' ')

  lorem_paragraph:(opts)=>@lorem_paragraphs(1,opts)
  lorem_paragraphs:(n,opts={})=>
    paragraphs = []
    while n>0
      paragraphs.push @lorem_sentences(@ri(@options.min_sentences_per_paragraph,@options.min_sentences_per_paragraph+1))
      n -= 1
    return switch opts['return']
      when 'array' then paragraphs
      else paragraphs.join(' ')

  title:(opts={})=> @_title_case(@words(@ri(1,5)+@ri(2)))
  lorem_title:(opts={})=> @_title_case(@lorem_words(@ri(1,5)+@ri(2)))

  _title_case:(str)=> # TODO make title case a little smarter, e.g., down upcase short words in the middle of the title.
    str.replace /\w\S*/g, (txt)->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

  domain_name:()=>
    domain = @rs(@data.TLD_WEIGHTS,@data.TLDS)
    if @data.SLDS[domain]?
      domain = @re(@data.SLDS[domain])
    if(@rs([1,7]) == 0)
      return "#{@word()}#{@word()}.#{domain}"
    else
      return "#{@word()}.#{domain}"

  host_name:()=>
    domain = @domain_name()
    if(@rs([2,3]) == 0)
      return "#{@re(@data.WEB_HOSTS)}.#{domain}"
    else
      return domain

  _word:()=>return @re(@data.NAMISH_WORDS)
  username:()=>
    switch @rs([6,1,1,1,3,3,3,2,2,2,1,1,1,1])
      when 0 then @_word()
      when 1 then "#{@_word()}#{@_word()}"
      when 2 then "#{@_word()}.#{@_word()}"
      when 3 then "#{@_word()}-#{@_word()}"
      when 4 then "#{@letter()}#{@_word()}"
      when 5 then "#{@letter()}.#{@_word()}"
      when 6 then "#{@letter()}-#{@_word()}"
      when 7 then "#{@letters(@ri(1,3))}#{@_word()}"
      when 8 then "#{@letters(@ri(1,3))}.#{@_word()}"
      when 9 then "#{@letters(@ri(1,3))}-#{@_word()}"
      when 10 then "#{@_word()}#{@letters(@ri(1.3))}"
      when 11 then "#{@_word()}.#{@letters(@ri(1,3))}"
      when 12 then "#{@_word()}-#{@letters(@ri(1,3))}"
      else @letters(@ri(5,16))

  email_address:()=>"#{@username()}@#{@domain_name()}"

  file_path:()=>
    path = ''
    n = @ri(1,4)
    while n > 0
      path += "/#{@word()}"
      n -= 1
    return path

  file_name:()=>
    return switch @rs([5,1])
      when 0 then "#{@word()}.#{@re(@data.FILE_EXT)}"
      else "#{@word()}"

  file_path_and_name:()=>
    return switch @rs([2,1,1])
      when 0 then "#{@file_path()}/#{@file_name()}"
      when 1 then "#{@file_path()}"
      else "#{@file_path()}/"

  uri:(opts={})=>
    schemes = if opts.schemes? then opts.schemes else [ 'http', 'http', 'http', 'http', 'http', 'https' ]
    ports = if opts.ports? then opts.ports else [ null, null, null, null, null, null, 81, 8080 ]
    uri = "#{@re(schemes)}://#{@host_name()}"
    port = @re(ports)
    if port?
      uri += ":#{port}"
    uri += @rs([3,1,1],[@file_path_and_name(),"/#{@file_name()}",'/'])
    return uri

exports.make_phony = ()->new Phony()
