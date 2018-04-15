import moment from 'moment';

export function since(d) {
  return moment()
    .subtract(d, 'days')
    .utcOffset('+09:00')
    .startOf('day')
    .valueOf();
}

export function fromToday(period) {
  switch (period) {
    case 'daily':
      return { newerThan: since(1), olderThan: since(0) };
    case 'weekly':
      return { newerThan: since(7), olderThan: since(0) };
    case 'monthly':
      return { newerThan: since(30), olderThan: since(0) };
    default:
      return { newerThan: since(7), olderThan: since(0) };
  }
}
