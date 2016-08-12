import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'

const mapStateToProps = ({}) => ({
})

class Destroied extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  render() {
    return (
      <Card>
        <CardTitle title="人狼" subtitle="廃村"/>
          <CardText>
          <p>村は廃村が決定しました。</p><br />
          <p>ゲームを終了します。</p>
          </CardText>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(Destroied)
