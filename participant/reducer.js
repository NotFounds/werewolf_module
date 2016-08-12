import { handleActions } from 'redux-actions'
import combineSectionReducers from 'combine-section-reducers'

const page = handleActions({
  'RECEIVE_CONTENTS': (state, { page }) => {
    return page
  },
  'CHANGE_PAGE': (state, { page }) => {
    return page
  },
  'UPDATE_TURN': (state, { page }) => {
    return page
  }
}, "description")

const player = handleActions({
  'UPDATE_PERSONAL': (state, { player }) => {
    return player
  },
  'RECEIVE_CONTENTS': (state, { player }) => {
    return player
  },
  'UPDATE_TURN': (state, { player }) => {
    return player
  }
}, {})

const role = handleActions({
  'RECEIVE_CONTENTS': (state, { role }) => {
    return role
  },
  'UPDATE_TURN': (state, { role }) => {
    return role
  }
}, {})

const meetingTime = handleActions({
  'RECEIVE_CONTENTS': (state, { meetingTime }) => {
    return meetingTime
  }
}, {})

const date = handleActions({
  'RECEIVE_CONTENTS': (state, { date }) => {
    return date
  },
  'UPDATE_TURN': (state, { date }) => {
    return date
  }
}, {})

const result = handleActions({
  'RECEIVE_CONTENTS': (state, { result }) => {
    return result
  },
  'UPDATE_TURN': (state, { result }) => {
    return result
  }
}, {})

const alivePeoples = handleActions({
  'RECEIVE_CONTENTS': (state, { alivePeoples }) => {
    return alivePeoples
  },
  'UPDATE_TURN': (state, { alivePeoples }) => {
    return alivePeoples
  }
}, {})

const deadPeoples = handleActions({
  'RECEIVE_CONTENTS': (state, { deadPeoples }) => {
    return deadPeoples
  },
  'UPDATE_TURN': (state, { deadPeoples }) => {
    return deadPeoples
  }
}, {})

const villageName = handleActions({
  'RECEIVE_CONTENTS': (state, { villageName }) => {
    return villageName
  }
}, "")

const reducer = combineSectionReducers({
  page,
  player,
  role,
  meetingTime,
  date,
  result,
  alivePeoples,
  deadPeoples,
  villageName
})

export default reducer
