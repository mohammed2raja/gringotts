# Gringotts [![Build Status](https://travis-ci.org/lookout/gringotts.png?branch=master)](https://travis-ci.org/lookout/gringotts)

A collection of [real mixins][1] and utilities supporting common behaviors found
in web apps built with `Chaplin` and `Handlebars`.

Some behaviors add properties onto the mixed in class to support default or
common properties/behaviors placed on the class's parent prototypes.

Here's an example of how to use a mixin:

```
Mixin = require 'mixin'
class someModel extends Mixin Chaplin.Model
  mixinOptions: {key1: 'stuff', key2: 'moreStuff'}
```

## Getting Started

### Prerequisites

First you’ll need to make sure your system is ready for development with
Node.js. [Node Version Manager][2] lets you
manage multiple versions of Node.js. Gringotts is currently developed using
Node.js version 8.4.0. Once you've installed NVM, run the `nvm install` command.

In the future (or if you already have 8.4.0 installed), you can run `nvm use` in
the Gringotts project working directory to switch to the correct version of
Node.js.

Once you're using the correct version of node, run `npm install -g npm` to
update Node.js' package manager to the latest version. It's important to note that
npm adds executables to PATH when running the scripts defined in package.json.
There's no need to install them globally. At this point, you can install the
project's dependencies:

```
npm install
```

### Testing the project

If you start Karma with `npm start`, then the specs will run automatically when
`.coffee` files are saved. This will open up a Chrome window with an option to
run the tests in the browser via the `debug` button.

Alternatively, you can run `npm test` which will run the specs via PhantomJS and
generate code coverage reports.

### Pushing changes

Make sure to publish a new version tag. First, bump the release version using
`npm run bump:patch`, `npm run bump:minor` or `npm run bump:major`. Next, update
npm with `npm run release`. If you need to release a specific version,
use [npm version][3] directly.

[1]: http://justinfagnani.com/2015/12/21/real-mixins-with-javascript-classes
[2]: https://github.com/creationix/nvm
[3]: https://docs.npmjs.com/cli/version
