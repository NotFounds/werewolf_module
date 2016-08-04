import { handleActions } from 'redux-actions'
import combineSectionReducers from 'combine-section-reducers'

const page = handleActions({
  'RECEIVE_CONTENTS': (state, { page }) => {
    console.log(page)
    return page
  }
}, "description")

const player = handleActions({
  'UPDATE_PERSONAL': (state, { player }) => {
    return player
  },
  'RECEIVE_CONTENTS': (state, { player }) => {
    return player
  }
}, {})

const role = handleActions({
  'RECEIVE_CONTENTS': (state, { role }) => {
    return role
  }
}, {})

const reducer = combineSectionReducers({
  page,
  player,
  role
})

export default reducer
