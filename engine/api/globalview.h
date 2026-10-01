//
//  globalview.h
//  Mr-FCrack
//
//  Versión simplificada de globalview para app standalone.
//  NO implementa la funcionalidad real (inyección global).
//  Solo declara las estructuras y variables que usa Tweak.mm.
//

#ifndef globalview_h
#define globalview_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Estructura GVData simplificada
typedef struct {
    bool enable;
    bool viewHosted;
    bool appLoaded;
    bool setWindowVisible;
    bool windowVisibleState;
    bool customButtonAction;
    bool floatBtnClick;
    bool touchableAll;
    bool followCurrentOrientation;

    CGRect floatMenuRect;
    CGRect touchableRect;

    int curOrientation;

    // Icono del botón flotante
    uint8_t buttonImageData[512 * 1024];
    size_t buttonImageSize;
} GVData;

// Valores por defecto
static const GVData GVDataDefault = {
    .enable = false,
    .viewHosted = false,
    .appLoaded = false,
    .setWindowVisible = false,
    .windowVisibleState = true,
    .customButtonAction = false,
    .floatBtnClick = false,
    .touchableAll = true,
    .followCurrentOrientation = false,
    .floatMenuRect = {{0, 0}, {0, 0}},
    .touchableRect = {{0, 0}, {0, 0}},
    .curOrientation = 0,
    .buttonImageData = {0},
    .buttonImageSize = 0,
};

#endif /* globalview_h */
