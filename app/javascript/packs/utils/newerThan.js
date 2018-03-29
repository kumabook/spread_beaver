import moment from 'moment';

export function since(d) {
  return moment()
    .subtract(d, 'days')
    .utcOffset('+09:00')
    .startOf('day')
    .valueOf();
}

export function daily() {
  return since(1);
}
export function weekly() {
  return since(7);
}

export function monthly() {
  return since(30);
}
