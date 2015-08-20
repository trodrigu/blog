React = require 'react'
require 'react/addons'
@Aside = React.createClass
  render: ->
    React.DOM.div
      className: 'logo'
      React.DOM.a
        className: 'asdf'
        React.DOM.img({src:"img/caticorn.png"})
      React.DOM.div
        className: 'me-info'
        React.DOM.h1
          className: 'what'
          'Thomas Rodriguez'
        React.DOM.p
          className: 'dode'
          'A blog about code'

React.render(React.createElement(@Aside), document.getElementById('nav'))

