import React, { Component } from 'react'
import { connect } from 'react-redux'

import Divider from 'material-ui/Divider'
import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'

const mapStateToProps = ({ result }) => ({
  result
})

class Result extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  render() {
    const { result } = this.props
    return (
      <Card>
        <CardTitle title="人狼" subtitle="結果"/>
          <CardText>
          </CardText>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(Result)
