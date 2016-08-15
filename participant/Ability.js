import React, { Component } from 'react'
import { connect } from 'react-redux'

import Divider from 'material-ui/Divider'

import Seer from './Roles/Seer'
import Werewolf from './Roles/Werewolf'
import Psychic from './Roles/Psychic'
import Hunter from './Roles/Hunter'
import Default from './Roles/Default'

const mapStateToProps = ({ role, player }) => ({
  role,
  player
})

class Ability extends Component {
  constructor(props, context) {
    super(props, context)
  }

  render() {
    const { role, player } = this.props
    let list = []
    return (
        <div>
          <p>{player.name}さんの役職は<b>{player.role != null
                                            ? role[player.role].name
                                            : ""}</b>です。</p>
          <p>{player.role != null
                ? role[player.role].description
                : ""}</p>
          <Divider />
          {((player.role == "seer")     ? <Seer />     : null)}
          {((player.role == "psychic")  ? <Psychic />  : null)}
          {((player.role == "hunter")   ? <Hunter />   : null)}
          {((player.role == "werewolf") ? <Werewolf /> : null)}
          {((player.role == "villager") ? <Default />  : null)}
          {((player.role == "minion")   ? <Default />  : null)}
        </div>
    )
  }
}

export default connect(mapStateToProps)(Ability)
