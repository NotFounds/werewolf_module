import React, { Component } from 'react'
import { connect } from 'react-redux'

import Divider from 'material-ui/Divider'
import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'

const mapStateToProps = ({ date, result }) => ({
  date,
  result
})

class Morning extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  render() {
    const { date, result } = this.props
    return (
      <Card>
        <CardTitle title="人狼" subtitle={date + "日目 : 朝"}/>
          <CardText>
            <p>朝になりました。<br /></p>
            <p><b>{result.deadPeople}</b>さんが、無残な姿で発見されました。<br /></p>
            <Divider />
            <p>村人達は人狼を処刑するため、話し合いの後、投票で処刑する人を決定します。<br /></p>
            <p>尚、死亡したプレイヤーは、全プレイヤーの役職を確認できますが、他のプレイヤーと話し合ってはいけません。<br /></p>
          </CardText>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(Morning)