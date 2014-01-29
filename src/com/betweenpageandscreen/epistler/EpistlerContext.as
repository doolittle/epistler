package com.betweenpageandscreen.epistler {

  import com.betweenpageandscreen.binding.config.BookConfig;
  import com.betweenpageandscreen.binding.events.BookEvent;
  import com.betweenpageandscreen.binding.bootstrapper.Bootstrapper;
  import com.betweenpageandscreen.binding.models.Pages;
  import com.betweenpageandscreen.binding.views.pages.Epistle;
  import com.betweenpageandscreen.epistler.views.pages.CustomEpistle;
  import com.bradwearsglasses.utils.delay.Delay;
  import com.bradwearsglasses.utils.delay.Delayer;
  import com.bradwearsglasses.utils.helpers.GraphicsHelper;
  import com.bradwearsglasses.utils.helpers.NumberHelper;
  import com.bradwearsglasses.utils.helpers.SpriteHelper;

  import flash.display.Sprite;
  import flash.events.Event;
  import flash.external.ExternalInterface;
  import flash.geom.Rectangle;

  public class EpistlerContext extends Sprite {

  private var bootstrapper:Bootstrapper;
  private var masks:Sprite;
  private var editor_mode:Boolean = false;
  private var epistle:Epistle;

  private var demo_text:String =
      "<< Your epistle will appear here >>";

  public function EpistlerContext(_editor_mode:Boolean = false) {

    editor_mode = _editor_mode;

    //Create a new epistle by passing a text string to it.
    epistle = (editor_mode) ? new CustomEpistle(demo_text, false, true) : new Epistle(demo_text, false, true);

    var i:int = -1;
    while (++i < BookConfig.NUM_MARKERS) { //All BPS markers work (for now)
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

    if (editor_mode) {
      // Set preview mode, which shows the epistle by default.
      bootstrapper.addEventListener(
        BookEvent.BOOK_READY,
        function(event:Event):void {
          bootstrapper.dispatch(BookEvent.MARKER_PREVIEW_MODE, {status:true});
        }
      )
    }

    //Attach it to the stage
    SpriteHelper.add_these(this,bootstrapper.book);

  }

  // Should probably do something with this...
  private function bootstrap_error(event:BookEvent):void {
    trace("## Shoot! Bootstrap error:");
    trace(event.data);
  }

  // Bootstrap is complete and the app is listening for markers.
  private function start(event:BookEvent):void {

     // Look for epistle passed by HTML page.
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
          updateText(epistle.epistle.epistle)
        } else {
          trace("Failed loading epistle.");
        }
      } catch (e:Error) {
        trace("Could not load epistle.");
      }
    }

    draw_side_masks();
    stage.addEventListener(Event.RESIZE, draw_side_masks);

  }

  // The blur we put on the video in the background of the editor overflows
  // the edge of the video frame, so we want to mask it. 
  private function draw_side_masks(event:Event=null):void {

    if (!bootstrapper || !bootstrapper.book) return;
    if (!masks) masks = addChild(new Sprite) as Sprite;

    var book_bounds:Rectangle = bootstrapper.book.getBounds(stage);

    SpriteHelper.wipe(masks);

    var top_bounds:Rectangle = GraphicsHelper.rect(stage.stageWidth, book_bounds.top, 0, 0);
    var bottom_bounds:Rectangle = GraphicsHelper.rect(stage.stageWidth, stage.stageHeight - book_bounds.bottom, 0, book_bounds.bottom);

    var left_bounds:Rectangle = GraphicsHelper.rect(book_bounds.left, stage.stageHeight, 0,0);
    var right_bounds:Rectangle = GraphicsHelper.rect((stage.stageWidth-book_bounds.right), stage.stageHeight,book_bounds.right, 0);

    GraphicsHelper.box(masks, top_bounds, 0xFFFFFF);
    GraphicsHelper.box(masks, bottom_bounds, 0xFFFFFF);

    GraphicsHelper.box(masks, left_bounds, 0xFFFFFF);
    GraphicsHelper.box(masks, right_bounds, 0xFFFFFF);

  }

  private function updateText(text:String):Boolean {
    update_epistle(text);
    //randomize(text);
    return true;
  }

  // Randomly change text length for testing speed and layout.
  private function randomize(text:String):void {
    var lines:Array = text.split("\n");
    var randoms:Array = lines.slice(0,NumberHelper.random(0,lines.length));
    update_epistle(randoms.join("\n"));
    Delay.delay(5000, randomize, [text]);
  }

  private var update_markers_timer:Number;
  public function update_epistle(text:String):void {
    if (!epistle || !text) return;

    // de-bounce by 400ms
    var delayer:Delayer = Delay.delay(400,epistle.update_text, [text],  update_markers_timer, true);
    update_markers_timer = delayer.timer_id;

  }

}
}
