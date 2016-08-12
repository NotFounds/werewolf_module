import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Card, CardHeader, CardText } from 'material-ui/Card'

const mapStateToProps = ({ data, players }) => ({ data, players })

const Player = ({ name, role, isAlive, page }) => (
  <tr>
    <td>{name}</td>
    <td>{role}</td>
    <td>{page}</td>
    <td>{
      isAlive
        ? "生存"
        : "死亡"
    }</td>
  </tr>
)

const Players = ({ data, players }) => (
  <Card>
    <CardHeader
      title={"Players : " + Object.keys(players).length + "人"}
      actAsExpander={true}
      showExpandableButton={true}
    />
    <CardText expandable={true}>
      <table>
        <thead>
          <tr>
            <th>名前</th>
            <th>役</th>
            <th>ページ</th>
            <th>状態</th>
          </tr>
        </thead>
        <tbody>
          {
            Object.keys(players).map(id => (
              <Player
                key={id}
                name={players[id].name}
                role={players[id].role != null
                        ? data.role[players[id].role].name
                        : ""}
                page={players[id].page}
                isAlive={players[id].isAlive}
              />
            ))
          }
        </tbody>
      </table>
    </CardText>
  </Card>
)

export default connect(mapStateToProps)(Players)
