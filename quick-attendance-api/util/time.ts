/**
 * @description Calculates the ISO week number for a given date.
 *
 * The ISO week date system is a leap week calendar system that is part of the ISO 8601 date and time standard.
 * ISO 8601 assigns numbers to each week of the year. A week starts on Monday and ends on Sunday.
 * The first week of the year is the week that contains the first Thursday of the year.
 *
 * @example
 * ```typescript
 * const currentWeekNum = getWeekNum(); // default is current date
 * const weekNum = getWeekNum(new Date('2023-06-01')); // 22, get the week number for a specific date
 * ```
 *
 * @param {Date=} date - The date object for which to calculate the week number.
 * @return The ISO week number of the given date.
 */
export function get_week_num_of_year(date: Date = new Date()) {
  const d = new Date(date.getTime());
  d.setHours(0, 0, 0, 0);
  // Thursday in current week decides the year.
  d.setDate(d.getDate() + 3 - (d.getDay() + 6) % 7);
  // January 4 is always in week 1.
  const week1 = new Date(d.getFullYear(), 0, 4);
  // Adjust to Thursday in week 1 and count number of weeks from date to week1.
  return 1 +
    Math.round(((d.getTime() - week1.getTime()) / 86400000 - 3 + (week1.getDay() + 6) % 7) / 7);
}

/**
 * @description Get the week number in the given month
 * Weeks start on Sunday
 * The first week of a month is the one that contains the first of the month
 * So in March 2013:
 *
 * Fri 1 Mar is the first day of week 1
 * Sun 3 Mar is the start of week 2
 * Sun 31 Mar is the start of week 6 (and is the only day in the that week)
 * Mon 1 Apr is the first day of week 1 in April.
 * @param date - The date to get the week number of
 * @returns The week number of the given month
 */
export function get_week_num_of_month(date: Date) {
  const month = date.getMonth(),
    year = date.getFullYear(),
    firstWeekday = new Date(year, month, 1).getDay(),
    offsetDate = date.getDate() + firstWeekday - 1,
    index = 1,
    week = index + Math.floor(offsetDate / 7);
  return week;
}
