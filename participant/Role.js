import React, { Component } from 'react'
import { connect } from 'react-redux'

import {Card, CardActions, CardText, CardTitle } from 'material-ui/Card'

import WerewolfUtil from './Roles/WerewolfUtil'

const mapStateToProps = ({ role, player }) => ({ role, player })

class Role extends Component {
    componentDidMount() {
      if (this.props.role == "werewolf")
        this.props.dispatch(getOptionalData())
    }

    render() {
        const { role, player } = this.props
        return (
            <div>
                <Card>
                    <CardTitle title="人狼" subtitle="役職確認"/>
                    <CardText>
                        <p>参加者の登録が終了し、あなたの役職が決まりました。</p>
                        <p>{player.name}さんの役職は<b>{player.role != null
                                                ? role[player.role].name
                                                : ""}</b>です。</p>
                        <p>{player.role != null
                              ? role[player.role].description
                              : ""}</p>
                        {
                          (player.role == "werewolf")
                            ? <WerewolfUtil />
                            : null
                        }
                    </CardText>
                </Card>
            </div>
        )
    }
}
export default connect(mapStateToProps)(Role)
