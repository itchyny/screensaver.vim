#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <time.h>

#define TTY_PATH "/dev/tty"
#define CSI "\x1b["

#define CSI_FUNC(name,format)\
  static inline void name(void) {\
    printf(CSI format); }
CSI_FUNC(erasescreen, "2J")
CSI_FUNC(cursorhide, "?25l")
CSI_FUNC(cursorshow, "?25h")
CSI_FUNC(savescreen, "?1049h")
CSI_FUNC(restorescreen, "?1049l")

#define CSI_FUNC1(name,format)\
  static inline void name(int arg) {\
    printf(CSI format, arg); }
CSI_FUNC1(cursorup, "%dA")
CSI_FUNC1(cursordown, "%dB")
CSI_FUNC1(cursorforward, "%dC")

#define CSI_FUNC2(name,format)\
  static inline void name(int arg1, int arg2) {\
    printf(CSI format, arg1, arg2); }
CSI_FUNC2(cursormove, "%d;%dH")

#define getcolor(red, green, blue)\
  16 + 36 * (red / 43) + 6 * (green / 43) + (blue / 43)
#define CSI_COLOR_FUNC(name,format,num)\
  static inline void name(int red, int green, int blue) {\
    printf(CSI format, num); }
CSI_FUNC1(setcolor, "48;5;%dm")
CSI_FUNC(setdefaultcolor, "0m")

static void saftyexit(int status)
{
  setdefaultcolor();
  cursorshow();
  restorescreen();
  exit(status);
}

static void interuppthandler(int signal)
{
  (void)signal;
  saftyexit(EXIT_SUCCESS);
}

static int terminalwidth, terminalheight;
static void terminalsize(void)
{
  int status;
  struct winsize size;
  FILE *console;
  terminalwidth = 110; terminalheight = 34;
  if ((console = fopen(TTY_PATH, "r")) == NULL &&
       ioctl(fileno(stdout), TIOCGWINSZ, &size) == 0) {
    terminalwidth = size.ws_col;
    terminalheight = size.ws_row;
  } else if (ioctl(fileno(console), TIOCGWINSZ, &size) == 0) {
    terminalwidth = size.ws_col;
    terminalheight = size.ws_row;
  }
}

static int pixel_number[10][5][4] = {
  {{0, 6, 0, 0}, {0, 2, 2, 2}, {0, 2, 2, 2}, {0, 2, 2, 2}, {0, 6, 0, 0}},
  {{4, 2, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}},
  {{0, 6, 0, 0}, {4, 2, 0, 0}, {0, 6, 0, 0}, {0, 2, 4, 0}, {0, 6, 0, 0}},
  {{0, 6, 0, 0}, {4, 2, 0, 0}, {0, 6, 0, 0}, {4, 2, 0, 0}, {0, 6, 0, 0}},
  {{0, 2, 2, 2}, {0, 2, 2, 2}, {0, 6, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}},
  {{0, 6, 0, 0}, {0, 2, 4, 0}, {0, 6, 0, 0}, {4, 2, 0, 0}, {0, 6, 0, 0}},
  {{0, 6, 0, 0}, {0, 2, 4, 0}, {0, 6, 0, 0}, {0, 2, 2, 2}, {0, 6, 0, 0}},
  {{0, 6, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}, {4, 2, 0, 0}},
  {{0, 6, 0, 0}, {0, 2, 2, 2}, {0, 6, 0, 0}, {0, 2, 2, 2}, {0, 6, 0, 0}},
  {{0, 6, 0, 0}, {0, 2, 2, 2}, {0, 6, 0, 0}, {4, 2, 0, 0}, {0, 6, 0, 0}},
};

static int pixel_colon[5][4] =
  {{0, 0, 0, 0}, {1, 2, 1, 0}, {0, 0, 0, 0}, {1, 2, 1, 0}, {0, 0, 0, 0}};

static char spaces[8][10] =
  { "", " ", "  ", "   ", "    ", "     ", "      ", "       " };

static int printspaces(char c, int cursori, int cursorj, int skiphead)
{
  int (*map)[4];
  int i, j, k, width, mwidth, skipwidth;
  if ('0' <= c && c <= '9') {
    map = pixel_number[c - '0'];
  } else if (c == ':') {
    map = pixel_colon;
  } else {
    return 0;
  }
  mwidth = 0;
  if (skiphead) {
    skipwidth = 10;
    for (i = 0; i < 5; ++i) {
      skipwidth = skipwidth > map[i][0] ? map[i][0] : skipwidth;
    }
  } else {
    skipwidth = 0;
  }
  for (i = 0; i < 5; ++i) {
    width = 0;
    for (j = 0; j < 3; ++j) {
      width += map[i][j] - skipwidth * (j == 0);
      if (map[i][++j]) {
        cursormove(cursori + i, cursorj + width);
        width += map[i][j];
        printf("%s", spaces[map[i][j]]);
      }
    }
    mwidth = mwidth > width ? mwidth : width;
  }
  return mwidth;
}

static void clockscreensaver(void)
{
  int i, j, di, dj, pi, pj, k, l, red, green, blue, colordiff, index, width;
  int * colorptr;
  int * colorptrs[3] = { &red, &green, &blue };
  time_t timer;
  struct tm *date;
  char str[256];
  i = rand() % ((terminalheight - 5) / 2 + 1) + (terminalheight - 5) / 4 + 1;
  j = rand() % ((terminalwidth - 60) / 2 + 1) + (terminalwidth - 60) / 4 + 1;
  pi = i; pj = j;
  di = (rand() % 2) * 2 - 1; dj = (rand() % 2) * 4 - 2;
  red = rand() % 128 + 64; green = rand() % 128 + 64; blue = rand() % 128 + 64;
  colordiff = ((rand() % 2) * 2 - 1) * 8; colorptr = colorptrs[rand() % 3];
  index = 0; width = 0;
  while (1) {
    ++index;
    timer = time(NULL);
    date = localtime(&timer);
    setdefaultcolor();
    for (k = 0; k < 5; ++k) {
      cursormove(pi + k, pj);
      printf("                                                              ");
    }
    sprintf(str, "%d:%02d:%02d", date->tm_hour, date->tm_min, date->tm_sec);
    width = 0;
    setcolor(getcolor(red, green, blue));
    for (k = 0; str[k]; ++k) {
      width += printspaces(str[k], i, j + width, k == 0) + 2;
    }
    fflush(stdout);
    pi = i; pj = j; i += di; j += dj;
    if (di < 0 && i <= 1 || di > 0 && i + 4 >= terminalheight) {
      di = - di;
      i += 2 * di;
    }
    if (dj < 0 && j <= 1 || dj > 0 && j + width - 2 >= terminalwidth) {
      dj = - dj;
      j += 2 * dj;
    }
    if (index % 24 == 0) {
      colordiff = ((rand() % 2) * 2 - 1) * 8;
      colorptr = colorptrs[rand() % 3];
    }
    (*colorptr) += colordiff;
    if (colordiff < 0 && (*colorptr) < 8 || colordiff > 0 && (*colorptr) > 248) {
      colordiff = - colordiff; (*colorptr) += 2 * colordiff;
    }
    usleep(100000);
    if (index % 24 == 0) {
      terminalsize();
      setdefaultcolor();
      for (k = 0; k < terminalheight; ++k) {
        cursormove(k, 1);
        for (l = 0; l < terminalwidth; ++l) {
          printf(" ");
        }
      }
      cursorhide();
    }
  }
}

int main(int argc, char *argv[])
{

  srand((unsigned)time(NULL));

  signal(SIGINT, interuppthandler);
  signal(SIGQUIT, interuppthandler);
  signal(SIGTERM, interuppthandler);
  signal(SIGFPE, interuppthandler);
  signal(SIGSEGV, interuppthandler);

  terminalsize();
  savescreen();
  erasescreen();
  cursorhide();
  clockscreensaver();
  saftyexit(EXIT_SUCCESS);

  return 0;
}
