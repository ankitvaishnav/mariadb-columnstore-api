/* Copyright (c) 2017, MariaDB Corporation. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

%exception {
  try {
    $action
  } catch (mcsapi::ColumnStoreError &e) {
    PyErr_SetString(PyExc_RuntimeError, const_cast<char*>(e.what()));
    SWIG_fail;
  } catch (std::bad_alloc &er) {
    PyErr_SetString(PyExc_RuntimeError, const_cast<char*>(er.what()));
    SWIG_fail;
  }
}

%module pymcsapi

%{
#include "libmcsapi/mcsapi.h"
%}

/* MCOL-1321 */
%include "typemaps.i"
%apply int *OUTPUT { mcsapi::columnstore_data_convert_status_t* status };
/* MCOL-1321 */
/* MCOL-1094 */
%include "std_vector.i"
%template(TableLockInfoVector) std::vector<mcsapi::TableLockInfo>; 
/* MCOL-1094 */

/* swig includes for standard types / exceptions */
%include <std_except.i>
%include <std_string.i>
%include <stdint.i>

/* include each of the mcsapi.h files and dependencies directly for swig to process */
%include "libmcsapi/visibility.h"
%include "libmcsapi/mcsapi_types.h"
%include "libmcsapi/mcsapi_exception.h"
%include "libmcsapi/mcsapi_driver.h"
%include "libmcsapi/mcsapi_bulk.h"
