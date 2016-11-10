#include "FastVision.h"

using namespace shapes;

static const char FORMATS[3][9] = {"XYBitmap", "XYPixmap", "ZPixmap "};

FastVision::FastVision(int x, int y, int width, int height){
    x = x;
    y = y;
    width = width;
    height = height;

    puts("");
    display = XOpenDisplay(NULL);

    int ignore, major, minor;
    Bool pixmaps;
    if(XQueryExtension(display, "MIT-SHM", &ignore, &ignore, &ignore))
        if(XShmQueryVersion(display, &major, &minor, &pixmaps))
            printf("XShm extension v%d.%d %s shared pixmaps\n", major, minor, pixmaps ? "with" : "without");

    root = DefaultRootWindow(display);
    XGetWindowAttributes(display, root, &window_attributes);
    screen = window_attributes.screen;
    ximg = XShmCreateImage(display, DefaultVisualOfScreen(screen), DefaultDepthOfScreen(screen),
                           ZPixmap, NULL, &shminfo, width, height);

    shminfo.shmid = shmget(IPC_PRIVATE, ximg->bytes_per_line * ximg->height, IPC_CREAT|0777);
    shminfo.shmaddr = ximg->data = (char*)shmat(shminfo.shmid, 0, 0);
    shminfo.readOnly = False;
    if(shminfo.shmid < 0)
        puts("Fatal shminfo error!");;
    Status s1 = XShmAttach(display, &shminfo);
    printf("XShmAttach() %s\n", s1 ? "success!" : "failure!");

    init = true;
}

FastVision::~FastVision(){
    if(!init)
        XDestroyImage(ximg);

    XShmDetach(display, &shminfo);
    shmdt(shminfo.shmaddr);
    XCloseDisplay(display);
}

char* FastVision::get_screen(){
    if(init)
        init = false;

    XShmGetImage(display, root, ximg, 0, 0, 0x00ffffff);
    return ximg->data;
}

void FastVision::ximg_meta(){
    printf("w %u  h %u  depth %u  B/line %u  b/pixel %u  format %s  offset %u  bm unit %u  B %08lx  G %08lx  R %08lx\n",
           ximg->width, ximg->height, ximg->depth, ximg->bytes_per_line, ximg->bits_per_pixel, FORMATS[ximg->format],
           ximg->xoffset, ximg->bitmap_unit, ximg->blue_mask, ximg->green_mask, ximg->red_mask);
}
