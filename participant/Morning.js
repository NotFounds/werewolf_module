import React, { Component } from 'react'
import { connect } from 'react-redux'

import Divider from 'material-ui/Divider'
import FlatButton from 'material-ui/FlatButton'
import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'

import { check } from './actions'
import Result from './Result'

const mapStateToProps = ({ date, result, villageName, player }) => ({
  date,
  result,
  villageName,
  player
})

class Morning extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  handleClick() {
    const { dispatch } = this.props
    dispatch(check())
  }

  render() {
    const { date, result, villageName, player } = this.props
    return (
      <Card>
        <CardTitle title="人狼" subtitle={(date + 1) + "日目 : 朝"}/>
          <CardText>
            <p>朝になりました。<br /></p>
            {
              (result["morning"] != null && result["morning"].deadPeople != null)
                ? (<p><b>{result["morning"].deadPeople}</b>さんが、無残な姿で発見されました。<br /></p>)
                : (<p>昨晩は狩人の活躍により、襲撃による犠牲者はいませんでした。</p>)
            }
            <Divider />
            <p>{villageName}村の人達は人狼を処刑するため、話し合いの後、投票で処刑する人を決定します。<br /></p>
            <p>尚、死亡したプレイヤーは、全プレイヤーの役職を確認できますが、他のプレイヤーと話し合ってはいけません。<br /></p>
            {((player.isAlive) ? null : <Result />)}<br />
          </CardText>
          <CardActions>
            <FlatButton
              primary={true}
              onClick={this.handleClick.bind(this)}
            >確認</FlatButton>
          </CardActions>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(Morning)
