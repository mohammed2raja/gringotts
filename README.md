# Gringotts [![Build Status](https://travis-ci.org/lookout/gringotts.png?branch=master)](https://travis-ci.org/lookout/gringotts)

A collection of [real mixins](http://justinfagnani.com/2015/12/21/real-mixins-with-javascript-classes/)
and utilities supporting common behaviors found in web apps built with `Chaplin` and `Handlebars`.

Some behaviors add properties onto the mixed in class to support
default or common properties/behaviors placed on the class's parent prototypes.

Here's an example of how to use a mixin:

```
Mixin = require 'mixin'
class someModel extends Mixin Chaplin.Model
  mixinOptions: {key1: 'stuff', key2: 'moreStuff'}
```

For more information, see the [docs](http://hackers.lookout.com/gringotts/).

## Getting Started

### Installation

If you've never installed or used `npm` or `bower`, you can skip the associated `cache` commands.

```
npm cache clear
bower cache clean
npm install
bower install
```

### Testing the project

If you start `grunt`, then the specs will run automatically when `.coffee` files are saved.

Alternatively, you can run `grunt test` which will run the specs via PhantomJS and generate code coverage reports.

Visit [localhost:8000](http://localhost:8000) to debug the tests in a browser.

### Local docs

You can view docs locally at [localhost:8000/docs/](http://localhost:8000/docs/)

### Pushing changes

After making a change, please remember to update the docs with `grunt docs`.

Also, make sure to publish a new version tag with `grunt release` so projects can retrieve the change.
The `release` task takes the same options as the `bump` task (`release:minor`, `release:major`) and defaults to a patch release.
