# SPOT [<img src="https://secure.travis-ci.org/fujimura/spot.png"/>](http://travis-ci.org/fujimura/spot)

## What is this?

An example web application with [scotty](https://github.com/xich/scotty), [persistent](https://github.com/yesodweb/persistent) and [hspec](https://github.com/hspec/hspec)


## How to run

    $ coffee -c -o static coffee/
    $ cabal-dev install
    $ cabal-dev configure && cabal-dev build
    $ ghci
    > Migrate.run
    > main

## Compiling CoffeeScript continuously

    $ coffee -c -o static --watch coffee/

## Libraries
* scotty [github](https://github.com/xich/scotty) [hackage](http://hackage.haskell.org/package/scotty)
* hastache [github](https://github.com/lymar/hastache) [hackage](http://hackage.haskell.org/package/hastache)
* persistent [github](https://github.com/yesodweb/persistent) [hackage](http://hackage.haskell.org/package/persistent)
* hspec [hspec](https://github.com/hspec/hspec)
* gmaps.js [github](https://github.com/hpneo/gmaps) [site](http://hpneo.github.com/gmaps/)

## External APIs
* Google Maps JavaScript API V3 [site](https://developers.google.com/maps/documentation/javascript/?hl=ja)
