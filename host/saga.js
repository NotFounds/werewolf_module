import { take, put, fork, select, call } from 'redux-saga/effects'
import { START, DESTROY, MATCH, ROLE } from './actions'

function* startSaga() {
  const { payload } = yield take(START)
  yield call(sendData, 'start')
}

function* destroySaga() {
  const { payload } = yield take(DESTROY)
  yield call(sendData, 'destroy')
}

function* matchingSaga() {
  const { payload } = yield take(MATCH)
  yield call(sendData, 'do_matching')
}

function* setRoleSaga() {
  const { payload } = yield take(ROLE)
  yield call(sendData, 'set_role', payload)
}

function* saga() {
  yield fork(startSaga)
  yield fork(destroySaga)
  yield fork(matchingSaga)
  yield fork(setRoleSaga)
}

export default saga
