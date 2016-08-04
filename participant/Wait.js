import React, { Component } from 'react'
import { connect } from 'react-redux'

import {Card, CardActions, CardText, CardTitle } from 'material-ui/Card'
import CircularProgress from 'material-ui/CircularProgress'

const mapStateToProps = ({}) => ({})

class Wait extends Component {
    render() {
        return (
            <div>
                <Card>
                    <CardTitle title="人狼" subtitle="待機中"/>
                    <CardText>
                        <p>参加者の登録を待っています。</p>
                        <p>この画面のまましばらくお待ち下さい。</p>
                    </CardText>
                    <div style={{textAlign: "center"}}>
                        <CircularProgress size={2}/>
                    </div>
                </Card>
            </div>
        )
    }
}
export default connect(mapStateToProps)(Wait)
