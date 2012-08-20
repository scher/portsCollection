Execute the following command line in the project's root directory:
make -f dev_env.mk list_env_info
It will change nothing, but list some necessary environment variables

_parv_WANT_PARALLEL_BUILD - assign this variable any value to enable parralel instalation
( e.g. make -D_parv_WANT_PARALLEL_BUILD install)

------------------------------------------------------

All new lines of code will bew surrounded by the following comment lines:
############### PAR_PORTS SPECIFIC COMMENT LINE ############### 
############### THIS ENTRY IS FOR DEBUGGING PURPOSE  ###############
############### Detailed comment if necessary
some code here
############### END OF PAR_PORTS SPECIFIC COMMENT LINE  ###############

Parallel specific output lines will be surrounded by the following, just to catch them from other output
=================_PAR_PORTS_SPECIFIC_OUTPUT_==============
==============_END_OF_PAR_PORTS_SPECIFIC_OUTPUT_==============

------------------------------------------------------

Almost all global parallel specific variables are prefixed with "_parv_". Naturally this will be ommited at the end of development.

All parallel specific debugging variables are prefixed with "_dparv_".

