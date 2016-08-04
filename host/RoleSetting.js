import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'

import Slider from 'material-ui/Slider'
import RaisedButton from 'material-ui/RaisedButton'
import { Card, CardHeader, CardText } from 'material-ui/Card'

import { setRole } from './actions'

const mapStateToProps = ({ data, count }) => ({
  data,
  count
})

class RoleSetting extends Component {
  constructor(props, context) {
    super(props, context)
    const value = this.props.data.roleCount
    let cnt = 0
    Object.keys(value).forEach(function(role, index, array) {
      cnt += value[role]
    }.bind(this))
    this.state = {value: value, cnt: cnt}
  }

  handleClick() {
    const { count, dispatch } = this.props
    let { value, cnt} = this.state
    if (count == cnt) {
      alert("現在の設定を保存しました。")
      dispatch(setRole(value))
    }
    else alert(count < cnt ? "参加人数が足りていません" : "役職が足りていません")
  }

  handleChange() {
    const { data } = this.props
    const roles = data.role
    let value = {}
    let cnt = 0
    Object.keys(roles).forEach(function(role, index, array) {
      value[role] = this.refs[role].state.value
      cnt += value[role]
    }.bind(this))
    this.setState({value: value, cnt: cnt})
  }

  render() {
    const { value, cnt } = this.state
    const { data, count } = this.props
    const roles = data.role
    let list = Object.keys(roles).map(role => (
      <div key={role.toString()}>
      <p><b>{roles[role].name}</b><br />{value[role.toString()]} / {count} 人</p>
      <Slider step={1} ref={role.toString()} value={value[role.toString()]} max={count} onChange={this.handleChange.bind(this)} />
      </div>
    ))
    let color = (cnt > count ? "red" : "green")
    return(
      <div>
      <p>設定されている役職の人数: <font color={color}>{cnt}/{count}人</font></p>
      {list}
      <RaisedButton
      primary={true}
      onClick={this.handleClick.bind(this)}
      >決定</RaisedButton>
      </div>
    )
  }
}

export default connect(mapStateToProps)(RoleSetting)
