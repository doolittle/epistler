package com.betweenpageandscreen.epistler {

import com.betweenpageandscreen.binding.config.BookConfig;
import com.betweenpageandscreen.binding.events.BookEvent;
import com.betweenpageandscreen.binding.bootstrapper.Bootstrapper;
import com.betweenpageandscreen.binding.interfaces.iBookModule;
import com.betweenpageandscreen.binding.models.Pages;
import com.betweenpageandscreen.binding.views.pages.Epistle;
import com.betweenpageandscreen.epistler.views.pages.CustomEpistle;
import com.bradwearsglasses.utils.delay.Delay;
import com.bradwearsglasses.utils.delay.Delayer;
import com.bradwearsglasses.utils.helpers.NumberHelper;
import com.bradwearsglasses.utils.helpers.SpriteHelper;

import flash.display.Sprite;
import flash.external.ExternalInterface;


public class EpistlerContext extends Sprite {

  private var bootstrapper:Bootstrapper;
  private var editor_mode:Boolean = false;
  private var epistle:Epistle;

  private var demo_text:String =
      "<< Your epistle will appear here >>";

  public function EpistlerContext(_editor_mode:Boolean = false) {

    editor_mode = _editor_mode;

    //Create a new epistle by passing a text string to it.
    epistle = (editor_mode) ? new CustomEpistle(demo_text, false, true) : new Epistle(demo_text, false, true);

    var i:int = -1;
    while (++i < BookConfig.NUM_MARKERS) {
      Pages.PAGES.push(epistle);
    }

    // Create new bootstrapper from the BPS Binder library.
    // The bootstrapper will take care of setting up the interface.
    bootstrapper = new Bootstrapper(this);

    // Set listeners on bootstrapper.
    bootstrapper.addEventListener(BookEvent.BOOTSTRAP_ERROR, bootstrap_error);
    bootstrapper.addEventListener(BookEvent.BOOTSTRAP_COMPLETE, start);

    //Start bootstrapper
    bootstrapper.start();

    //Attach it to the stage
    SpriteHelper.add_these(this,bootstrapper.book);

  }

  // You'll want to handle these.
  private function bootstrap_error(event:BookEvent):void {
    trace("## Shoot! Bootstrap error:");
    trace(event.data);
  }

  // Bootstrap is complete and the app is listening for markers.
  private function start(event:BookEvent):void {
    trace("## Bootstrap complete. Listening for markers...");

    if (ExternalInterface.available) {
      try {
        ExternalInterface.addCallback("updateText", updateText);
      } catch (e:Error) {
        trace("Couldn't set up external interface");
      }

      // TODO: Pass a flag to SWF informing it there's an epistle available.
      try {
        var epistle:Object = ExternalInterface.call("loadEpistle");
        if (epistle) {
          trace("Epistle is:" + epistle.epistle.epistle);
          updateText(epistle.epistle.epistle)
        } else {
          trace("Failed loading epistle.");
        }
      } catch (e:Error) {
        trace("Could not load epistle.");
      }
    }

    if (editor_mode) {
      // Set preview mode, which shows the epistle by default.
      // TODO: Set this listener on an event when the bootstrapper has finished intro-ing.
      Delay.delay(1000, function(...rest):void {
        bootstrapper.dispatch(BookEvent.MARKER_PREVIEW_MODE, {status:true});
        });
    }
  }

  private function updateText(text:String):Boolean {
    trace("Trying to update text with:" + text);
    update_epistle(text);
    //randomize(text);
    return true;
  }

  private function randomize(text:String):void {
    var lines:Array = text.split("\n");
    var randoms:Array = lines.slice(0,NumberHelper.random(0,lines.length));
    trace(" \n\n ### ARRAY IS: " + randoms.length + " lines long\n\n");
    update_epistle(randoms.join("\n"));
    Delay.delay(5000, randomize, [text]);
  }

  private var update_markers_timer:Number;
  public function update_epistle(text:String):void {
    //trace("Updating epistle with:\n" + text);
    if (!epistle || !text) return;

    // de-bounce by 1s
     var delayer:Delayer = Delay.delay(400,epistle.update_text, [text],  update_markers_timer, true);
     update_markers_timer = delayer.timer_id;

  }

}
}
