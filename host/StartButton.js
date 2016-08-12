import React, { Component } from 'react'
import { connect } from 'react-redux'

import RaisedButton from 'material-ui/RaisedButton'

import { start } from './actions'

const mapStateToProps = ({}) => ({
})

class StartButton extends Component {
  constructor(props) {
    super(props)
  }

  handleClick() {
    const { dispatch } = this.props
    dispatch(start())
  }

  render() {
    return (
      <RaisedButton
        primary={false}
        onClick={this.handleClick.bind(this)}
      >ゲーム開始</RaisedButton>
    )
  }
}

export default connect(mapStateToProps)(StartButton)
