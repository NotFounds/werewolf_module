import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Card, CardHeader, CardText } from 'material-ui/Card'

import RoleSetting from './RoleSetting'
import MatchingButton from './MatchingButton'

const mapStateToProps = ({}) => ({
})

class GameSettingRoot extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  render() {
    return(
      <Card>
        <CardHeader
          title={"Setings"}
          actAsExpander={true}
          showExpandableButton={true}
        />
        <CardText expandable={true}>
        <RoleSetting />
        </CardText>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(GameSettingRoot)
