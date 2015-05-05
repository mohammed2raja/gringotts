# Gringotts

A collection of [functional mixins](http://javascriptweblog.wordpress.com/2011/05/31/a-fresh-look-at-javascript-mixins/)
and utilities supporting common behaviors found in web apps built with `Chaplin` and `Handlebars`.

Several behaviors take advantage of [aspect-oriented programming](http://en.wikipedia.org/wiki/Aspect-oriented_programming) (AOP)
with [Flight's advice component](https://github.com/flightjs/flight/blob/master/doc/advice_api.md).

Some behaviors add properties onto the mixed in object to support
default or common properties/behaviors placed on the object's parent prototypes.

Here's an example of how to use a mixin:

```
mixin = require 'mixin'
chaplinObj = {}
mixin.call chaplinObj, {key1: 'stuff', key2: 'moreStuff'}
```

The first argument is the object the behavior is being added to. The second argument is an optional configuration object.

When used within a view or collection definition `chaplinObj` above will generally be `@prototype`.

The mixins can be used classically (via `_.extend`) by invoking them as a constructor
(with `new`).

Most of the mixins involving collections expect the payload to be nested (**e.g.** `{"count": 100, "items": [{...}]}`)
so views using them are intended to be paginated. The behaviors have been broken out so they can be used separately
or together. You can also specify and override properties on collections.

For more information, see the [docs](https://github.com/pages/lookout/gringotts/).

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
