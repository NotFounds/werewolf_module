import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Card, CardHeader, CardText } from 'material-ui/Card'

import MatchingButton from './MatchingButton'

const mapStateToProps = ({}) => ({
})

class GameControlerRoot extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  render() {
    return(
      <Card>
        <CardHeader title={"Controler"} />
        <CardText>
        <MatchingButton />
        </CardText>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(GameControlerRoot)
