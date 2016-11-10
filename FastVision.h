#ifndef FASTVISION_HPP
#define FASTVISION_HPP

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/XShm.h>

#include <sys/ipc.h>
#include <sys/shm.h>

#include <stdio.h>
#include <stdint.h>

namespace shapes{

    class FastVision{
        public:
            FastVision(int x, int y, int width, int height);
            ~FastVision();

            // void move(int dx, int dy);
            char* get_screen();
            void ximg_meta();

            Display* display;
            Window root;
            XWindowAttributes window_attributes;
            Screen* screen;
            XImage* ximg;
            XShmSegmentInfo shminfo;

            int x, y, width, height;
            bool init;

    };
}

#endif
