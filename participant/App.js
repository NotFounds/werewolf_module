import React, { Component } from 'react'
import { connect } from 'react-redux'

import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider'

import Wait from './Wait'
import Role from './Role'
import NameForm from './NameForm'
import Description from './Description'

const mapStateToProps = ({page}) => ({
  page
})

class App extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  componentDidMount() {
    sendData("fetch_contents")
  }

  render() {
    const { page } = this.props
    return (
      <MuiThemeProvider>
        <div>
          { (page == "name") ? <NameForm /> : null }
          { (page == "description") ? <Description /> : null }
          { (page == "wait") ? <Wait /> : null }
          { (page == "role") ? <Role /> : null }
        </div>
      </MuiThemeProvider>
    )
  }
}

export default connect(mapStateToProps)(App)
