import { take, put, fork, select, call } from 'redux-saga/effects'
import { MATCH, ROLE } from './actions'

function* matchingSaga() {
  const { payload } = yield take(MATCH)
  yield call(sendData, 'do_matching')
}

function* setRoleSaga() {
  const { payload } = yield take(ROLE)
  yield call(sendData, 'set_role', payload)
}

function* saga() {
  yield fork(matchingSaga)
  yield fork(setRoleSaga)
}

export default saga
