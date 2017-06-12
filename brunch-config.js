exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: 'js/app.js'
    },
    stylesheets: {
      joinTo: 'css/app.css',
      order: {
        after: ['web/static/css/app.css'] // concat app.css last
      }
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    assets: /^(web\/static\/assets)/,
    ignored: /^(web\/client\/elm-stuff)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      'web/static',
      'web/client',
      'test/static'
    ],

    // Where to compile files to
    public: 'priv/static'
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    elmBrunch: {
      elmFolder: 'web/client',
      mainModules: ['Main.elm'],
      outputFolder: '../static/js'
    }
  },

  modules: {
    autoRequire: {
      'js/app.js': ['web/static/js/app']
    }
  },

  npm: {
    enabled: true
  }
}
