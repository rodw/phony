# phony

A fake data generator in JavaScript/CoffeeScript.

# Installing Phony

To install Phony with [NPM](http://npmjs.org/), use:

        > npm install phony

or add a dependency such as:

        "dependencies" : {
          "phony" : "latest"
        }

to your `package.json` file and run `npm install`.

# Using Phony

The `phony` module exports a simple factory method, which you can use as follows:

        // JavaScript
        var phony = require('phony').make_phony(); 

or

        # CoffeeScript
        phony = require('phony').make_phony()

You can then use `phony` to generate a wide variety of fake data.

## Names

        coffee> phony.name()
        'Sylvia Robinson'
        
        coffee> phony.first_name()
        'Deborah'
        
        coffee> phony.surname()
        'Sanchez'
        
        coffee> phony.male_name()
        'Brett Foster'
        
        coffee> phony.female_name()
        'Gina Holmes'
        
        coffee> phony.name(return:'map')
        { first_name: 'Steve', surname: 'Stephens' }
        
        coffee> phony.name(return:'array')
        [ 'Darlene', 'Clark' ]
        
        coffee> phony.male_name(return:'map')
        { first_name: 'Adam', surname: 'Watts' }


## Places

        coffee> phony.street()
        'Old Gordon Court'
        
        coffee> phony.street()
        'S Hermosa Drive'
        
        coffee> phony.street_address()
        '8172 South Ontario Circle'
        
        coffee> phony.postal_code()
        '27101'
        
        coffee> phony.zip_code()
        '40206'
        
        coffee> phony.city()
        'Yonkers'
        
        coffee> phony.city()
        'Hamden'
        
        coffee> phony.state()
        'DE'
        
        coffee> phony.state()
        'MA'
        
        coffee> phony.city_state()
        'Indianapolis IN'
        
        coffee> phony.city_state_zip()
        'East Hartford CT 06108'

        coffee> phony.city_state_zip(return:"map")
        { city: 'Grand Forks',
          state: 'ND',
          postal_code: '58203' }

## Text
       
        coffee> phony.letters(4)
        'ecaa'
        
        coffee> phony.letters(4,delimiter:' ')
        'f t e b'
        
        coffee> phony.letters(4,delimiter:'-')
        'r-e-v-o'
        
        coffee> phony.letters(4,delimiter:', ')
        'l, d, t, w'
       
        coffee> phony.word()
        'weekended'
        
        coffee> phony.lorem_word()
        'nunc'
        
        coffee> phony.words(10)
        'disquiets lance porta allotments jack nonprofessionals contributor 
        changing kristen catastrophe'
        
        coffee> phony.lorem_words(10)
        'fusce malesuada laoreet sed massa mi nullam vivamus nullam ut'
        
        coffee> phony.lorem_words(10)
        'sem dui cum id magnis enim penatibus et dignissim odio'
        
        coffee> phony.title()
        'Bayberry Butler Rosemary'
        
        coffee> phony.title()
        'Tamara Ulna'
        
        coffee> phony.lorem_title()
        'Feugiat Nisl Libero Risus'

        coffee> phony.lorem_sentence()
        'Proin neque massa, cursus ut, gravida ut, lobortis eget, lacus.'
        
        coffee> phony.lorem_sentences(2)
        'Phasellus purus. Nullam libero mauris, consequat quis, varius et, 
        dictum id, arcu.'

        coffee> phony.lorem_sentences(5,return:"array")
        [ 'Nullam libero mauris, consequat quis, varius et, dictum id, arcu.',
          'Sed bibendum.',
          'Donec hendrerit tempor tellus.',
          'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.',
          'Nulla posuere.' ]
       
        coffee> phony.lorem_paragraph()
        'Phasellus purus. Nam vestibulum accumsan nisl. Nunc porta vulputate
        tellus.'

        coffee> phony.lorem_paragraphs(2)
        'Donec vitae dolor. Proin neque massa, cursus ut, gravida ut, lobortis 
        eget, lacus. Phasellus lacus. Praesent augue. Proin neque massa, 
        cursus ut, gravida ut, lobortis eget, lacus. Praesent fermentum 
        tempor tellus.'
        
        coffee> phony.lorem_paragraphs(3,return:"array")
        [ 'Integer placerat tristique nisl. Fusce commodo. Phasellus at dui 
          in ligula mollis ultricies.',
          'Nunc porta vulputate tellus. Fusce sagittis, libero non molestie 
          mollis, magna orci ultrices dolor, at vulputate neque nulla lacinia 
          eros. Praesent augue.',
          'Nulla posuere. In id erat non orci commodo lobortis. Pellentesque 
          dapibus suscipit ligula.' ]

## Internet

        coffee> phony.domain_name()
        'avior.nhs.uk'

        coffee> phony.domain_name()
        'continuing.mobi'

        coffee> phony.domain_name()
        'gonzales.com'

        coffee> phony.host_name()
        'underestimate.edu'

        coffee> phony.host_name()
        'unemployable.areo'
        
        coffee> phony.host_name()
        'cdn.maniacal.gov.uk'

        coffee> phony.host_name()
        'www.vulputate.org'
        
        coffee> phony.username()
        'n.lane'
        
        coffee> phony.username()
        'zreid'
        
        coffee> phony.username()
        'yz-wallace'

        coffee> phony.email_address()
        'a.michelle@elit.edu'
        
        coffee> phony.email_address()
        'myers@jaggedly.com'

        coffee> phony.file_name()
        'boastfulness.zip'
        
        coffee> phony.file_name()
       'apparel.doc'
        
        coffee> phony.file_name()
        'nancy.txt'

        coffee> phony.file_path()
        '/terry/huskies/bower'
        
        coffee> phony.file_path()
        '/volleyball/chavez'
        
        coffee> phony.file_path()
        '/warren'
        
        coffee> phony.file_path_and_name()
        '/lillian/harold'
        
        coffee> phony.file_path_and_name()
        '/betty/frances/aloud.ppt'
        
        coffee> phony.file_path_and_name()
        '/barnett/norma/pronghorns/boyd.aspx'
        
        coffee> phony.uri()
        'http://aerie.com/romero/manacle/'
        
        coffee> phony.uri()
        'https://oliver.mil/engorging'

        coffee> phony.uri()
        'http://william.org:8080/celebrities/sam/robert'

        coffee> phony.uri()
        'http://www2.hansontuareg.org/natalie/'

# Note

This module is developed following the [git-flow](https://github.com/nvie/gitflow) workflow/branching model.

The default [master](https://github.com/rodw/phony) branch only contains the released versions of the code and hence may seem relatively stagnant (or stable, depending upon your point of view).

Most of the develop action happens on the [develop](https://github.com/rodw/phony/tree/develop) branch or in feature branches.
