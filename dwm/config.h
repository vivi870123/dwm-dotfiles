/* See LICENSE file for copyright and license details. */

/* Constants */
#define TERMINAL  "st"
#define TERMCLASS "St"
#define BROWSER   "librewolf"

#define SUPER Mod4Mask
#define ALT   Mod1Mask
#define SHIFT ShiftMask
#define CTRL  ControlMask

/* appearance */

/* appearance */
static const int swallowfloating       = 0;        /* 1 means swallow floating windows by default */
static       unsigned int borderpx     = 3;        /* border pixel of windows */
static       unsigned int snap         = 32;       /* snap pixel */
static const unsigned int gappih       = 20;       /* horiz inner gap between windows */
static const unsigned int gappiv       = 10;       /* vert inner gap between windows */
static const unsigned int gappoh       = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov       = 30;       /* vert outer gap between windows and screen edge */
static                int smartgaps    = 1;        /* 1 means no outer gap when there is only one window */
static                int showbar      = 1;        /* 0 means no bar */
static                int topbar       = 1;        /* 0 means bottom bar */
static                char font[]      = "monospace:size=10";
static                char dmenufont[] = "monospace:size=10";
static const          char *fonts[]    = { font };
static char normbgcolor[]              = "#222222";
static char normbordercolor[]          = "#444444";
static char normfgcolor[]              = "#bbbbbb";
static char selfgcolor[]               = "#eeeeee";
static char selbordercolor[]           = "#005577";
static char selbgcolor[]               = "#005577";
static char *colors[][3]               = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;
const char *spcmd1[] = {TERMINAL, "-n", "spterm", "-g", "120x34", NULL };
const char *spcmd2[] = {TERMINAL, "-n", "spfm", "-g", "144x41", "-e", "ranger", NULL };
const char *spcmd3[] = {"keepassxc", NULL };
static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
	{"spranger",    spcmd2},
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class           instance     title           tags mask  isfloating  isterminal  noswallow  monitor */
	{ "Gimp",          NULL,        NULL,       	1 << 8,       0,           0,         0,        -1 },
	{ TERMCLASS,       NULL,        NULL,       	0,            0,           1,         0,        -1 },
	{ NULL,            NULL,        "Event Tester", 0,            0,           0,         1,        -1 },
	{ TERMCLASS,       "floatterm", NULL,       	0,            1,           1,         0,        -1 },
	{ TERMCLASS,       "bg",        NULL,       	1 << 7,       0,           1,         0,        -1 },
	{ TERMCLASS,       "spterm",    NULL,       	SPTAG(0),     1,           1,         0,        -1 },
	{ TERMCLASS,       "spcalc",    NULL,       	SPTAG(1),     1,           1,         0,        -1 },
};

/* layout(s) */
static float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static int nmaster     = 1;    /* number of clients in master area */
static int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
  /* symbol     arrange function */
  { "[@]",	spiral },		/* Fibonacci spiral */
  { "TTT",	bstack },		/* Master on top, slaves on bottom */

  { "[]=",	tile },			/* Default: Master on left, slaves on right */
  { "[\\]",	dwindle },		/* Decreasing in size right and leftward */

  { "[D]",	deck },			/* Master on left, slaves in monocle-like mode on right */
  { "[M]",	monocle },		/* All windows on top of eachother */

  { "|M|",	centeredmaster },		/* Master in middle, slaves on sides */
  { ">M>",	centeredfloatingmaster },	/* Same but master floats */

  { "><>",	NULL },			/* no layout function means floating behavior */
  { NULL,	NULL },

  /* { "===",      bstackhoriz }, */
  /* { "HHH",      grid }, */
  /* { "###",      nrowgrid }, */
  /* { "---",      horizgrid }, */
  /* { ":::",      gaplessgrid }, */
};

/* key definitions */
#define TAGKEYS(KEY,TAG) \
{ SUPER,            KEY,      view,           {.ui = 1 << TAG} }, \
{ SUPER|CTRL,       KEY,      toggleview,     {.ui = 1 << TAG} }, \
{ SUPER|SHIFT,      KEY,      tag,            {.ui = 1 << TAG} }, \
{ SUPER|CTRL|SHIFT, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define STATUSBAR "dwmblocks"

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbordercolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "st", NULL };

/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
  { "color0",		STRING,	 &normbordercolor },
  { "color8",		STRING,	 &selbordercolor },
  { "color0",		STRING,	 &normbgcolor },
  { "color4",		STRING,	 &normfgcolor },
  { "color0",		STRING,	 &selfgcolor },
  { "color4",		STRING,	 &selbgcolor },
  { "borderpx",		INTEGER, &borderpx },
  { "snap",		INTEGER, &snap },
  { "showbar",		INTEGER, &showbar },
  { "topbar",		INTEGER, &topbar },
  { "nmaster",		INTEGER, &nmaster },
  { "resizehints",	INTEGER, &resizehints },
  { "mfact",		FLOAT,	 &mfact },
  { "gappih",		INTEGER, &gappih },
  { "gappiv",		INTEGER, &gappiv },
  { "gappoh",		INTEGER, &gappoh },
  { "gappov",		INTEGER, &gappov },
  { "swallowfloating",	INTEGER, &swallowfloating },
  { "smartgaps",	INTEGER, &smartgaps },
};

#include <X11/XF86keysym.h>
#include "shiftview.c"

static const Key keys[] = {
  /* modifier          key              function        argument */
    { SUPER,           XK_j,            focusstack,     {.i = +1 } },
    { SUPER,           XK_k,            focusstack,     {.i = -1 } },
    { SUPER,	       XK_grave,	spawn,	        {.v = (const char*[]){ "dmenuunicode", NULL } } },
    { SUPER,	       XK_0,	        view,		{.ui = ~0 } },
    { SUPER|SHIFT,     XK_0,	        tag,		{.ui = ~0 } },
    { SUPER,	       XK_minus,	spawn,		SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-;  kill -44 $(pidof dwmblocks)") },
    { SUPER|SHIFT,     XK_minus,	spawn,		SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%-; kill -44 $(pidof dwmblocks)") },
    { SUPER,	       XK_equal,	spawn,		SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+;  kill -44 $(pidof dwmblocks)") },
    { SUPER|SHIFT,     XK_equal,	spawn,		SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%+; kill -44 $(pidof dwmblocks)") },
    { SUPER,	       XK_BackSpace,    spawn,		{.v = (const char*[]){ "sysact", NULL } } },
    { SUPER|SHIFT,     XK_BackSpace,    spawn,		{.v = (const char*[]){ "sysact", NULL } } },

    { SUPER,	       XK_Tab,	        view,		{0} },
    { SUPER,           XK_q,            killclient,     {0} },
    { SUPER|SHIFT,     XK_q,            quit,           {0} },
    { SUPER,	       XK_w,	        spawn,		{.v = (const char*[]){ BROWSER, NULL } } },
    { SUPER|SHIFT,     XK_w,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e", "sudo", "nmtui", NULL } } },
    { SUPER,	       XK_e,	        spawn,		SHCMD(TERMINAL " -e neomutt ; pkill -RTMIN+12 dwmblocks; rmdir ~/.abook 2>/dev/null") },
    { SUPER|SHIFT,     XK_e,	        spawn,		SHCMD(TERMINAL " -e abook -C ~/.config/abook/abookrc --datafile ~/.config/abook/addressbook") },
    { SUPER,	       XK_r,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e", "lfub", NULL } } },
    { SUPER|SHIFT,     XK_r,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e", "htop", NULL } } },
    { SUPER,	       XK_t,	        setlayout,	{.v = &layouts[0]} }, /* spiral */
    { SUPER|SHIFT,     XK_t,	        setlayout,	{.v = &layouts[1]} }, /* bstack */
    { SUPER,	       XK_y,	        setlayout,	{.v = &layouts[2]} }, /* title */
    { SUPER|SHIFT,     XK_y,	        setlayout,	{.v = &layouts[3]} }, /* dwindle */
    { SUPER,	       XK_u,	        setlayout,	{.v = &layouts[4]} }, /* deck */
    { SUPER|SHIFT,     XK_u,	        setlayout,	{.v = &layouts[5]} }, /* monocle */
    { SUPER,	       XK_i,	        setlayout,	{.v = &layouts[6]} }, /* centeredmaster */
    { SUPER|SHIFT,     XK_i,	        setlayout,	{.v = &layouts[7]} }, /* centeredfloatingmaster */
    { SUPER,	       XK_o,	        incnmaster,     {.i = +1 } },
    { SUPER|SHIFT,     XK_o,	        incnmaster,     {.i = -1 } },
    { SUPER,	       XK_p,	        spawn,		{.v = (const char*[]){ "mpc", "toggle", NULL } } },
    { SUPER|SHIFT,     XK_p,	        spawn,		SHCMD("mpc pause; pauseallmpv") },
    { SUPER,	       XK_bracketleft,  spawn,		{.v = (const char*[]){ "mpc", "seek", "-10", NULL } } },
    { SUPER|SHIFT,     XK_bracketleft,  spawn,		{.v = (const char*[]){ "mpc", "seek", "-60", NULL } } },
    { SUPER,	       XK_bracketright, spawn,		{.v = (const char*[]){ "mpc", "seek", "+10", NULL } } },
    { SUPER|SHIFT,     XK_bracketright, spawn,		{.v = (const char*[]){ "mpc", "seek", "+60", NULL } } },
    { SUPER,	       XK_backslash,    view,		{0} },
    /* { SUPER|SHIFT,  XK_backslash,    spawn,		SHCMD("") }, */

    { SUPER,	       XK_a,	        togglegaps,	{0} },
    { SUPER|SHIFT,     XK_a,	        defaultgaps,	{0} },
    { SUPER,	       XK_s,	        togglesticky,	{0} },
    { SUPER,	       XK_d,	        spawn,          {.v = dmenucmd } },
    { SUPER|SHIFT,     XK_d,	        spawn,		{.v = (const char*[]){ "passmenu", NULL } } },
    { SUPER,	       XK_f,	        togglefullscr,	{0} },
    { SUPER|SHIFT,     XK_f,	        setlayout,	{.v = &layouts[8]} },
    { SUPER,	       XK_g,	        shiftview,	{ .i = -1 } },
    { SUPER|SHIFT,     XK_g,	        shifttag,	{ .i = -1 } },
    { SUPER,	       XK_h,	        setmfact,	{.f = -0.05} },
    { SUPER,	       XK_l,	        setmfact,      	{.f = +0.05} },
    { SUPER,	       XK_semicolon,    shiftview,	{ .i = 1 } },
    { SUPER|SHIFT,     XK_semicolon,    shifttag,	{ .i = 1 } },
    { SUPER,	       XK_apostrophe,   togglescratch,	{.ui = 1} },
    { SUPER,	       XK_Return,	spawn,		{.v = termcmd } },
    { SUPER|SHIFT,     XK_Return,	togglescratch,	{.ui = 0} },

    { SUPER|SHIFT,     XK_h,            setcfact,       {.f = +0.25} },
    { SUPER|SHIFT,     XK_l,            setcfact,       {.f = -0.25} },
    { SUPER|ALT,       XK_o,            setcfact,       {.f =  0.00} },

    { SUPER,	       XK_z,		incrgaps,	{.i = +3 } },
    { SUPER,	       XK_x,		incrgaps,	{.i = -3 } },

    { SUPER,	       XK_b,		togglebar,	{0} },
    { SUPER,	       XK_n,		spawn,		SHCMD(TERMINAL " -e newsboat ; pkill -RTMIN+6 dwmblocks") },
    { SUPER,	       XK_m,		spawn,		{.v = (const char*[]){ TERMINAL, "-e", "ncmpcpp", NULL } } },
    { SUPER|SHIFT,     XK_m,		spawn,		SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; kill -44 $(pidof dwmblocks)") },
    { SUPER,	       XK_comma,	spawn,		{.v = (const char*[]){ "mpc", "prev", NULL } } },
    { SUPER|SHIFT,     XK_comma,	spawn,		{.v = (const char*[]){ "mpc", "seek", "0%", NULL } } },
    { SUPER,	       XK_period,	spawn,		{.v = (const char*[]){ "mpc", "next", NULL } } },
    { SUPER|SHIFT,     XK_period,	spawn,		{.v = (const char*[]){ "mpc", "repeat", NULL } } },

    { SUPER,	       XK_Left,	        focusmon,	{.i = -1 } },
    { SUPER|SHIFT,     XK_Left,	        tagmon,		{.i = -1 } },
    { SUPER,	       XK_Right,	focusmon,	{.i = +1 } },
    { SUPER|SHIFT,     XK_Right,	tagmon,		{.i = +1 } },

    { SUPER,	       XK_Page_Up,	shiftview,	{ .i = -1 } },
    { SUPER|SHIFT,     XK_Page_Up,	shifttag,	{ .i = -1 } },
    { SUPER,	       XK_Page_Down,	shiftview,	{ .i = +1 } },
    { SUPER|SHIFT,     XK_Page_Down,    shifttag,	{ .i = +1 } },

    /* { SUPER,	       XK_F1,		spawn,		SHCMD("groff -mom /usr/local/share/dwm/larbs.mom -Tpdf | zathura -") }, */
    { SUPER,	       XK_F2,		spawn,		{.v = (const char*[]){ "tutorialvids", NULL } } },
    { SUPER,	       XK_F3,		spawn,		{.v = (const char*[]){ "displayselect", NULL } } },
    { SUPER,	       XK_F4,		spawn,		SHCMD(TERMINAL " -e pulsemixer; kill -44 $(pidof dwmblocks)") },
    /* { SUPER,	       XK_F5,		xrdb,		{.v = NULL } }, */
    { SUPER,	       XK_F6,		spawn,		{.v = (const char*[]){ "torwrap", NULL } } },
    { SUPER,	       XK_F7,		spawn,		{.v = (const char*[]){ "td-toggle", NULL } } },
    { SUPER,	       XK_F8,		spawn,		{.v = (const char*[]){ "mailsync", NULL } } },
    { SUPER,	       XK_F9,		spawn,		{.v = (const char*[]){ "mounter", NULL } } },
    { SUPER,	       XK_F10,		spawn,		{.v = (const char*[]){ "unmounter", NULL } } },
    { SUPER,	       XK_F11,		spawn,		SHCMD("mpv --untimed --no-cache --no-osc --no-input-default-bindings --profile=low-latency --input-conf=/dev/null --title=webcam $(ls /dev/video[0,2,4,6,8] | tail -n 1)") },
    { SUPER,	       XK_F12,		spawn,		SHCMD("remaps") },
    { SUPER,	       XK_space,	zoom,		{0} },
    { SUPER|SHIFT,     XK_space,	togglefloating,	{0} },

    { 0,	       XK_Print,	spawn,		SHCMD("maim pic-full-$(date '+%y%m%d-%H%M-%S').png") },
    { SHIFT,	       XK_Print,	spawn,		{.v = (const char*[]){ "maimpick", NULL } } },
    { SUPER,	       XK_Print,	spawn,		{.v = (const char*[]){ "dmenurecord", NULL } } },
    { SUPER|SHIFT,     XK_Print,	spawn,		{.v = (const char*[]){ "dmenurecord", "kill", NULL } } },
    { SUPER,	       XK_Delete,	spawn,		{.v = (const char*[]){ "dmenurecord", "kill", NULL } } },
    { SUPER,	       XK_Scroll_Lock,	spawn,	        SHCMD("killall screenkey || screenkey &") },

    { 0, XF86XK_AudioMute,	        spawn,		SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; kill -44 $(pidof dwmblocks)") },
    { 0, XF86XK_AudioRaiseVolume,       spawn,		SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%- && wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+; kill -44 $(pidof dwmblocks)") },
    { 0, XF86XK_AudioLowerVolume,       spawn,		SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%+ && wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-; kill -44 $(pidof dwmblocks)") },
    { 0, XF86XK_AudioPrev,	        spawn,		{.v = (const char*[]){ "mpc", "prev", NULL } } },
    { 0, XF86XK_AudioNext,	        spawn,		{.v = (const char*[]){ "mpc",  "next", NULL } } },
    { 0, XF86XK_AudioPause,	        spawn,		{.v = (const char*[]){ "mpc", "pause", NULL } } },
    { 0, XF86XK_AudioPlay,	        spawn,		{.v = (const char*[]){ "mpc", "play", NULL } } },
    { 0, XF86XK_AudioStop,	        spawn,		{.v = (const char*[]){ "mpc", "stop", NULL } } },
    { 0, XF86XK_AudioRewind,	        spawn,		{.v = (const char*[]){ "mpc", "seek", "-10", NULL } } },
    { 0, XF86XK_AudioForward,	        spawn,		{.v = (const char*[]){ "mpc", "seek", "+10", NULL } } },
    { 0, XF86XK_AudioMedia,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e", "ncmpcpp", NULL } } },
    { 0, XF86XK_AudioMicMute,	        spawn,		SHCMD("pactl set-source-mute @DEFAULT_SOURCE@ toggle") },
    { 0, XF86XK_Calculator,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e", "bc", "-l", NULL } } },
    { 0, XF86XK_Sleep,		        spawn,		{.v = (const char*[]){ "sudo", "-A", "zzz", NULL } } },
    { 0, XF86XK_WWW,		        spawn,		{.v = (const char*[]){ BROWSER, NULL } } },
    { 0, XF86XK_DOS,		        spawn,		{.v = termcmd } },
    { 0, XF86XK_ScreenSaver,	        spawn,		SHCMD("slock & xset dpms force off; mpc pause; pauseallmpv") },
    { 0, XF86XK_TaskPane,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e", "htop", NULL } } },
    { 0, XF86XK_Mail,		        spawn,		SHCMD(TERMINAL " -e neomutt ; pkill -RTMIN+12 dwmblocks") },
    { 0, XF86XK_MyComputer,	        spawn,		{.v = (const char*[]){ TERMINAL, "-e",  "lfub",  "/", NULL } } },
    { 0, XF86XK_Launch1,	        spawn,		{.v = (const char*[]){ "xset", "dpms", "force", "off", NULL } } },
    { 0, XF86XK_TouchpadToggle,	        spawn,		SHCMD("(synclient | grep 'TouchpadOff.*1' && synclient TouchpadOff=0) || synclient TouchpadOff=1") },
    { 0, XF86XK_TouchpadOff,	        spawn,		{.v = (const char*[]){ "synclient", "TouchpadOff=1", NULL } } },
    { 0, XF86XK_TouchpadOn,	        spawn,		{.v = (const char*[]){ "synclient", "TouchpadOff=0", NULL } } },
    { 0, XF86XK_MonBrightnessUp,        spawn,		{.v = (const char*[]){ "xbacklight", "-inc", "15", NULL } } },
    { 0, XF86XK_MonBrightnessDown,      spawn,		{.v = (const char*[]){ "xbacklight", "-dec", "15", NULL } } },

    TAGKEYS(                XK_1,       0)
    TAGKEYS(                XK_2,       1)
    TAGKEYS(                XK_3,       2)
    TAGKEYS(                XK_4,       3)
    TAGKEYS(                XK_5,       4)
    TAGKEYS(                XK_6,       5)
    TAGKEYS(                XK_7,       6)
    TAGKEYS(                XK_8,       7)
    TAGKEYS(                XK_9,       8)

    /* { SUPER|ALT,         XK_i,          incrigaps,      {.i = +1 } }, */
    /* { SUPER|ALT|SHIFT,   XK_i,          incrigaps,      {.i = -1 } }, */
    /* { SUPER|ALT,         XK_o,          incrogaps,      {.i = +1 } }, */
    /* { SUPER|ALT|SHIFT,   XK_o,          incrogaps,      {.i = -1 } }, */
    /* { SUPER|ALT,         XK_6,          incrihgaps,     {.i = +1 } }, */
    /* { SUPER|ALT|SHIFT,   XK_6,          incrihgaps,     {.i = -1 } }, */
    /* { SUPER|ALT,         XK_7,          incrivgaps,     {.i = +1 } }, */
    /* { SUPER|ALT|SHIFT,   XK_7,          incrivgaps,     {.i = -1 } }, */
    /* { SUPER|ALT,         XK_8,          incrohgaps,     {.i = +1 } }, */
    /* { SUPER|ALT|SHIFT,   XK_8,          incrohgaps,     {.i = -1 } }, */
    /* { SUPER|ALT,         XK_9,          incrovgaps,     {.i = +1 } }, */
    /* { SUPER|ALT|SHIFT,   XK_9,          incrovgaps,     {.i = -1 } }, */
    /* { SUPER|SHIFT,       XK_space,      togglefloating, {0} }, */


};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
  /* click          event mask  button    function        argument */
  { ClkWinTitle,    0,          Button2,  zoom,           {0} },
  { ClkStatusText,  0,          Button1,  sigblock,       {.i = 1} },
  { ClkStatusText,  0,          Button2,  sigblock,       {.i = 2} },
  { ClkStatusText,  0,          Button3,  sigblock,       {.i = 3} },
  { ClkStatusText,  SHIFT,      Button1,  sigblock,       {.i = 6} },
  { ClkClientWin,   SUPER,      Button1,  movemouse,      {0} },
  { ClkClientWin,   SUPER,      Button2,  defaultgaps,	  {0} },
  { ClkClientWin,   SUPER,      Button3,  resizemouse,    {0} },
  { ClkTagBar,      0,          Button1,  view,           {0} },
  { ClkTagBar,      0,          Button3,  toggleview,     {0} },
  { ClkTagBar,      SUPER,      Button1,  tag,            {0} },
  { ClkTagBar,      SUPER,      Button3,  toggletag,      {0} },
  { ClkTagBar,	    0,	        Button4,  shiftview,	  {.i = -1} },
  { ClkTagBar,	    0,	        Button5,  shiftview,	  {.i = 1} },
  { ClkRootWin,	    0,	        Button2,  togglebar,	  {0} },
};

