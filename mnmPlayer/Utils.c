//
//  Utils.c
//  slsPlayer
//
//  Created by aobskl on 6/16/16.
//  Copyright © 2016 AoB. All rights reserved.
//

#include "Utils.h"

void getTimeText(int totalSeconds, char *out, bool alwaysPutHour) {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (alwaysPutHour || hours) {
        sprintf(out, "%02d:%02d:%02d", hours, minutes, seconds);
    } else {
        sprintf(out, "%02d:%02d", minutes, seconds);
    }
}
