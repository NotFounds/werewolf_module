import { take, put, fork, select, call } from 'redux-saga/effects'
import { START, DESTROY, MATCH, ROLE, NAME, SKIP } from './actions'

function* startSaga() {
  while (true) {
    const { payload } = yield take(START)
    yield call(sendData, 'start')
  }
}

function* destroySaga() {
  while (true) {
    const { payload } = yield take(DESTROY)
    yield call(sendData, 'destroy')
  }
}

function* matchingSaga() {
  while (true) {
    const { payload } = yield take(MATCH)
    yield call(sendData, 'do_matching')
  }
}

function* setRoleSaga() {
  while (true) {
    const { payload } = yield take(ROLE)
    yield call(sendData, 'set_role', payload)
  }
}

function* setNameSaga() {
  while (true) {
    const { payload } = yield take(NAME)
    yield call(sendData, 'set_villageName', payload)
  }
}

function* skipMeetingSaga() {
  while (true) {
    const { payload } = yield take(SKIP)
    yield call(sendData, 'skip_meeting')
  }
}

function* saga() {
  yield fork(startSaga)
  yield fork(destroySaga)
  yield fork(matchingSaga)
  yield fork(setRoleSaga)
  yield fork(setNameSaga)
  yield fork(skipMeetingSaga)
}

export default saga
