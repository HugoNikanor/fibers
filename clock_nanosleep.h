/* Copyright (C) 2020 Aleix Conchillo Flaqué <aconchillo@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */

#ifndef CLOCK_NANOSLEEP_H
#define CLOCK_NANOSLEEP_H

#include <time.h>

#ifndef TIMER_ABSTIME
#define TIMER_ABSTIME 1
#endif // TIMER_ABSTIME

int clock_nanosleep (clockid_t id, int flags, const struct timespec *ts,
                     struct timespec *ots);

#endif // CLOCK_NANOSLEEP_H
