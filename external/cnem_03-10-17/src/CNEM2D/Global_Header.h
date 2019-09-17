/* This file is part of CNEMLIB.
 
Copyright (C) 2003-2011
Lounes ILLOUL (illoul_lounes@yahoo.fr)
Philippe LORONG (philippe.lorong@ensam.eu)
Arts et Metiers ParisTech, Paris, France
 
CNEMLIB is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CNEMLIB is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

Please report bugs to illoul_lounes@yahoo.fr */

#pragma once

#ifdef _WIN32

#ifndef _WIN32_WINNT        // Autorise l'utilisation des fonctionnalités spécifiques é Windows XP ou version ultérieure.                   
#define _WIN32_WINNT 0x0501    // Attribuez la valeur appropriée é cet élément pour cibler d'autres versions de Windows.
#endif                        

//#define WIN32_LEAN_AND_MEAN // Exclure les en-têtes Windows rarement utilisés
#include <windows.h>
#include <process.h>    /* _beginthread, _endthread */
#include <stddef.h>
#include <conio.h>
#include <signal.h>

#else

#include<signal.h>
#include<pthread.h>
#include <dlfcn.h>
//#include<process.h>
//#include<error.h>

#endif

//#include <cstdio>
//#include <cstdlib>
//#include <cassert>
//#include <utility>

#include <fcntl.h>
#ifdef _WIN32
#include <tchar.h>
#include <io.h>
#include <lm.h>
#endif
#include <stdlib.h>
#include <stdio.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <string.h>
#include <vector>
#include <list>
#include <set>
#include <map>
#include <time.h>
#include <math.h>
#include <algorithm>
//#include <thread>
using namespace std;

using namespace std;
//#include "tbb/task.h"
#include "tbb/task_scheduler_init.h"
//#include "tbb/tick_count.h"
#include "tbb/blocked_range.h"
//#include "tbb/concurrent_vector.h"
//#include "tbb/concurrent_queue.h"
//#include "tbb/concurrent_hash_map.h"
//#include "tbb/parallel_while.h"
#include "tbb/parallel_for.h"
//#include "tbb/parallel_reduce.h"
//#include "tbb/parallel_scan.h"
//#include "tbb/pipeline.h"
//#include "tbb/atomic.h"
//#include "tbb/mutex.h"
//#include "tbb/spin_mutex.h"
//#include "tbb/queuing_mutex.h"
//#include "tbb/tbb_thread.h"
using namespace tbb;
