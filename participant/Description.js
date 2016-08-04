import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'
import FlatButton from 'material-ui/FlatButton'

import { setWait } from './actions'

const mapStateToProps = ({}) => ({})

class Description extends Component {
  handleClick() {
    this.props.dispatch(setWait())
  }

  render() {
    return (
      <Card>
        <CardTitle title="人狼" subtitle="説明"/>
          <CardText>
            <p>プレイヤーはそれぞれが村人と村人に化けた人狼となり、自分自身の正体がばれないようにしながら他のプレイヤーと交渉して相手の正体を探ります。<br /></p>
            <p>ゲームは半日単位で進行し、昼には全プレイヤーの投票により決まった人狼容疑者1名の処刑が、夜には人狼による村人の襲撃が行われます。<br /></p>
            <p>全ての人狼を処刑することができれば村人チームの勝ち、生き残った人狼と同数まで村人を減らすことができれば人狼チームの勝ちとなります。<br /></p>
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

export default connect(mapStateToProps)(Description)
