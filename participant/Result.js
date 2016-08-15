import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Card, CardTitle, CardText, CardActions } from 'material-ui/Card'

import { getResult } from './actions'

const mapStateToProps = ({ result, role }) => ({
  result,
  role
})

const Player = ({ name, role, isAlive }) => (
  <tr>
    <td>{name}</td>
    <td>{role}</td>
    <td>{
      isAlive
        ? "生存"
        : "死亡"
    }</td>
  </tr>
)

class Result extends Component {
  constructor(props, context) {
    super(props, context)
    this.state = {}
  }

  render() {
    const { result, role } = this.props
    console.log(result)
    return (
      <Card>
        <CardTitle title="人狼" subtitle="結果"/>
          <CardText>
            {(result.isEnd
              ? <div>
                  <p>ゲームは終了しました。お疲れ様でした。</p>
                  <p>{result.side}陣営の方の勝利です。</p>
                </div>
              : <p>あなたは死亡しました。ゲームが終了するまで、話し合い等に参加することはできません。</p>
            )}
            <p>今回の役職は以下のとおりです。</p>
            <table>
              <thead>
                <tr>
                  <th>名前</th>
                  <th>役</th>
                  <th>状態</th>
                </tr>
              </thead>
              <tbody>
                {
                  Object.keys(result.players).map(id => (
                    <Player
                      key={id}
                      name={(result.players[id].name != "")
                              ? result.players[id].name
                              : "id: "+id}
                      role={result.players[id].role != null
                              ? role[result.players[id].role].name
                              : "未定"}
                      isAlive={result.players[id].isAlive}
                    />
                  ))
                }
              </tbody>
            </table>
          </CardText>
      </Card>
    )
  }
}

export default connect(mapStateToProps)(Result)
