import React, { Component } from 'react'
import { connect } from 'react-redux'

import Divider from 'material-ui/Divider'
import MenuItem from 'material-ui/MenuItem'
import SelectField from 'material-ui/SelectField'
import FlatButton from 'material-ui/FlatButton'
import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'

import { vote, check } from './actions'

const mapStateToProps = ({ date, player, alivePeoples }) => ({
  date,
  player,
  alivePeoples
})

class Evening extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {value: null}
    if (this.props.player.isAlive == false) { this.props.dispatch(check()) }
  }

  handleChange(event, index, value) {
    this.setState({value: value})
  }

  handleClick() {
    const { value } = this.state
    this.props.dispatch(vote(value))
  }

  render() {
    const { date, player, alivePeoples } = this.props
    let list = []
    alivePeoples.forEach(function(value, index, array) {
      if (value != player.name) {
        list.push(<MenuItem key={index} value={value} primaryText={value} />)
      }
    }.bind(this))
    return (
      <Card>
        <CardTitle title="人狼" subtitle={(date + 1) + "日目 : 夕"}/>
          <CardText>
            <div>
              <p>夕方になりました。話し合いを終了し、吊る人を投票で決めてください。<br /></p>
              <SelectField
                value={this.state.value}
                onChange={this.handleChange.bind(this)}
                hintText="選択して下さい"
                hintStyle = {{backgroundColor: '#ffffff', zIndex: 1, pointerEvents: 'none',  width: '85%'}}
              >{list}</SelectField>
            </div>
          </CardText>
          <CardActions>
            <FlatButton
              primary={true}
              onClick={this.handleClick.bind(this)}
            >決定</FlatButton>
          </CardActions>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(Evening)
