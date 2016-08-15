import { handleActions } from 'redux-actions'
import combineSectionReducers from 'combine-section-reducers'

const mode = handleActions({
  'CHANGE_MODE': (state, { mode }) => {
    return mode
  },
  'RECEIVE_CONTENTS': (state, { data }) => {
    return data.mode
  },
  'RECEIVE_PLAYERS': (state, { data }) => {
    return data.mode
  }
}, "wait")

const count = handleActions({
  'ADD_PLAYER': (state, { count }) => {
    return count
  },
  'RECEIVE_CONTENTS': (state, { data }) => {
    return data.count
  }
}, 0)

const players = handleActions({
  'ADD_PLAYER': (state, { participants }) => {
    return participants
  },
  'RECEIVE_CONTENTS': (state, { data }) => {
    return data.participants
  },
  'RECEIVE_PLAYERS': (state, { data }) => {
    return data.participants
  },
  'CHANGE_MODE': (state, { data }) => {
    return data.participants
  }
}, {})

const data = handleActions({
  'RECEIVE_CONTENTS': (state, { data }) => {
    return data
  },
  'CHANGE_MODE': (state, { data }) => {
    return data
  },
  'RECEIVE_PLAYERS': (state, { data }) =>
  {
    return data
  }
}, {})

const reducer = combineSectionReducers({
  mode,
  data,
  count,
  players
})

export default reducer
