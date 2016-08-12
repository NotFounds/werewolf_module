import React, { Component } from 'react'
import { connect } from 'react-redux'

const mapStateToProps = ({ data }) => ({
  data
})

function getState(state) {
  switch (state) {
    case 'preparation':
      return '準備中'
    case 'wait':
      return '待機中'
    case 'play':
      return 'プレイ中'
    case 'result':
      return '結果表示'
    case 'destroied':
      return '廃村'
    default:
      return '?'
  }
}

const StateView  = ({ data }) => (
  <div>
  <p>ゲームの状態 : <span style={{fontSize: "large"}}>{getState(data.mode)}</span></p>
  </div>
)

export default connect(mapStateToProps)(StateView)
