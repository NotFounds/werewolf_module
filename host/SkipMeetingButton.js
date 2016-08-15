import React, { Component } from 'react'
import { connect } from 'react-redux'

import RaisedButton from 'material-ui/RaisedButton'

import { skip } from './actions'

const mapStateToProps = ({ mode }) => ({
  mode
})

class SkipMeetingButton extends Component {
  constructor(props) {
    super(props)
  }

  handleClick() {
    const { dispatch } = this.props
    dispatch(skip())
  }

  render() {
    const { mode } = this.props
    let disabled = (mode != "meeting")
    return (
      <RaisedButton
        disabled={disabled}
        secondary={true}
        onClick={this.handleClick.bind(this)}
      >話し合い終了</RaisedButton>
    )
  }
}

export default connect(mapStateToProps)(SkipMeetingButton)
