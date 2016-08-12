import React, { Component } from 'react'
import { connect } from 'react-redux'

import RaisedButton from 'material-ui/RaisedButton'

import { destroy } from './actions'

const mapStateToProps = ({}) => ({
})

class DestroyButton extends Component {
  constructor(props) {
    super(props)
  }

  handleClick() {
    const { dispatch } = this.props
    dispatch(destroy())
  }

  render() {
    return (
      <RaisedButton
        secondary={true}
        onClick={this.handleClick.bind(this)}
      >廃村にする</RaisedButton>
    )
  }
}

export default connect(mapStateToProps)(DestroyButton)
