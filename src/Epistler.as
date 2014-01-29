package {

import com.betweenpageandscreen.binding.fonts.BookHelveticaExtended;
import com.betweenpageandscreen.epistler.EpistlerContext;
import com.betweenpageandscreen.binding.config.BookConfig;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

public class Epistler extends Sprite {

  private var context:EpistlerContext;

  // Editor mode lets the user preview the text without a marker.
  public var EDITOR_MODE:Boolean = false;

  public function Epistler() {
    addEventListener(Event.ADDED_TO_STAGE, init);
  }

  public function init(event:Event=null):void {

    removeEventListener(Event.ADDED_TO_STAGE, init);

    EDITOR_MODE = (stage.loaderInfo.parameters["epistle_editor"]);

    // Set config.
    BookConfig.FPS = 31;
    BookConfig.CAM_FPS = 24;
    BookConfig.SHOW_FPS = false;
    BookConfig.MAX_UPSCALE = 5;
    BookConfig.TYPEFACE = new BookHelveticaExtended();

    if (EDITOR_MODE) {
      BookConfig.DISPLAY_PADDING = 0;
      BookConfig.BORDER_PADDING = 0;
      BookConfig.SCREEN_ALPHA_MAX = 0.85;
      BookConfig.CAM_BLUR = 50;
    }

    // Set up stage.
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;

    stage.quality = BookConfig.QUALITY;
    stage.frameRate = BookConfig.FPS;

    if (BookConfig.CAM_WIDESCREEN) {
      BookConfig.CAMERA_WIDTH = 720;
      BookConfig.CAMERA_HEIGHT = 405;
    } else {
      BookConfig.CAMERA_WIDTH = 640;
      BookConfig.CAMERA_HEIGHT = 480;
    }

    context = new EpistlerContext(EDITOR_MODE);

    addChild(context);
  }
}
}
