#define MAINPREFIX z
#define PREFIX root_rads

#include "\z\root_rads\addons\main\script_version.hpp"

#define VERSION MAJOR.MINOR.PATCH.BUILD
#define VERSION_AR MAJOR,MINOR,PATCH,BUILD

// HEMTT check needs a quoted version
#define VERSION_CONFIG version = QUOTE(VERSION); versionStr = QUOTE(VERSION); versionAr[] = {VERSION_AR}

// ignoreTarget (and its targetKnowledge field) requires Arma 3 v2.18
#define REQUIRED_VERSION 2.18
