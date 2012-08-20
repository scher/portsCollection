#-*- mode: Fundamental; tab-width: 4; -*-
# ex:ts=4
#
# $FreeBSD$
#
# Please view me with 4 column tabs!

# The following variables may be specified by user.
# By the way, all this variable have default values.
#
# _parv_WANT_PARALLEL_BUILD 	- trigger for parallel ports installation.
#								  Set this variable to some value to enable
#								  parallel ports build/install. It does not
#								  matter what value is assigned.
#								  Example: _parv_WANT_PARALLEL_BUILD=yes
#
# _parv_CHECK_ACTIVE_TIMEOUT	- timeout in seconds before next check of active
#								  builds in case if port is prohibit to spawn
#								  another background process.
#								  Default: 2
#
# _parv_WAIT_FOR_LOCK_TIME 		- time in seconds to wait if lock file is locked
#								  by lockf(1) in case of directory locking.
#								  Default: 5
#
# _parv_WAIT_FOR_UNLOCK_TIME	- time in seconds to wait if lock file is locked
#								  by lockf(1) in case of directory unlocking.
#								  Default: 15
#
# _parv_LOCK_ATTEMPT_TIMEOUT	- while trying to lock a directory in "while"
#								  loop, if the directory is locked, this
#								  variable specifies delay in seconds before
#								  next attempt to lock a directory. Default: 2
#
# _parv_ON_LOCK_FEEDBACK_TIMEOUT -while trying to lock a directory in "while"
#								  loops, if the directory is locked, user
#								  feedback is printed once in
#                                 ${_parv_ON_LOCK_FEEDBACK_TIMEOUT} attempts.
#								  Default: 2
#
# _parv_PARALLEL_BUILDS_NUMBER  - number of parallel dependency builds for
#								  current port.
#								  Default: ${_parv_DEFAULT_PAR_BUILDS_NUM} (see below).
#								  If value of this variable is more then
#								  ${_parv_DEFAULT_PAR_BUILDS_NUM}, then it will
#								  be set to ${_parv_DEFAULT_PAR_BUILDS_NUM}.
#
# _parv_PORTS_LOGS_DIR			- directory that contains dependency ports' log files.
#								  Default: /tmp/portslogs
#
# The following variables are not assumed to be changed by user
#
# _parv_ON_LOCK_EXIT_STATUS		- if the directory is locked script exits with
#								  this exit status (2).
#
# _parv_MAKE_LOCK_EXIT_STATUS	- if port's directory is locked make(1) process
#							      exits with this exit status (158).
#
# LOCK_DIR 						- directory that contains lock files of locked ports.
#                                 Value: /var/db/portlocks
#
# _parv_PKG_DBDIR_LOCK_FILE		- name of lock file for ${PKG_DBDIR} locking.
#								  Value: .lock
#								  This file contains PID of the process, that
#								  locked ${PKG_DBDIR}.
#
# _parv_LOCK_DIR_LOCK_FILE 		- name of lock file for ${LOCK_DIR} locking.
#								  Value: ${PKGNAME}
#								  This file contains PID of the process, that
#								  locked ${LOCK_DIR}.
#
# _parv_PORT_LOG_FILE			- name of dependency port's log file.
#								  Value: $$(cd $$dir; ${MAKE} -V PKGNAME)-spawned-by-pid${.MAKE.PID}.log
#								  where $${dir} is a dependency port's directory
#								  in ports tree.
#
# _parv_CHECKED_CONFIG_F_PREFIX - file name prefix for file in which already
#								  checked directories are stored while evaluating
#								  "config-recursive" target. Full file name is 
#								  ${_parv_CHECKED_CONFIG_F_PREFIX}.${.MAKE.PID}
#
# _parv_DEFAULT_TARGETS			- sequence of bsd.port.mk targets. If at least
#								  one of this targets is encounted in ${.TARGETS}
#								  then port's directory has to be locked.
#
# _parv_DEFAULT_PAR_BUILDS_NUM 	- default number of parallel dependency builds.
#								  Value: number of logical CPUs on user's machine.
#
# The following targets may be used by user
#
# check-license-depends			- license checking for port's dependencies.
#								  Does not lock any directory.
#								  If any dependencies need to ask for comfirmation
#								  then port's build stops, and user is listed all
#								  ports that will ask for licences checking.
#								  Then a user will have to eval "make patch" for the
#								  above mentioned ports. Only if no dependencies
#								  require license confirmation parallel ports build
#								  will be allowed.
#
# locking-config-recursive		- Configure options for current port and all dependencies
#								  recursively, while holding lock on
#								  ${_parv_PORT_DBDIR_LOCK_LOOP}. Considers dynamic
#								  changes in port's dependencies. Skips already checked
#								  ports.
#

.if !defined(_POSTMKINCLUDED) && !defined(Parallel_Pre_Include)
Parallel_Pre_Include=	bsd.parallel.mk

#####################################################
# Commands
_parv_KILL= /bin/kill
_parv_KILL_SIGNAL= USR1
_parv_PKILL= /bin/pkill
_parv_PKILL_FLAGS= -P
_parv_UMASK= 0644

DO_NADA?=		${TRUE}
# End of Commands section
#####################################################
#####################################################
# Debugging specific tools and variable declarations
_dparv_START_OUTPUT_MESSAGE= =================_PAR_PORTS_SPECIFIC_OUTPUT_==============
_dparv_END_OUTPUT_MESSAGE= ==============_END_OF_PAR_PORTS_SPECIFIC_OUTPUT_==============

_dparv_START_OUTPUT= ${ECHO_CMD} ${_dparv_START_OUTPUT_MESSAGE}
_dparv_END_OUTPUT= ${ECHO_CMD} ${_dparv_END_OUTPUT_MESSAGE}

# Use it when you need a barrier
_dparv_DEBUGGING_BREAKPOINT= ${ECHO_CMD} Debugging breakpoint here...; \
	${ECHO_CMD} Press any key when you are ready to continue; \
	read non_existed_var

seal:
	@echo "       <<<<<< =====       WE ARE HERE       ===== >>>>>>"
breakpoint:
	@${_dparv_DEBUGGING_BREAKPOINT}

# End of Debugging specific tools and variable declarations section 
#####################################################
#####################################################
_parv_DEFAULT_TARGETS= all check-sanity fetch checksum extract patch configure build install
_parv_IS_DEFAULT_TARGET= 0

# in case of the following call: make -D_parv_WANT_PARALLEL_BUILD
# "all" target will be evaluated. It is in default sequence, ${.TARGETS}="".
#
.if !${.TARGETS}
_parv_IS_DEFAULT_TARGET= 1
.else
.for _called_target in ${.TARGETS}
_tmp_called_target= ${_called_target}
.	for _def_target in ${_parv_DEFAULT_TARGETS}
.		if ${_tmp_called_target} == ${_def_target}
_parv_IS_DEFAULT_TARGET= 1
.		endif
.	endfor
.endfor
.endif #!{.TARGETS}

.if !defined(_parv_DEFAULT_PAR_BUILDS_NUM) 
_parv_DEFAULT_PAR_BUILDS_NUM!= ${SYSCTL} -n kern.smp.cpus
.endif

.if !defined(_parv_PARALLEL_BUILDS_NUMBER) || ${_parv_PARALLEL_BUILDS_NUMBER} > ${_parv_DEFAULT_PAR_BUILDS_NUM}
_parv_PARALLEL_BUILDS_NUMBER= ${_parv_DEFAULT_PAR_BUILDS_NUM}
.endif
#####################################################
#####################################################
# Locking variables and tools

_parv_PORTS_LOGS_DIR?= /tmp/portslogs
LOCK_DIR?= /var/db/portslocks
_parv_PKG_DBDIR_LOCK_FILE= .lock
_parv_PORT_DBDIR_LOCK_FILE= .lock
_parv_LOCK_DIR_LOCK_FILE= ${PKGNAME}
_parv_PORT_LOG_FILE= $$(cd $$dir; ${MAKE} -V PKGNAME)-spawned-by-pid${.MAKE.PID}.log

_parv_CHECKED_CONFIG_F_PREFIX= already-checked-config

_parv_WAIT_FOR_LOCK_TIME?= 5
_parv_WAIT_FOR_UNLOCK_TIME?= 15

_parv_LOCK_ATTEMPT_TIMEOUT?= 2
_parv_ON_LOCK_FEEDBACK_TIMEOUT?= 2

_parv_CHECK_ACTIVE_TIMEOUT?= 2

_parv_ON_LOCK_EXIT_STATUS= 2
_parv_LOCKF_EX_TEMPFAIL= 75

_parv_MAKE_LOCK_EXIT_STATUS= 158

.for _lock_dir in PKG_DBDIR PORT_DBDIR LOCK_DIR
# ${${_lock_dir}} == ${PKG_DBDIR} OR ${LOCK_DIR}

# _parv_PKG_DBDIR_LOCK_SEQ
# _parv_LOCK_DIR_LOCK_SEQ
# _parv_PORT_DBDIR_LOCK_SEQ
#
# Senquence of commands to lock a directory using ${_parv_${_lock_dir}_LOCK_FILE}.
# During evaluation of the following commands lockf(1) is holding lock on
# ${_parv_${_lock_dir}_LOCK_FILE} file. Hence NO other process is able to evaluate
# any commands using lockf(1) locking on the same ${_parv_${_lock_dir}_LOCK_FILE} file.
# 
# Stalled locks cheking enabled.
#
# If the directory is locked this script returns ${_parv_ON_LOCK_EXIT_STATUS}.
#
# Process is allowed to work in locked port's directory if and only if it is locked
# by it's parent process.
#
_parv_${_lock_dir}_LOCK_SEQ= \
	${CHMOD} ${_parv_UMASK} ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}; \
	pid=$$(${CAT} ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}); \
	if [ $${pid} ]; then \
		[ $${pid} -eq ${.MAKE.PID} ] && exit 0; \
		ps -p $${pid} > /dev/null && status=$$? || status=$$?; \
		if [ $${status} -eq 0 ]; then \
			if [ ${_lock_dir} = "LOCK_DIR" ] || [ ${_lock_dir} = "PORT_DBDIR" ]; then \
				cur_pid=${.MAKE.PID}; \
				while true; do \
					ppid=$$( ps -o ppid -p $${cur_pid} | ${AWK} "NR==2" ); \
					if [ $${ppid} -eq $${pid} ]; then \
						${ECHO_CMD} "===> ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE} is locked by parent make process."; \
						${ECHO_CMD} "     We are allowed to work here."; \
						break; \
					elif [ $${ppid} -eq 0 ]; then \
						exit ${_parv_ON_LOCK_EXIT_STATUS}; \
					else \
						cur_pid=$${ppid}; \
					fi; \
				done; \
			else \
				exit ${_parv_ON_LOCK_EXIT_STATUS}; \
			fi; \
		else \
			${ECHO_CMD} "===> Stalled lock at ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE} file."; \
			${ECHO_CMD} "     Deleting stalled lock."; \
			${ECHO_CMD} "===> Locking: ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}"; \
			${ECHO_CMD} ${.MAKE.PID} >  ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}; \
		fi; \
	else \
		${ECHO_CMD} "===> Locking: ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}"; \
		${ECHO_CMD} ${.MAKE.PID} > ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}; \
	fi

#####################################################

# _parv_PKG_DBDIR_DO_LOCK
# _parv_LOCK_DIR_DO_LOCK
# _parv_PORT_DBDIR_DO_LOCK
#
# This scripts handles exit status of lockf(1) call.
# It substitutes exit status 75 of lockf(1) for ${_parv_ON_LOCK_EXIT_STATUS}
# and pushes it.
#
_parv_${_lock_dir}_DO_LOCK= \
	lockf -k -t ${_parv_WAIT_FOR_LOCK_TIME} ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE} ${SH} -c '${_parv_${_lock_dir}_LOCK_SEQ}' || { \
		status=$$?; \
			if [ $${status} -eq ${_parv_LOCKF_EX_TEMPFAIL} ] || \
					[ $${status} -eq ${_parv_ON_LOCK_EXIT_STATUS} ]; then \
				exit ${_parv_ON_LOCK_EXIT_STATUS}; \
			else \
				${_dparv_START_OUTPUT}; \
				${ECHO_CMD} "Unhandled EXIT STATUS = $${status}. Terminating"; \
				${_dparv_END_OUTPUT}; \
				exit 1; \
			fi; \
	}

#####################################################

# _parv_PKG_DBDIR_LOCK_LOOP
# _parv_LOCK_DIR_LOCK_LOOP
# _parv_PORT_DBDIR_LOCK_LOOP
#
# Loops to lock a directory
# $${attempts} - Number of attempts to lock a directory. Exetranal variable.
# 				 Default: 1, if this var is not set.
#				 Set this variable to -1 for infinity loop.
# e.g. ( attempts=10; ${_parv_LOCK_DIR_LOCK_LOOP} ) && echo dir is locked \
#													|| echo dir is not locked
#
# Script exits with ${_parv_ON_LOCK_EXIT_STATUS} status if it was unabled
# to lock a directry after $${attempts} attempts.
#
_parv_${_lock_dir}_LOCK_LOOP= \
	enable_feedback=${_parv_ON_LOCK_FEEDBACK_TIMEOUT}; \
	if [ ! $${attempts} ]; then attempts=1; fi; \
	while [ $${attempts} -ne 0 ]; do \
		attempts=$$(( $${attempts} - 1 )); \
		( ${_parv_${_lock_dir}_DO_LOCK} ) && status=$$? || status=$$?; \
			if [ $${status} -eq 0 ]; then \
				exit 0; \
			elif [ $${status} -eq ${_parv_ON_LOCK_EXIT_STATUS} ]; then \
				if [ $$(( $${enable_feedback} % ${_parv_ON_LOCK_FEEDBACK_TIMEOUT} )) -eq 0 ]; then \
					${ECHO_CMD} "===> Unable to lock ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}"; \
					${ECHO_CMD} "     It is already locked by another working process."; \
					${ECHO_CMD} "     Waiting for unlock ..."; \
					enable_feedback=0; \
				fi; \
				enable_feedback=$$(( $${enable_feedback} + 1 )); \
				sleep ${_parv_LOCK_ATTEMPT_TIMEOUT}; \
				continue; \
			else \
				exit 1; \
			fi; \
	done; \
	exit ${_parv_ON_LOCK_EXIT_STATUS}

#####################################################

# _parv_PKG_DBDIR_DO_UNLOCK
# _parv_LOCK_DIR_DO_UNLOCK
# _parv_PORT_DBDIR_DO_UNLOCK
#
_parv_${_lock_dir}_DO_UNLOCK= \
	lockf -k -t ${_parv_WAIT_FOR_UNLOCK_TIME} ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE} ${SH} -c '{ \
		pid=$$(${CAT} ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}); \
		if [ ${.MAKE.PID} -eq $${pid} ]; then \
			${RM} -rf ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}; \
			${ECHO_CMD} "===> Unlocking ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE}"; \
		else \
			${ECHO_CMD} "===> ${${_lock_dir}}/${_parv_${_lock_dir}_LOCK_FILE} was locked by another process"; \
			${ECHO_CMD} "     Leave lock file."; \
		fi; \
	}'

#####################################################

.endfor # .for _lock_dir in PKG_DBDIR LOCK_DIR
#####################################################

# _parv_CHECK_SEQ
# _parv_CHECK_LOCK
#
# The former variables implement check for lock utility.
# $${pkg_name}	 - port to check, since ${_parv_LOCK_DIR_LOCK_FILE} = ${PKGNAME}
#				   External variable for script. Supports sh(1) patterns
#				   (see Shell Patterns section). Assign this variable appropriate
#				   value before executing this script.
#				   e.g. ( pkg_name=apache-[1234]; ${_parv_CHECK_LOCK} ) || ...
# Script exits with exit status ${_parv_ON_LOCK_EXIT_STATUS} if $${pkg_name} is locked
#
_parv_CHECK_SEQ= \
	${CHMOD} ${_parv_UMASK} ${LOCK_DIR}/$${pkg_name}; \
	pid=\$$(${CAT} ${LOCK_DIR}/$${pkg_name}); \
	if [ \$${pid} ]; then \
		ps -p \$${pid} > /dev/null && status=\$$? || status=\$$?; \
		if [ \$${status} -eq 0 ]; then \
			cur_pid=${.MAKE.PID}; \
			while true; do \
				ppid=\$$( ps -o ppid -p \$${cur_pid} | ${AWK} "NR==2" ); \
				if [ \$${ppid} -eq \$${pid} ]; then \
					${ECHO_CMD} '===> $${pkg_name} is locked by parent make process'; \
					${ECHO_CMD} '     We are allowed to work here'; \
					exit 0; \
				elif [ \$${ppid} -eq 0 ]; then \
					break; \
				else \
					cur_pid=\$${ppid}; \
				fi; \
			done; \
			${ECHO_CMD} '===> $${pkg_name} is already locked by another working process'; \
			exit ${_parv_ON_LOCK_EXIT_STATUS}; \
		else \
			${ECHO_CMD} '===> Stalled lock Detected for $${pkg_name}'; \
			${ECHO_CMD} '     Deleting stalled lock'; \
		fi; \
	else \
		${ECHO_CMD} '===> $${pkg_name} is not locked'; \
	fi; \
	${RM} -rf ${LOCK_DIR}/$${pkg_name}

_parv_CHECK_LOCK= \
	lockf -k -t ${_parv_WAIT_FOR_LOCK_TIME} ${LOCK_DIR}/$${pkg_name} ${SH} -c "${_parv_CHECK_SEQ}" || { \
		status=$$?; \
			if [ $${status} -eq ${_parv_LOCKF_EX_TEMPFAIL} ] || \
					[ $${status} -eq ${_parv_ON_LOCK_EXIT_STATUS} ]; then \
				exit ${_parv_ON_LOCK_EXIT_STATUS}; \
			else \
				${ECHO_CMD}; \
				${ECHO_CMD} "Unhandled EXIT STATUS = $${status}. Terminating..."; \
				exit 1; \
			fi; \
	}

_parv_ON_LOCK_EXIT_SEQ= \
	status=$$?; \
	if [ $${status} -eq  ${_parv_ON_LOCK_EXIT_STATUS} ]; then \
		${_parv_KILL} -${_parv_KILL_SIGNAL} ${.MAKE.PID} && \
		${_parv_PKILL} ${_parv_PKILL_FLAGS} $$$$; \
	else \
		exit $${status}; \
	fi

# End of Locking variables and tools section
#####################################################

_parv_CHECK_DIRS_SANITY= \
	if [ ! -d ${LOCK_DIR} ]; then \
		${_dparv_START_OUTPUT}; \
		${ECHO_CMD} "Creating ports locks dir"; \
		${_dparv_END_OUTPUT}; \
		${MKDIR} ${LOCK_DIR}; \
	fi; \
	if [ ! -d ${_parv_PORTS_LOGS_DIR} ]; then \
		${_dparv_START_OUTPUT}; \
		${ECHO_CMD} "Creating ports logs dir"; \
		${_dparv_END_OUTPUT}; \
		${MKDIR} ${_parv_PORTS_LOGS_DIR}; \
	fi

_parv_PRINT_ACTIVE_BUILDS= \
	${ECHO_CMD} "     Currently building dependency ports are"; \
	for build in $$( ${ECHO_CMD} "$${active_builds}" ); do \
		dep=$${build\#*:}; \
		dir=$${dep\#*:}; \
		target=$${dep\#\#*:}; \
		[ $$dir != $$target ] && dir=$${dir%%:*}; \
		${ECHO_CMD} "         $$(cd $${dir}; ${MAKE} -V PKGNAME)"; \
	done


# _PROCESS_ACTIVE_BUILDS	- this script contains all magic, related to
#							  processing of background dependecy builds.
#
# $${builds_num}			- current number of spawned background dependecy
#							  builds. If $${builds_num} < ${_parv_PARALLEL_BUILDS_NUMBER}
#							  then another background dependency build will be
#							  spawned, if there is any dependency to be spawned.
#							  Otherwise "sleep ${_parv_CHECK_ACTIVE_TIMEOUT}" will be called.
# $${active_builds} 		- a list of "pid:path:dir[:target]" or "pid:lib:dir[:target]"
# 							  tuples of all currently being processed ports,
#							  spawned by this make process.
#
_PROCESS_ACTIVE_BUILDS= \
	enable_feedback=${_parv_ON_LOCK_FEEDBACK_TIMEOUT}; \
	while true; do \
		builds_num=$$( ${ECHO_CMD} $${active_builds} | wc -w ); \
		if [ $${builds_num} -lt ${_parv_PARALLEL_BUILDS_NUMBER} ] && [ $${\#depends} -ne 0 ]; then \
			break; \
		fi; \
		if [ $${builds_num} -eq 0 ] && [ $${\#depends} -eq 0 ]; then \
			${ECHO_MSG} "===>   Returning to build of ${PKGNAME}"; \
			break; \
		fi; \
		for build in $$( ${ECHO_CMD} "$${active_builds}" ); do \
			pid=$${build%%:*}; \
			dep=$${build\#*:}; \
			ps -p $${pid} > /dev/null || { \
				dir=$${dep\#*:}; \
				target=$${dep\#\#*:}; \
				[ $$dir != $$target ] && dir=$${dir%%:*}; \
				wait $${pid} && status=$$? || status=$$?; \
				if [ $${status} -eq 0 ]; then \
					active_builds="$${active_builds%%$${build}*} $${active_builds\#\#*$${build}}"; \
					active_builds=$$( echo "$${active_builds}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$$//' ); \
					builds_num=$$(( $${builds_num} - 1 )); \
					if [ ${.TARGET} = "lib-depends" ]; then \
						lib=$${dep%%:*}; \
						pattern="`${ECHO_CMD} $$lib | ${SED} -E -e 's/\./\\\\./g' -e 's/(\\\\)?\+/\\\\+/g'`"; \
						if ! ${LDCONFIG} ${_LDCONFIG_FLAGS} -r | ${GREP} -vwF -e "${PKGCOMPATDIR}" | ${GREP} -qwE -e "-l$$pattern"; then \
							${ECHO_MSG} "Error: shared library \"$$lib\" does not exist"; \
							${FALSE}; \
						fi; \
					fi; \
					${ECHO_CMD} "=====> $$(cd $${dir}; ${MAKE} -V PKGNAME) is installed"; \
				elif [ $${status} -eq ${_parv_MAKE_LOCK_EXIT_STATUS} ]; then \
					${ECHO_CMD} "===> $$(cd $${dir}; ${MAKE} -V PKGNAME) is locked. Unable to start build."; \
					active_builds="$${active_builds%%$${build}*} $${active_builds\#\#*$${build}}"; \
					active_builds=$$( echo "$${active_builds}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$$//' ); \
					builds_num=$$(( $${builds_num} - 1 )); \
					depends="$${depends} $${dep}"; \
					depends=$$( echo "$${depends}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$$//' ); \
				else \
					${ECHO_CMD} "Errors occured while building a dependency port $$(cd $${dir}; ${MAKE} -V PKGNAME)"; \
					${ECHO_CMD} "Checkout its log"; \
					${ECHO_CMD} "    ${_parv_PORTS_LOGS_DIR}/${_parv_PORT_LOG_FILE})"; \
					${ECHO_CMD} "Terminating..."; \
					exit 1; \
				fi; \
			}; \
		done; \
		if { [ $${builds_num} -eq ${_parv_PARALLEL_BUILDS_NUMBER} ] || \
			( [ $${builds_num} -gt 0 ] && [ $${\#depends} -eq 0 ] ); }; then \
			if [ $$(( $${enable_feedback} % ${_parv_ON_LOCK_FEEDBACK_TIMEOUT} )) -eq 0 ]; then \
				${ECHO_CMD} "===> Unable to start more dependency builds."; \
				if [ $${builds_num} -eq ${_parv_PARALLEL_BUILDS_NUMBER} ]; then \
					${ECHO_CMD} "     ${_parv_PARALLEL_BUILDS_NUMBER} is maximum number of parallel builds."; \
				else \
					${ECHO_CMD} "     No dependencies to spawn. All remaining dependencies are building now."; \
				fi; \
				${_parv_PRINT_ACTIVE_BUILDS}; \
				enable_feedback=0; \
			fi; \
			enable_feedback=$$(( $${enable_feedback} + 1 )); \
			sleep ${_parv_CHECK_ACTIVE_TIMEOUT}; \
		fi; \
	done

# _parv_CHECK_ALL_DEPS_LOCKED
#
# This script prevents infinity non-sleeping loop in XXX-depends targets.
# If all dependencies in corresponding XXX_DEPENDS variable are locked
# then parent make process will sleep ${_parv_CHECK_ACTIVE_TIMEOUT} seconds.
#
_parv_CHECK_ALL_DEPS_LOCKED= \
	if ! [ $${\#depends} -eq 0 ]; then \
		enable_feedback=${_parv_ON_LOCK_FEEDBACK_TIMEOUT}; \
		while true; do \
			for dep in $${depends}; do \
				dir=$${dep\#*:}; \
				target=$${dep\#\#*:}; \
				[ $$dir != $$target ] && dir=$${dir%%:*}; \
				{ (cd $${dir}; ${MAKE} check-lock > /dev/null 2> /dev/null & wait $$! ) \
					&& break 2 || continue; }; \
			done; \
			if [ $$(( $${enable_feedback} % ${_parv_ON_LOCK_FEEDBACK_TIMEOUT} )) -eq 0 ]; then \
				${ECHO_CMD} "===> All dependencies are currently locked"; \
				${ECHO_CMD} "     Nothing to do"; \
				${ECHO_CMD} "     Waiting ..."; \
				enable_feedback=0; \
			fi; \
			enable_feedback=$$(( $${enable_feedback} + 1 )); \
			sleep ${_parv_CHECK_ACTIVE_TIMEOUT}; \
		done; \
	fi

#
# _TERMINATE_PROCESS_TREE	- this script contains all magic, related to
#							  termination of the whole process tree, starting
#							  from ${.MAKE.PID}.
#							  This script implements Breadth-first traversal of
#							  the process tree. It prevents processes of the
#							  current level from evaluation of any commands using
#							  STOP signal. Then it determines children of
#							  processes of the current level of process tree
#							  and stops them and so forth...
#							  It is necessary to stop processes to avoid new
#							  untracked pids. Finally, this script kills $${pids_to_kill}
#							  
# $${pids_to_kill}			- all pids of the process tree, starting from ${.MAKE.PID}
# 
_TERMINATE_PROCESS_TREE= \
	[ $$? -eq 0 ] && exit 0; \
	${ECHO_CMD}; \
	${ECHO_CMD} Terminating process tree strating from ${PKGNAME} build process \( PID ${.MAKE.PID} \); \
	pids_to_kill=${.MAKE.PID}; \
	/bin/kill -STOP ${.MAKE.PID} 2> /dev/null || ${DO_NADA}; \
	ppids=$$( ps -xao pid,ppid | awk "{ if (\$$2==${.MAKE.PID}) {print \$$1} }" ); \
	pids_to_kill="$${pids_to_kill} $${ppids}"; \
	/bin/kill -STOP "$${ppids%%$$$$*} $${ppids\#\#*$$$$}" 2> /dev/null || ${DO_NADA}; \
	while true; do \
		tmp_ppids=$$(${ECHO_CMD} $${ppids}); \
		ppids=""; \
		for ppid in $${tmp_ppids}; do \
			children=$$( ps -xao pid,ppid | awk "{ if (\$$2==$${ppid}) {print \$$1} }" ); \
			if [ $${\#children} -eq 0 ]; then continue; fi; \
			pids_to_kill="$${pids_to_kill} $${children}"; \
			ppids="$${ppids} $${children}"; \
			/bin/kill -STOP $${children} 2> /dev/null || ${DO_NADA}; \
		done; \
		if [ $${\#ppids} -eq 0 ]; then break; fi; \
	done; \
	${ECHO_CMD} Processes with the following PIDs will be killed: $${pids_to_kill}; \
	/bin/kill -KILL $${pids_to_kill} 2> /dev/null || ${DO_NADA}

#####################################################

#####################################################
# Parallel targets section
# TODO: outline intergation with bsd.port.mk
#
.if !defined(INSTALLS_DEPENDS)
check-license-depends: check-license-message
	@license_to_ask=""; \
	dirs_to_process=""; \
	for dir in $$(${ALL-DEPENDS-LIST}); do \
		license_status=$$(cd $${dir}; ${MAKE} -V _LICENSE_STATUS); \
		if [ "$${license_status}" = "ask" ]; then \
			license_to_ask="$${license_to_ask} $$(cd $${dir}; ${MAKE} -V PKGNAME)"; \
			dirs_to_process="$${dirs_to_process} $${dir}"; \
		fi; \
	done; \
	if [ $${license_to_ask} ]; then \
		${ECHO_CMD} "     The following ports will ask for license conformation:"; \
		for port in $${license_to_ask}; do \
			${ECHO_CMD} "         $${port}"; \
		done; \
		${ECHO_CMD} "     Unable to process in parallel way."; \
		${ECHO_CMD} "     Call:"; \
		${ECHO_CMD} "           make -D_parv_WANT_NON_PARALLEL_BUILD patch"; \
		${ECHO_CMD} "     in the following directories:"; \
		for dir in $${dirs_to_process}; do \
			${ECHO_CMD} "         $${dir}"; \
		done; \
		exit 1; \
	fi
.endif

check-license-message:
	@${ECHO_MSG} "===> Checking out licenses for ${PKGNAME} dependencies";

.if !defined(CONFIG_DONE_${UNIQUENAME:U}) && !defined(INSTALLS_DEPENDS)
locking-config-recursive: locking-config-message lock-port-dbdir config-recursive unlock-port-dbdir
.endif

locking-config-message:
	@${ECHO_MSG} "===> Setting user-specified options for ${PKGNAME} and dependencies";

config-recursive: config-conditional
	@if [ ! ${DEP_CHECK_CONFIG} ]; then \
		already_checked_file=/tmp/${_parv_CHECKED_CONFIG_F_PREFIX}.${.MAKE.PID}; \
		trap '${RM} -rf $${already_checked_file};' EXIT TERM INT; \
		${ECHO_CMD} ${.CURDIR} > $${already_checked_file}; \
	else \
		already_checked_file=${DEP_CHECK_CONFIG}; \
	fi; \
	for dir in $$(${MAKE} run-depends-list build-depends-list | uniq); do \
		if [ ! $$(grep $${dir}$$ $${already_checked_file}) ]; then \
			${ECHO_CMD} "     configure options for $${dir}"; \
			( cd $${dir}; \
			${MAKE} "DEP_CHECK_CONFIG=$${already_checked_file}" config-recursive ); \
			${ECHO_CMD} $${dir} >> $${already_checked_file}; \
		fi; \
	done

check-lock:
	@( pkg_name=${PKGNAME}; ${_parv_CHECK_LOCK} ) || { ${_parv_ON_LOCK_EXIT_SEQ}; }

check-active-build-conflicts:
.if ( defined(CONFLICTS) || defined(CONFLICTS_BUILD) || defined(CONFLICTS_INSTALL)) && !defined(DISABLE_CONFLICTS)
	@conflicts_with=; \
	active_builds=$$(cd ${LOCK_DIR}; ${LS} -dA ${CONFLICTS} ${CONFLICTS_BUILD} ${CONFLICTS_INSTALL} 2> /dev/null || ); \
	for entry in $${active_builds}; do \
		( pkg_name=$${entry}; ${_parv_CHECK_LOCK} ) || { \
			status=$$?; \
			if [ $${status} -eq ${_parv_ON_LOCK_EXIT_STATUS} ]; then \
				conflicts_with="$${conflicts_with} $${entry}"; \
			else \
				exit 1; \
			fi; \
		}; \
	done; \
	if [ -n "$${conflicts_with}" ]; then \
		${ECHO_MSG}; \
		${ECHO_MSG} "===> ${PKGNAME} conflicts with currently installing package(s): "; \
		for entry in $${conflicts_with}; do \
			${ECHO_MSG} "          $${entry}"; \
		done; \
		${ECHO_MSG}; \
		${ECHO_MSG} "     Please remove them first with pkg_delete(1)."; \
		exit 1; \
	fi
.endif

lock-port-dbdir:
	@attempts=-1; ${_parv_PORT_DBDIR_LOCK_LOOP}

lock-pkg-dbdir:
	@attempts=-1; ${_parv_PKG_DBDIR_LOCK_LOOP}

unlock-port-dbdir:
	@${_parv_PORT_DBDIR_DO_UNLOCK}

unlock-pkg-dbdir:
	@${_parv_PKG_DBDIR_DO_UNLOCK}

do-lock:
	@${DO_NADA}

do-unlock:
	@${DO_NADA}

# End of Parallel targets section
#####################################################

.endif # !defined(_POSTMKINCLUDED) && !defined(Parallel_Pre_Include)
