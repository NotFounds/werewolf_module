import React, { Component } from 'react'
import { connect } from 'react-redux'

import RaisedButton from 'material-ui/RaisedButton'

import { doMatching } from './actions'

const mapStateToProps = ({}) => ({
})

class MatchingButton extends Component {
  constructor(props) {
    super(props)
  }

  handleClick() {
    const { dispatch } = this.props
    dispatch(doMatching())
  }

  render() {
    return (
      <RaisedButton
        primary={true}
        onClick={this.handleClick.bind(this)}
      >マッチング</RaisedButton>
    )
  }
}

export default connect(mapStateToProps)(MatchingButton)
